import 'dart:convert';
import 'dart:io';
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
    try {
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
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

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
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
      throw UnauthorizedException('Unauthorized');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Not found');
    } else {
      throw ServerException('Server error: ${response.statusCode}');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
