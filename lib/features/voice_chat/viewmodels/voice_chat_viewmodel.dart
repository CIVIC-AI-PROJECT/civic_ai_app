import 'package:flutter/material.dart';
import 'dart:async';
import 'package:civic_ai_app/models/grievance_model.dart';
import 'package:civic_ai_app/core/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceChatViewModel extends ChangeNotifier {
  final AudioService _audioService;

  bool _isRecording = false;
  String _transcribedText = '';
  String? _extractedRight;
  List<String>? _documentChecklist;
  bool _isLoading = false;
  GrievanceModel? _currentGrievance;

  bool get isRecording => _isRecording;
  String get transcribedText => _transcribedText;
  String? get extractedRight => _extractedRight;
  List<String>? get documentChecklist => _documentChecklist;
  bool get isLoading => _isLoading;
  GrievanceModel? get currentGrievance => _currentGrievance;

  VoiceChatViewModel({required AudioService audioService})
    : _audioService = audioService;

  Future<void> initializeAudio() async {
    await _audioService.initializeSpeech();
    await _audioService.initializeTts();
  }

  Future<void> startRecording({
    required String languageCode,
    required String userId,
  }) async {
    _isRecording = true;
    notifyListeners();

    await _audioService.startListening(
      languageCode: languageCode,
      onResult: (text) {
        _transcribedText = text;
        _isRecording = false;
        notifyListeners();
        unawaited(_processGrievance(text, userId));
      },
    );
  }

  Future<void> stopRecording() async {
    await _audioService.stopListening();
    _isRecording = false;
    notifyListeners();
  }

  Future<void> _processGrievance(String description, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call to process grievance
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - In production, this would come from your AI backend
      _currentGrievance = GrievanceModel(
        id: 'grv_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: 'Grievance from voice input',
        description: description,
        transcription: description,
        category: _detectCategory(description),
        status: GrievanceStatus.new_,
        extractedRight: _generateMockRight(description),
        documentChecklist: _generateMockDocuments(),
        createdAt: DateTime.now(),
      );

      _extractedRight = _currentGrievance!.extractedRight;
      _documentChecklist = _currentGrievance!.documentChecklist;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error processing grievance: $e');
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

  String _generateMockRight(String description) {
    final category = _detectCategory(description);
    switch (category) {
      case GrievanceCategory.ration:
        return 'You have the right to receive your ration quota as per the Public Distribution System (PDS). If you are denied ration due to biometric mismatch, you can file a complaint with the District Collector.';
      case GrievanceCategory.pensions:
        return 'You are entitled to receive your pension on the scheduled date. If there is a delay, you can escalate to the Pension Disbursement Authority.';
      case GrievanceCategory.landDisputes:
        return 'Land rights are protected under Indian law. You can file a dispute with the District Land Records Office.';
      case GrievanceCategory.fir:
        return 'You have the right to file an FIR for any criminal offense. Visit the nearest police station with relevant documents.';
      case GrievanceCategory.fertilizer:
        return 'Farmers are entitled to subsidized fertilizers. Contact your block agricultural office if facing shortage.';
      case GrievanceCategory.other:
        return 'Your grievance has been noted. Please provide more details for better assistance.';
    }
  }

  List<String> _generateMockDocuments() {
    return ['Aadhar Card', 'Bank Passbook', 'Photo Identity', 'Address Proof'];
  }

  Future<void> playResponse(String text, String languageCode) async {
    await _audioService.speak(text, languageCode: languageCode);
  }

  Future<void> saveGrievance() async {
    if (_currentGrievance == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> grievances = prefs.getStringList('grievances') ?? [];
      grievances.add(_currentGrievance!.toJson().toString());
      await prefs.setStringList('grievances', grievances);
    } catch (e) {
      print('Error saving grievance: $e');
    }
  }

  void reset() {
    _isRecording = false;
    _transcribedText = '';
    _extractedRight = null;
    _documentChecklist = null;
    _isLoading = false;
    _currentGrievance = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
