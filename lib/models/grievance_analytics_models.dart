// Models for Grievance Analytics Endpoints

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

class GrievanceCluster {
  final int clusterId;
  final List<String> keywords;
  final int count;

  GrievanceCluster({
    required this.clusterId,
    required this.keywords,
    required this.count,
  });

  factory GrievanceCluster.fromJson(Map<String, dynamic> json) {
    return GrievanceCluster(
      clusterId: _asInt(json['cluster_id']),
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      count: _asInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cluster_id': clusterId, 'keywords': keywords, 'count': count};
  }
}

class GrievanceAnomaly {
  final String state;
  final String issue;
  final int count;

  GrievanceAnomaly({
    required this.state,
    required this.issue,
    required this.count,
  });

  factory GrievanceAnomaly.fromJson(Map<String, dynamic> json) {
    return GrievanceAnomaly(
      state: json['state'] as String,
      issue: json['issue'] as String,
      count: _asInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'state': state, 'issue': issue, 'count': count};
  }
}

class HeatmapDataPoint {
  final String state;
  final int intensity;

  HeatmapDataPoint({required this.state, required this.intensity});

  factory HeatmapDataPoint.fromJson(Map<String, dynamic> json) {
    return HeatmapDataPoint(
      state: json['state'] as String,
      intensity: _asInt(json['intensity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'state': state, 'intensity': intensity};
  }
}

class RecentSpike {
  final String state;
  final String issue;
  final int recentCount;
  final int previousCount;
  final int growth;

  RecentSpike({
    required this.state,
    required this.issue,
    required this.recentCount,
    required this.previousCount,
    required this.growth,
  });

  factory RecentSpike.fromJson(Map<String, dynamic> json) {
    return RecentSpike(
      state: json['state'] as String,
      issue: json['issue'] as String,
      recentCount: _asInt(json['recent_count']),
      previousCount: _asInt(json['previous_count']),
      growth: _asInt(json['growth']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'issue': issue,
      'recent_count': recentCount,
      'previous_count': previousCount,
      'growth': growth,
    };
  }
}

class IntelligenceDashboard {
  final int totalRecords;
  final Map<String, int> stateHeatmap;
  final List<GrievanceCluster> topClusters;
  final List<RecentSpike> recentSpikes;
  final Map<String, int> clusterKeywords;

  IntelligenceDashboard({
    required this.totalRecords,
    required this.stateHeatmap,
    required this.topClusters,
    required this.recentSpikes,
    required this.clusterKeywords,
  });

  factory IntelligenceDashboard.fromJson(Map<String, dynamic> json) {
    // Parse cluster_summary
    List<GrievanceCluster> clusters = [];
    if (json['cluster_summary'] is List) {
      clusters = (json['cluster_summary'] as List).map((e) {
        final clusterData = e as Map<String, dynamic>;
        return GrievanceCluster(
          clusterId: _asInt(clusterData['cluster']),
          keywords: json['cluster_keywords'] != null
              ? (json['cluster_keywords'][clusterData['cluster'].toString()]
                            as List<dynamic>?)
                        ?.cast<String>() ??
                    []
              : [],
          count: _asInt(clusterData['count']),
        );
      }).toList();
    }

    // Parse recent_spikes
    List<RecentSpike> spikes = [];
    if (json['recent_spikes'] is List) {
      spikes = (json['recent_spikes'] as List)
          .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return IntelligenceDashboard(
      totalRecords: _asInt(json['total_records']),
      stateHeatmap: (json['state_heatmap'] as Map? ?? {}).map(
        (key, value) => MapEntry(key as String, _asInt(value)),
      ),
      topClusters: clusters,
      recentSpikes: spikes,
      clusterKeywords: Map<String, int>.from(
        (json['cluster_keywords'] ?? {}).map(
          (key, value) =>
              MapEntry(key as String, value is List ? value.length : 0),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_records': totalRecords,
      'state_heatmap': stateHeatmap,
      'top_clusters': topClusters.map((e) => e.toJson()).toList(),
      'recent_spikes': recentSpikes.map((e) => e.toJson()).toList(),
      'cluster_keywords': clusterKeywords,
    };
  }
}
