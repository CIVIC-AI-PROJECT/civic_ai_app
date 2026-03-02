import 'package:flutter/material.dart';
import 'package:civic_ai_app/models/grievance_model.dart';
import 'package:civic_ai_app/models/office_model.dart';
import 'package:geolocator/geolocator.dart';

class ActionCenterViewModel extends ChangeNotifier {
  GrievanceModel? _grievance;
  OfficeModel? _nearestOffice;
  bool _isLoading = false;
  List<String> _documentStatus = [];
  String? _errorMessage;

  GrievanceModel? get grievance => _grievance;
  OfficeModel? get nearestOffice => _nearestOffice;
  bool get isLoading => _isLoading;
  List<String> get documentStatus => _documentStatus;
  String? get errorMessage => _errorMessage;

  void setGrievance(GrievanceModel grievance) {
    _grievance = grievance;
    _documentStatus = grievance.documentChecklist ?? [];
    notifyListeners();
  }

  Future<void> findNearestOffice({
    required double latitude,
    required double longitude,
    required String state,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mock nearest office - in production, this would make an API call
      _nearestOffice = OfficeModel(
        id: 'office_001',
        name: 'District Grievance Redressal Center',
        officerName: 'Shri Rajesh Kumar',
        phoneNumber: '+91-9876543210',
        address: '123 Government Plaza, $state',
        state: state,
        district: 'Central District',
        latitude: latitude + 0.05,
        longitude: longitude + 0.05,
        type: OfficeType.collectorate,
        hoursOfOperation: '9:00 AM - 5:00 PM (Monday to Friday)',
        requiredDocuments: _grievance?.documentChecklist ?? [],
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to find nearest office: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await findNearestOffice(
        latitude: position.latitude,
        longitude: position.longitude,
        state: _grievance?.userId ?? 'Unknown',
      );
    } catch (e) {
      _errorMessage = 'Unable to get location: $e';
      notifyListeners();
    }
  }

  void updateDocumentStatus(String document, bool isCollected) {
    final index = _documentStatus.indexOf(document);
    if (index != -1) {
      // In a real app, you might use a Map<String, bool> for document status
      notifyListeners();
    }
  }

  Future<String> generatePDF() async {
    if (_grievance == null) {
      _errorMessage = 'No grievance to generate PDF';
      return '';
    }

    try {
      // Mock PDF generation - in production, use pdf package
      await Future.delayed(const Duration(seconds: 2));
      return 'grievance_${_grievance!.id}.pdf';
    } catch (e) {
      _errorMessage = 'Failed to generate PDF: $e';
      return '';
    }
  }

  Future<void> callOffice() async {
    if (_nearestOffice == null) {
      _errorMessage = 'No office information available';
      return;
    }
    // In production, use url_launcher to make actual phone call
    // await launch('tel:${_nearestOffice!.phoneNumber}');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
