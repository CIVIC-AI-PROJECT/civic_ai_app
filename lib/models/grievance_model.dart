enum GrievanceStatus { new_, inProgress, resolved, escalated }

enum GrievanceCategory {
  ration,
  pensions,
  landDisputes,
  fir,
  fertilizer,
  other,
}

class GrievanceModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? audioPath;
  final String? transcription;
  final GrievanceCategory category;
  final GrievanceStatus status;
  final String? extractedRight;
  final List<String>? documentChecklist;
  final String? officeName;
  final double? officeLat;
  final double? officeLng;
  final String? escalationScript;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GrievanceModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.audioPath,
    this.transcription,
    required this.category,
    required this.status,
    this.extractedRight,
    this.documentChecklist,
    this.officeName,
    this.officeLat,
    this.officeLng,
    this.escalationScript,
    required this.createdAt,
    this.updatedAt,
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    return GrievanceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      audioPath: json['audioPath'] as String?,
      transcription: json['transcription'] as String?,
      category: GrievanceCategory.values[json['category'] as int? ?? 0],
      status: GrievanceStatus.values[json['status'] as int? ?? 0],
      extractedRight: json['extractedRight'] as String?,
      documentChecklist: (json['documentChecklist'] as List<dynamic>?)
          ?.cast<String>(),
      officeName: json['officeName'] as String?,
      officeLat: (json['officeLat'] as num?)?.toDouble(),
      officeLng: (json['officeLng'] as num?)?.toDouble(),
      escalationScript: json['escalationScript'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'audioPath': audioPath,
    'transcription': transcription,
    'category': category.index,
    'status': status.index,
    'extractedRight': extractedRight,
    'documentChecklist': documentChecklist,
    'officeName': officeName,
    'officeLat': officeLat,
    'officeLng': officeLng,
    'escalationScript': escalationScript,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  GrievanceModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? audioPath,
    String? transcription,
    GrievanceCategory? category,
    GrievanceStatus? status,
    String? extractedRight,
    List<String>? documentChecklist,
    String? officeName,
    double? officeLat,
    double? officeLng,
    String? escalationScript,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GrievanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      audioPath: audioPath ?? this.audioPath,
      transcription: transcription ?? this.transcription,
      category: category ?? this.category,
      status: status ?? this.status,
      extractedRight: extractedRight ?? this.extractedRight,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      officeName: officeName ?? this.officeName,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
      escalationScript: escalationScript ?? this.escalationScript,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
