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

      if (response is Map && response.containsKey('cluster_keywords')) {
        final Map<String, dynamic> keywords =
            response['cluster_keywords'] as Map<String, dynamic>;
        final Map<String, dynamic> summary =
            response['cluster_summary'] as Map<String, dynamic>? ?? {};

        return keywords.entries.map((e) {
          final clusterId = int.tryParse(e.key) ?? 0;
          final countValue = summary[clusterId.toString()];
          final count = countValue is num ? countValue.toInt() : 0;
          return GrievanceCluster(
            clusterId: clusterId,
            keywords: (e.value as List<dynamic>).cast<String>(),
            count: count,
          );
        }).toList();
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

      if (response is Map && response.containsKey('alerts')) {
        return (response['alerts'] as List)
            .map((e) => GrievanceAnomaly.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
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

      if (response is Map) {
        return response.entries.map((e) {
          final value = e.value;
          return HeatmapDataPoint(
            state: e.key as String,
            intensity: value is num ? value.toInt() : 0,
          );
        }).toList();
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

      if (response is Map && response.containsKey('recent_spikes')) {
        return (response['recent_spikes'] as List)
            .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get recent spikes: $e');
    }
  }
}
