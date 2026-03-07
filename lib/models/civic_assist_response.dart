class CivicAssistResponse {
  final RecommendedOffice recommendedOffice;
  final List<AlternativeOffice> alternatives;
  final Checklist checklist;
  final ConversationScript conversationScript;
  final Privacy privacy;
  final Metadata metadata;

  CivicAssistResponse({
    required this.recommendedOffice,
    required this.alternatives,
    required this.checklist,
    required this.conversationScript,
    required this.privacy,
    required this.metadata,
  });

  factory CivicAssistResponse.fromJson(Map<String, dynamic> json) {
    return CivicAssistResponse(
      recommendedOffice: RecommendedOffice.fromJson(
        json['recommended_office'] as Map<String, dynamic>,
      ),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => AlternativeOffice.fromJson(e as Map<String, dynamic>))
          .toList(),
      checklist: Checklist.fromJson(json['checklist'] as Map<String, dynamic>),
      conversationScript: ConversationScript.fromJson(
        json['conversation_script'] as Map<String, dynamic>,
      ),
      privacy: Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_office': recommendedOffice.toJson(),
      'alternatives': alternatives.map((e) => e.toJson()).toList(),
      'checklist': checklist.toJson(),
      'conversation_script': conversationScript.toJson(),
      'privacy': privacy.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class RecommendedOffice {
  final String name;
  final String address;
  final double distanceKm;
  final String explanation;
  final String phone;
  final String hours;

  RecommendedOffice({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.explanation,
    required this.phone,
    required this.hours,
  });

  factory RecommendedOffice.fromJson(Map<String, dynamic> json) {
    return RecommendedOffice(
      name: json['name'] as String,
      address: json['address'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      explanation: json['explanation'] as String,
      phone: json['phone'] as String,
      hours: json['hours'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'distance_km': distanceKm,
      'explanation': explanation,
      'phone': phone,
      'hours': hours,
    };
  }
}

class AlternativeOffice {
  final String name;
  final String address;
  final double distanceKm;
  final String phone;
  final String hours;

  AlternativeOffice({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.phone,
    required this.hours,
  });

  factory AlternativeOffice.fromJson(Map<String, dynamic> json) {
    return AlternativeOffice(
      name: json['name'] as String,
      address: json['address'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      phone: json['phone'] as String,
      hours: json['hours'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'distance_km': distanceKm,
      'phone': phone,
      'hours': hours,
    };
  }
}

class Checklist {
  final List<String> documents;
  final List<String> steps;

  Checklist({required this.documents, required this.steps});

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      documents: (json['documents'] as List<dynamic>).cast<String>(),
      steps: (json['steps'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'documents': documents, 'steps': steps};
  }
}

class ConversationScript {
  final String opening;
  final List<String> followUps;

  ConversationScript({required this.opening, required this.followUps});

  factory ConversationScript.fromJson(Map<String, dynamic> json) {
    return ConversationScript(
      opening: json['opening'] as String,
      followUps: (json['follow_ups'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'opening': opening, 'follow_ups': followUps};
  }
}

class Privacy {
  final List<String> stored;
  final List<String> notStored;

  Privacy({required this.stored, required this.notStored});

  factory Privacy.fromJson(Map<String, dynamic> json) {
    return Privacy(
      stored: (json['stored'] as List<dynamic>).cast<String>(),
      notStored: (json['not_stored'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'stored': stored, 'not_stored': notStored};
  }
}

class Metadata {
  final String correlationId;
  final bool bedrockUsed;
  final double processingTimeMs;

  Metadata({
    required this.correlationId,
    required this.bedrockUsed,
    required this.processingTimeMs,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      correlationId: json['correlation_id'] as String,
      bedrockUsed: json['bedrock_used'] as bool,
      processingTimeMs: (json['processing_time_ms'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correlation_id': correlationId,
      'bedrock_used': bedrockUsed,
      'processing_time_ms': processingTimeMs,
    };
  }
}
