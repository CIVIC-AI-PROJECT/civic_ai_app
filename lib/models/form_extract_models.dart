// Models for Form Extraction and Image Validation

class FormExtractResponse {
  final String formType;
  final Map<String, dynamic> extractedFields;
  final double confidence;
  final List<String> missingFields;
  final String? errorMessage;

  FormExtractResponse({
    required this.formType,
    required this.extractedFields,
    required this.confidence,
    required this.missingFields,
    this.errorMessage,
  });

  factory FormExtractResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure and errors
    final data = json['data'] as Map<String, dynamic>? ?? json;

    // Check for error in response
    String? errorMsg;
    if (data.containsKey('error')) {
      final error = data['error'];
      if (error is Map) {
        final errorDetail = error['error'] as Map?;
        if (errorDetail != null) {
          errorMsg = '${errorDetail['message'] ?? 'Unknown error'}';
        }
      }
    }

    return FormExtractResponse(
      formType: data['form_type'] as String? ?? 'unknown',
      extractedFields: Map<String, dynamic>.from(
        data['extracted_fields'] as Map? ?? {},
      ),
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      missingFields:
          (data['missing_fields'] as List<dynamic>?)?.cast<String>() ?? [],
      errorMessage: errorMsg ?? json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_type': formType,
      'extracted_fields': extractedFields,
      'confidence': confidence,
      'missing_fields': missingFields,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}

class ImageValidationResponse {
  final bool isBlurry;
  final double blurScore;
  final double thresholdUsed;
  final String? errorMessage;

  bool get isValid => !isBlurry;

  double get quality {
    if (thresholdUsed <= 0) {
      return 1.0;
    }
    final normalized = blurScore / thresholdUsed;
    if (normalized < 0) {
      return 0.0;
    }
    if (normalized > 1) {
      return 1.0;
    }
    return normalized;
  }

  List<String> get issues => isBlurry ? ['Image is blurry & not in defined borders'] : const [];

  ImageValidationResponse({
    required this.isBlurry,
    required this.blurScore,
    required this.thresholdUsed,
    this.errorMessage,
  });

  factory ImageValidationResponse.fromJson(Map<String, dynamic> json) {
    // Handle the nested 'data' structure from the API
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return ImageValidationResponse(
      isBlurry:
          data['is_blurry'] as bool? ?? !(data['is_valid'] as bool? ?? true),
      blurScore:
          (data['blur_score'] as num?)?.toDouble() ??
          (((data['quality'] as num?)?.toDouble() ?? 0.0) *
              ((data['threshold_used'] as num?)?.toDouble() ?? 800.0)),
      thresholdUsed: (data['threshold_used'] as num?)?.toDouble() ?? 800.0,
      errorMessage:
          json['error_message'] as String? ?? json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_blurry': isBlurry,
      'blur_score': blurScore,
      'threshold_used': thresholdUsed,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}
