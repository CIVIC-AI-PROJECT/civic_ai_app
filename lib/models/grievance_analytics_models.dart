// Models for Grievance Analytics Endpoints

class GrievanceCluster {
  final String id;
  final String category;
  final int count;
  final List<String> keywords;
  final double latitude;
  final double longitude;
  final String region;

  GrievanceCluster({
    required this.id,
    required this.category,
    required this.count,
    required this.keywords,
    required this.latitude,
    required this.longitude,
    required this.region,
  });

  factory GrievanceCluster.fromJson(Map<String, dynamic> json) {
    return GrievanceCluster(
      id: json['id'] as String,
      category: json['category'] as String,
      count: json['count'] as int,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      region: json['region'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'count': count,
      'keywords': keywords,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
    };
  }
}

class GrievanceAnomaly {
  final String id;
  final String category;
  final String description;
  final double anomalyScore;
  final DateTime detectedAt;
  final String region;
  final String severity;

  GrievanceAnomaly({
    required this.id,
    required this.category,
    required this.description,
    required this.anomalyScore,
    required this.detectedAt,
    required this.region,
    required this.severity,
  });

  factory GrievanceAnomaly.fromJson(Map<String, dynamic> json) {
    return GrievanceAnomaly(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      anomalyScore: (json['anomaly_score'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detected_at'] as String),
      region: json['region'] as String,
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'anomaly_score': anomalyScore,
      'detected_at': detectedAt.toIso8601String(),
      'region': region,
      'severity': severity,
    };
  }
}

class HeatmapDataPoint {
  final double latitude;
  final double longitude;
  final int intensity;
  final String category;

  HeatmapDataPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.category,
  });

  factory HeatmapDataPoint.fromJson(Map<String, dynamic> json) {
    return HeatmapDataPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      intensity: json['intensity'] as int,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'intensity': intensity,
      'category': category,
    };
  }
}

class RecentSpike {
  final String category;
  final String region;
  final int count;
  final double percentageIncrease;
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  RecentSpike({
    required this.category,
    required this.region,
    required this.count,
    required this.percentageIncrease,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory RecentSpike.fromJson(Map<String, dynamic> json) {
    return RecentSpike(
      category: json['category'] as String,
      region: json['region'] as String,
      count: json['count'] as int,
      percentageIncrease: (json['percentage_increase'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'region': region,
      'count': count,
      'percentage_increase': percentageIncrease,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'description': description,
    };
  }
}

class IntelligenceDashboard {
  final DashboardStats stats;
  final List<GrievanceCluster> topClusters;
  final List<RecentSpike> recentSpikes;
  final List<GrievanceAnomaly> anomalies;
  final Map<String, int> categoryDistribution;
  final Map<String, double> resolutionRates;

  IntelligenceDashboard({
    required this.stats,
    required this.topClusters,
    required this.recentSpikes,
    required this.anomalies,
    required this.categoryDistribution,
    required this.resolutionRates,
  });

  factory IntelligenceDashboard.fromJson(Map<String, dynamic> json) {
    return IntelligenceDashboard(
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
      topClusters: (json['top_clusters'] as List<dynamic>)
          .map((e) => GrievanceCluster.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSpikes: (json['recent_spikes'] as List<dynamic>)
          .map((e) => RecentSpike.fromJson(e as Map<String, dynamic>))
          .toList(),
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => GrievanceAnomaly.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryDistribution: Map<String, int>.from(
        json['category_distribution'] as Map,
      ),
      resolutionRates: (json['resolution_rates'] as Map).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'top_clusters': topClusters.map((e) => e.toJson()).toList(),
      'recent_spikes': recentSpikes.map((e) => e.toJson()).toList(),
      'anomalies': anomalies.map((e) => e.toJson()).toList(),
      'category_distribution': categoryDistribution,
      'resolution_rates': resolutionRates,
    };
  }
}

class DashboardStats {
  final int totalGrievances;
  final int activeGrievances;
  final int resolvedGrievances;
  final double averageResolutionTime;
  final int totalClusters;
  final int totalAnomalies;

  DashboardStats({
    required this.totalGrievances,
    required this.activeGrievances,
    required this.resolvedGrievances,
    required this.averageResolutionTime,
    required this.totalClusters,
    required this.totalAnomalies,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalGrievances: json['total_grievances'] as int,
      activeGrievances: json['active_grievances'] as int,
      resolvedGrievances: json['resolved_grievances'] as int,
      averageResolutionTime: (json['average_resolution_time'] as num)
          .toDouble(),
      totalClusters: json['total_clusters'] as int,
      totalAnomalies: json['total_anomalies'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_grievances': totalGrievances,
      'active_grievances': activeGrievances,
      'resolved_grievances': resolvedGrievances,
      'average_resolution_time': averageResolutionTime,
      'total_clusters': totalClusters,
      'total_anomalies': totalAnomalies,
    };
  }
}
