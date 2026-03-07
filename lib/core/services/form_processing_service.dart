import 'dart:io';
import 'package:civic_ai_app/core/services/api_client.dart';
import 'package:civic_ai_app/core/constants/app_constants.dart';
import 'package:civic_ai_app/models/form_extract_models.dart';

class FormProcessingService {
  final ApiClient _apiClient;

  FormProcessingService({ApiClient? apiClient})
    : _apiClient =
          apiClient ?? ApiClient(baseUrl: AppConstants.analyticsBaseUrl);

  /// Extract form data from an image
  Future<FormExtractResponse> extractForm(File imageFile) async {
    try {
      final response = await _apiClient.postMultipart(
        '/form/extract',
        file: imageFile,
        fieldName: 'image',
      );

      return FormExtractResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to extract form: $e');
    }
  }

  /// Validate image quality and suitability
  Future<ImageValidationResponse> validateImage(File imageFile) async {
    try {
      final response = await _apiClient.postMultipart(
        '/image-validation/validate-image',
        file: imageFile,
        fieldName: 'image',
      );

      return ImageValidationResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to validate image: $e');
    }
  }
}
