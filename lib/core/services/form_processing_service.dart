import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:civic_ai_app/core/services/api_client.dart';
import 'package:civic_ai_app/core/constants/app_constants.dart';
import 'package:civic_ai_app/models/form_extract_models.dart';

class FormProcessingService {
  final ApiClient _apiClient;

  FormProcessingService({ApiClient? apiClient})
    : _apiClient =
          apiClient ?? ApiClient(baseUrl: AppConstants.analyticsBaseUrl);

  /// Extract form data from an image
  Future<FormExtractResponse> extractForm(dynamic imageFile) async {
    try {
      final bytes = await _getImageBytes(imageFile);
      final response = await _apiClient.postMultipartBytes(
        '/form/extract',
        bytes: bytes,
        fieldName: 'file',
        fileName: _getFileName(imageFile),
      );

      return FormExtractResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to extract form: $e');
    }
  }

  /// Validate image quality and suitability
  Future<ImageValidationResponse> validateImage(dynamic imageFile) async {
    try {
      final bytes = await _getImageBytes(imageFile);
      final response = await _apiClient.postMultipartBytes(
        '/image-validation/validate-image',
        bytes: bytes,
        fieldName: 'file',
        fileName: _getFileName(imageFile),
      );

      return ImageValidationResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to validate image: $e');
    }
  }

  /// Get image bytes from either XFile or File
  Future<Uint8List> _getImageBytes(dynamic imageFile) async {
    if (imageFile is XFile) {
      return await imageFile.readAsBytes();
    }
    // For native File objects
    return await imageFile.readAsBytes();
  }

  /// Get filename from either XFile or File
  String _getFileName(dynamic imageFile) {
    if (imageFile is XFile) {
      return imageFile.name;
    }
    // For native File objects
    try {
      return imageFile.path.split('/').last;
    } catch (e) {
      return 'upload';
    }
  }
}
