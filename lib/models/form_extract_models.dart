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
    return FormExtractResponse(
      formType: json['form_type'] as String? ?? 'unknown',
      extractedFields: Map<String, dynamic>.from(
        json['extracted_fields'] as Map? ?? {},
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      missingFields:
          (json['missing_fields'] as List<dynamic>?)?.cast<String>() ?? [],
      errorMessage: json['error_message'] as String?,
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
  final bool isValid;
  final double quality;
  final List<String> issues;
  final ImageValidationDetails details;
  final String? errorMessage;

  ImageValidationResponse({
    required this.isValid,
    required this.quality,
    required this.issues,
    required this.details,
    this.errorMessage,
  });

  factory ImageValidationResponse.fromJson(Map<String, dynamic> json) {
    return ImageValidationResponse(
      isValid: json['is_valid'] as bool? ?? false,
      quality: (json['quality'] as num?)?.toDouble() ?? 0.0,
      issues: (json['issues'] as List<dynamic>?)?.cast<String>() ?? [],
      details: ImageValidationDetails.fromJson(
        json['details'] as Map<String, dynamic>? ?? {},
      ),
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'quality': quality,
      'issues': issues,
      'details': details.toJson(),
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}

class ImageValidationDetails {
  final double brightness;
  final double sharpness;
  final bool hasText;
  final String? orientation;
  final int? width;
  final int? height;

  ImageValidationDetails({
    required this.brightness,
    required this.sharpness,
    required this.hasText,
    this.orientation,
    this.width,
    this.height,
  });

  factory ImageValidationDetails.fromJson(Map<String, dynamic> json) {
    return ImageValidationDetails(
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      sharpness: (json['sharpness'] as num?)?.toDouble() ?? 0.0,
      hasText: json['has_text'] as bool? ?? false,
      orientation: json['orientation'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'sharpness': sharpness,
      'has_text': hasText,
      if (orientation != null) 'orientation': orientation,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }
}
