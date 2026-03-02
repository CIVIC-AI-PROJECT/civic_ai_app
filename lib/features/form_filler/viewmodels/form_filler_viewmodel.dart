import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormFillerViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  String? _aadharPath;
  String? _ratioCardPath;
  String? _otherDocPath;
  bool _isProcessing = false;
  String? _extractedData;
  String? _errorMessage;

  String? get aadharPath => _aadharPath;
  String? get ratioCardPath => _ratioCardPath;
  String? get otherDocPath => _otherDocPath;
  bool get isProcessing => _isProcessing;
  String? get extractedData => _extractedData;
  String? get errorMessage => _errorMessage;

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

        // Process image with Vision AI
        await _processImageWithVision(image.path, documentType);
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
      // Mock Vision API processing
      // In production, integrate with Claude 3.5 Sonnet or Gemini Pro Vision
      await Future.delayed(const Duration(seconds: 2));

      _extractedData =
          '''
Document Type: ${documentType.toUpperCase()}
Extracted Fields:
- Name: John Doe
- Date of Birth: 15-05-1985
- Address: 123 Village Road, State, District
- Document Number: XXXX-XXXX-XXXX-1234
- Issue Date: 01-01-2020
- Validity: 31-12-2025
''';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to process image: $e';
      notifyListeners();
    }
  }

  Future<void> validateDocumentQuality(String imagePath) async {
    try {
      // Mock quality check using TensorFlow Lite edge model
      // In production, use tflite_flutter for on-device ML
      await Future.delayed(const Duration(seconds: 1));

      // Return quality metrics
      final qualityScore = 0.92; // Mock score out of 1.0
      if (qualityScore < 0.75) {
        _errorMessage =
            'Document quality is poor (blur/glare detected). Please retake the photo.';
      } else {
        _extractedData =
            'Document quality check passed. Score: ${(qualityScore * 100).toStringAsFixed(0)}%';
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Quality check failed: $e';
      notifyListeners();
    }
  }

  Future<String> generateFilledPDF() async {
    try {
      // Generate PDF with extracted data
      await Future.delayed(const Duration(seconds: 2));
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
    _errorMessage = null;
    notifyListeners();
  }
}
