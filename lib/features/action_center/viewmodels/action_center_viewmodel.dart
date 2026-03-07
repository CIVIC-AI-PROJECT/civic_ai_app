import 'package:flutter/material.dart';
import 'package:civic_ai_app/models/grievance_model.dart';
import 'package:civic_ai_app/models/civic_assist_response.dart';
import 'package:civic_ai_app/core/services/civic_assist_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionCenterViewModel extends ChangeNotifier {
  final CivicAssistService _civicAssistService;

  GrievanceModel? _grievance;
  CivicAssistResponse? _assistResponse;
  RecommendedOffice? _recommendedOffice;
  List<AlternativeOffice> _alternativeOffices = [];
  bool _isLoading = false;
  List<String> _documentStatus = [];
  String? _errorMessage;

  GrievanceModel? get grievance => _grievance;
  CivicAssistResponse? get assistResponse => _assistResponse;
  RecommendedOffice? get recommendedOffice => _recommendedOffice;
  List<AlternativeOffice> get alternativeOffices => _alternativeOffices;
  bool get isLoading => _isLoading;
  List<String> get documentStatus => _documentStatus;
  String? get errorMessage => _errorMessage;

  ActionCenterViewModel({CivicAssistService? civicAssistService})
    : _civicAssistService = civicAssistService ?? CivicAssistService();

  void setGrievance(GrievanceModel grievance) {
    _grievance = grievance;
    _documentStatus = grievance.documentChecklist ?? [];
    notifyListeners();
  }

  void setAssistResponse(CivicAssistResponse response) {
    _assistResponse = response;
    _recommendedOffice = response.recommendedOffice;
    _alternativeOffices = response.alternatives;
    notifyListeners();
  }

  Future<void> findNearestOffice({
    required String problem,
    required String city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Use default coordinates if location access fails
        position = Position(
          latitude: 28.6139,
          longitude: 77.2090,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      // Call API to get office recommendation
      _assistResponse = await _civicAssistService.getOfficeRecommendation(
        problem: problem,
        city: city,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _recommendedOffice = _assistResponse!.recommendedOffice;
      _alternativeOffices = _assistResponse!.alternatives;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to find nearest office: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateDocumentStatus(String document, bool isCollected) {
    final index = _documentStatus.indexOf(document);
    if (index != -1) {
      // Implement document tracking logic
      notifyListeners();
    }
  }

  Future<void> callOffice() async {
    if (_recommendedOffice == null) {
      _errorMessage = 'No office selected';
      notifyListeners();
      return;
    }

    final phoneNumber = _recommendedOffice!.phone.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );
    final uri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _errorMessage = 'Cannot make phone calls on this device';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to initiate call: $e';
      notifyListeners();
    }
  }

  Future<void> openMaps() async {
    if (_recommendedOffice == null) {
      _errorMessage = 'No office selected';
      notifyListeners();
      return;
    }

    // Open in Google Maps with address
    final query = Uri.encodeComponent(_recommendedOffice!.address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _errorMessage = 'Cannot open maps on this device';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to open maps: $e';
      notifyListeners();
    }
  }

  Future<String> generatePDF() async {
    if (_grievance == null) {
      _errorMessage = 'No grievance to generate PDF';
      return '';
    }

    try {
      // In production, implement actual PDF generation
      await Future.delayed(const Duration(seconds: 1));
      return 'grievance_${_grievance!.id}.pdf';
    } catch (e) {
      _errorMessage = 'Failed to generate PDF: $e';
      return '';
    }
  }

  void reset() {
    _grievance = null;
    _assistResponse = null;
    _recommendedOffice = null;
    _alternativeOffices = [];
    _isLoading = false;
    _documentStatus = [];
    _errorMessage = null;
    notifyListeners();
  }
}
