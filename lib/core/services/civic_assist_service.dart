import 'package:civic_ai_app/core/services/api_client.dart';
import 'package:civic_ai_app/core/constants/app_constants.dart';
import 'package:civic_ai_app/models/civic_assist_response.dart';

class CivicAssistService {
  final ApiClient _apiClient;

  CivicAssistService({ApiClient? apiClient})
    : _apiClient =
          apiClient ?? ApiClient(baseUrl: AppConstants.civicAssistBaseUrl);

  /// Get office recommendations based on problem and location
  Future<CivicAssistResponse> getOfficeRecommendation({
    required String problem,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(
        '/civic-assist',
        body: {
          'problem': problem,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return CivicAssistResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get office recommendation: $e');
    }
  }
}
