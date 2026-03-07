import 'package:flutter/material.dart';
import 'package:civic_ai_app/core/services/grievance_analytics_service.dart';
import 'package:civic_ai_app/models/grievance_analytics_models.dart';

class IntelligenceDashboardViewModel extends ChangeNotifier {
  final GrievanceAnalyticsService _analyticsService;

  IntelligenceDashboard? _dashboard;
  List<GrievanceCluster> _clusters = [];
  List<GrievanceAnomaly> _anomalies = [];
  List<HeatmapDataPoint> _heatmapData = [];
  List<RecentSpike> _recentSpikes = [];
  bool _isLoading = false;
  String? _errorMessage;

  IntelligenceDashboard? get dashboard => _dashboard;
  List<GrievanceCluster> get clusters => _clusters;
  List<GrievanceAnomaly> get anomalies => _anomalies;
  List<HeatmapDataPoint> get heatmapData => _heatmapData;
  List<RecentSpike> get recentSpikes => _recentSpikes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  IntelligenceDashboardViewModel({GrievanceAnalyticsService? analyticsService})
    : _analyticsService = analyticsService ?? GrievanceAnalyticsService();

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _analyticsService.getIntelligenceDashboard();

      // Extract data from dashboard
      _clusters = _dashboard!.topClusters;
      _anomalies = _dashboard!.anomalies;
      _recentSpikes = _dashboard!.recentSpikes;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClusters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clusters = await _analyticsService.getClusters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load clusters: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnomalies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _anomalies = await _analyticsService.getAnomalies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load anomalies: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHeatmapData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _heatmapData = await _analyticsService.getHeatmapData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load heatmap data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentSpikes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recentSpikes = await _analyticsService.getRecentSpikes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load recent spikes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadDashboard(), loadHeatmapData()]);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _dashboard = null;
    _clusters = [];
    _anomalies = [];
    _heatmapData = [];
    _recentSpikes = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
