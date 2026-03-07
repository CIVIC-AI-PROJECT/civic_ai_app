import 'package:civic_ai_app/core/services/api_client.dart';
import 'package:civic_ai_app/core/constants/app_constants.dart';
import 'package:civic_ai_app/models/grievance_analytics_models.dart';

class GrievanceAnalyticsService {
  final ApiClient _apiClient;

  GrievanceAnalyticsService({ApiClient? apiClient})
    : _apiClient =
          apiClient ?? ApiClient(baseUrl: AppConstants.analyticsBaseUrl);

  /// Get intelligence dashboard data
  Future<IntelligenceDashboard> getIntelligenceDashboard() async {
    try {
      final response = await _apiClient.get(
        '/grievance/intelligence-dashboard',
      );
      return IntelligenceDashboard.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get intelligence dashboard: $e');
    }
  }

  /// Get grievance clusters
  Future<List<GrievanceCluster>> getClusters() async {
    try {
      final response = await _apiClient.get('/grievance/cluster');

      if (response is List) {
        return response
            .map((e) => GrievanceCluster.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('clusters')) {
        return (response['clusters'] as List)
            .map((e) => GrievanceCluster.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get clusters: $e');
    }
  }

  /// Get anomaly detection results
  Future<List<GrievanceAnomaly>> getAnomalies() async {
    try {
      final response = await _apiClient.get('/grievance/anomaly');

      if (response is List) {
        return response
            .map((e) => GrievanceAnomaly.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('anomalies')) {
        return (response['anomalies'] as List)
            .map((e) => GrievanceAnomaly.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get anomalies: $e');
    }
  }

  /// Get heatmap data
  Future<List<HeatmapDataPoint>> getHeatmapData() async {
    try {
      final response = await _apiClient.get('/grievance/heatmap');

      if (response is List) {
        return response
            .map((e) => HeatmapDataPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('heatmap')) {
        return (response['heatmap'] as List)
            .map((e) => HeatmapDataPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get heatmap data: $e');
    }
  }

  /// Get recent spikes in grievances
  Future<List<RecentSpike>> getRecentSpikes() async {
    try {
      final response = await _apiClient.get('/grievance/recent-spikes');

      if (response is List) {
        return response
            .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response.containsKey('spikes')) {
        return (response['spikes'] as List)
            .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get recent spikes: $e');
    }
  }
}
