import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:civic_ai_app/core/constants/app_constants.dart';

class ApiClient {
  final http.Client httpClient;
  final String baseUrl;

  ApiClient({http.Client? httpClient, String? baseUrl})
    : httpClient = httpClient ?? http.Client(),
      baseUrl = baseUrl ?? AppConstants.baseUrl;

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl$endpoint'), headers: _buildHeaders(headers))
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    debugPrint('[ApiClient] POST $url');
    debugPrint('[ApiClient] Body: ${jsonEncode(body)}');
    try {
      final response = await httpClient
          .post(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);

      debugPrint(
        '[ApiClient] Response ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] Error: $e');
      rethrow;
    }
  }

  /// Upload file as multipart (works on web and native)
  /// Automatically converts File to bytes for cross-platform compatibility
  Future<dynamic> postMultipart(
    String endpoint, {
    required dynamic file,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final bytes = await file.readAsBytes() as Uint8List;
      
      // Try to extract filename, but use default on web
      String? fileName;
      try {
        final path = file.path as String?;
        if (path != null) {
          fileName = path.split('/').last;
        }
      } catch (e) {
        // file doesn't have path or path is not accessible
      }
      
      return postMultipartBytes(
        endpoint,
        bytes: bytes,
        fieldName: fieldName,
        fields: fields,
        headers: headers,
        fileName: fileName,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload multipart with bytes (works on web and native)
  Future<dynamic> postMultipartBytes(
    String endpoint, {
    required Uint8List bytes,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add headers
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add file as bytes (works on web and native)
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: fileName ?? 'upload',
        ),
      );

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(
        AppConstants.apiTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized: ${response.body}');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Not found (404): ${response.body}');
    } else if (response.statusCode == 403) {
      throw ServerException('Forbidden (403): ${response.body}');
    } else {
      throw ServerException(
        'Server error ${response.statusCode}: ${response.body}',
      );
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}
