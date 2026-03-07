import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:civic_ai_app/core/services/form_processing_service.dart';
import 'package:civic_ai_app/models/form_extract_models.dart';

class FormFillerViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final FormProcessingService _formService;

  String? _aadharPath;
  String? _ratioCardPath;
  String? _otherDocPath;
  bool _isProcessing = false;
  FormExtractResponse? _extractedData;
  ImageValidationResponse? _validationResult;
  String? _errorMessage;

  String? get aadharPath => _aadharPath;
  String? get ratioCardPath => _ratioCardPath;
  String? get otherDocPath => _otherDocPath;
  bool get isProcessing => _isProcessing;
  FormExtractResponse? get extractedData => _extractedData;
  ImageValidationResponse? get validationResult => _validationResult;
  String? get errorMessage => _errorMessage;

  FormFillerViewModel({FormProcessingService? formService})
    : _formService = formService ?? FormProcessingService();

  Future<void> captureDocument({required String documentType}) async {
    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image != null) {
        switch (documentType) {
          case 'aadhar':
            _aadharPath = image.path;
            break;
          case 'ratiocard':
            _ratioCardPath = image.path;
            break;
          case 'other':
            _otherDocPath = image.path;
            break;
        }

        // Validate and process image
        await validateDocumentQuality(image.path);
        if (_validationResult?.isValid == true) {
          await _processImageWithVision(image.path, documentType);
        }
      }

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to capture document: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _processImageWithVision(
    String imagePath,
    String documentType,
  ) async {
    try {
      final imageFile = File(imagePath);
      _extractedData = await _formService.extractForm(imageFile);

      if (_extractedData!.errorMessage != null) {
        _errorMessage = _extractedData!.errorMessage;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to process image: $e';
      notifyListeners();
    }
  }

  Future<void> validateDocumentQuality(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      _validationResult = await _formService.validateImage(imageFile);

      if (!_validationResult!.isValid) {
        _errorMessage =
            'Document quality is poor: ${_validationResult!.issues.join(", ")}. Please retake the photo.';
      } else if (_validationResult!.quality < 0.75) {
        _errorMessage =
            'Document quality is low (${(_validationResult!.quality * 100).toStringAsFixed(0)}%). Please retake with better lighting.';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Quality check failed: $e';
      _validationResult = null;
      notifyListeners();
    }
  }

  Future<String> generateFilledPDF() async {
    try {
      if (_extractedData == null) {
        _errorMessage = 'No extracted data to generate PDF';
        return '';
      }

      // In production, implement actual PDF generation with extracted data
      await Future.delayed(const Duration(seconds: 1));
      return 'filled_form_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e) {
      _errorMessage = 'Failed to generate form: $e';
      return '';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _aadharPath = null;
    _ratioCardPath = null;
    _otherDocPath = null;
    _isProcessing = false;
    _extractedData = null;
    _validationResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
