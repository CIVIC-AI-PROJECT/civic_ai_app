enum Persona { farmer, worker, student, senior }

enum Language { english, hindi, telugu, tamil, kannada, marathi }

class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String state;
  final String district;
  final Persona persona;
  final Language preferredLanguage;
  final String? aadharNumber;
  final String? ratioCardNumber;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.state,
    required this.district,
    required this.persona,
    required this.preferredLanguage,
    this.aadharNumber,
    this.ratioCardNumber,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      persona: Persona.values[json['persona'] as int? ?? 0],
      preferredLanguage:
          Language.values[json['preferredLanguage'] as int? ?? 0],
      aadharNumber: json['aadharNumber'] as String?,
      ratioCardNumber: json['ratioCardNumber'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'state': state,
    'district': district,
    'persona': persona.index,
    'preferredLanguage': preferredLanguage.index,
    'aadharNumber': aadharNumber,
    'ratioCardNumber': ratioCardNumber,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? state,
    String? district,
    Persona? persona,
    Language? preferredLanguage,
    String? aadharNumber,
    String? ratioCardNumber,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      state: state ?? this.state,
      district: district ?? this.district,
      persona: persona ?? this.persona,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      ratioCardNumber: ratioCardNumber ?? this.ratioCardNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
