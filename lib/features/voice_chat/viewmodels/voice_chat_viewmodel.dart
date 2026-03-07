import 'package:flutter/material.dart';
import 'dart:async';
import 'package:civic_ai_app/models/grievance_model.dart';
import 'package:civic_ai_app/models/civic_assist_response.dart';
import 'package:civic_ai_app/core/services/audio_service.dart';
import 'package:civic_ai_app/core/services/civic_assist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class VoiceChatViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final CivicAssistService _civicAssistService;

  bool _isRecording = false;
  String _transcribedText = '';
  String? _extractedRight;
  List<String>? _documentChecklist;
  List<String>? _checklistSteps;
  bool _isLoading = false;
  String? _errorMessage;
  GrievanceModel? _currentGrievance;
  CivicAssistResponse? _assistResponse;

  bool get isRecording => _isRecording;
  String get transcribedText => _transcribedText;
  String? get extractedRight => _extractedRight;
  List<String>? get documentChecklist => _documentChecklist;
  List<String>? get checklistSteps => _checklistSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GrievanceModel? get currentGrievance => _currentGrievance;
  CivicAssistResponse? get assistResponse => _assistResponse;

  VoiceChatViewModel({
    required AudioService audioService,
    CivicAssistService? civicAssistService,
  }) : _audioService = audioService,
       _civicAssistService = civicAssistService ?? CivicAssistService();

  Future<void> initializeAudio() async {
    await _audioService.initializeSpeech();
    await _audioService.initializeTts();
  }

  Future<void> startRecording({
    required String languageCode,
    required String userId,
    required String city,
  }) async {
    _isRecording = true;
    _errorMessage = null;
    notifyListeners();

    await _audioService.startListening(
      languageCode: languageCode,
      onResult: (text) {
        _transcribedText = text;
        _isRecording = false;
        notifyListeners();
        unawaited(_processGrievance(text, userId, city));
      },
    );
  }

  Future<void> stopRecording() async {
    await _audioService.stopListening();
    _isRecording = false;
    notifyListeners();
  }

  Future<void> _processGrievance(
    String description,
    String userId,
    String city,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      Position? position;
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

      // Call Civic Assist API
      _assistResponse = await _civicAssistService.getOfficeRecommendation(
        problem: description,
        city: city,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Create grievance model from response
      _currentGrievance = GrievanceModel(
        id: 'grv_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title:
            'Grievance: ${description.length > 30 ? description.substring(0, 30) + "..." : description}',
        description: description,
        transcription: description,
        category: _detectCategory(description),
        status: GrievanceStatus.new_,
        extractedRight: _assistResponse!.conversationScript.opening,
        documentChecklist: _assistResponse!.checklist.documents,
        officeName: _assistResponse!.recommendedOffice.name,
        officeLat: position.latitude,
        officeLng: position.longitude,
        escalationScript: _assistResponse!.conversationScript.followUps.join(
          '\n',
        ),
        createdAt: DateTime.now(),
      );

      _extractedRight = _assistResponse!.recommendedOffice.explanation;
      _documentChecklist = _assistResponse!.checklist.documents;
      _checklistSteps = _assistResponse!.checklist.steps;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to process grievance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  GrievanceCategory _detectCategory(String text) {
    text = text.toLowerCase();
    if (text.contains('ration') || text.contains('pds')) {
      return GrievanceCategory.ration;
    } else if (text.contains('pension')) {
      return GrievanceCategory.pensions;
    } else if (text.contains('land')) {
      return GrievanceCategory.landDisputes;
    } else if (text.contains('fir') || text.contains('police')) {
      return GrievanceCategory.fir;
    } else if (text.contains('fertilizer')) {
      return GrievanceCategory.fertilizer;
    } else {
      return GrievanceCategory.other;
    }
  }

  /// Submit a typed problem (text input alternative to voice)
  Future<void> submitTextProblem({
    required String problem,
    required String userId,
    required String city,
  }) async {
    _transcribedText = problem;
    notifyListeners();
    await _processGrievance(problem, userId, city);
  }

  Future<void> playResponse(String text, String languageCode) async {
    await _audioService.speak(text, languageCode: languageCode);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> saveGrievance() async {
    if (_currentGrievance == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> grievances = prefs.getStringList('grievances') ?? [];
      grievances.add(_currentGrievance!.toJson().toString());
      await prefs.setStringList('grievances', grievances);
    } catch (e) {
      _errorMessage = 'Error saving grievance: $e';
      notifyListeners();
    }
  }

  void reset() {
    _isRecording = false;
    _transcribedText = '';
    _extractedRight = null;
    _documentChecklist = null;
    _isLoading = false;
    _errorMessage = null;
    _currentGrievance = null;
    _assistResponse = null;
    _checklistSteps = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
