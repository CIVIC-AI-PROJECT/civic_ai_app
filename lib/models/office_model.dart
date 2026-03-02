enum OfficeType {
  pdsCenter,
  pensionOffice,
  landRecord,
  policeStation,
  collectorate,
}

class OfficeModel {
  final String id;
  final String name;
  final String officerName;
  final String phoneNumber;
  final String address;
  final String state;
  final String district;
  final double latitude;
  final double longitude;
  final OfficeType type;
  final String? hoursOfOperation;
  final List<String>? requiredDocuments;

  OfficeModel({
    required this.id,
    required this.name,
    required this.officerName,
    required this.phoneNumber,
    required this.address,
    required this.state,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.hoursOfOperation,
    this.requiredDocuments,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      officerName: json['officerName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: OfficeType.values[json['type'] as int? ?? 0],
      hoursOfOperation: json['hoursOfOperation'] as String?,
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'officerName': officerName,
    'phoneNumber': phoneNumber,
    'address': address,
    'state': state,
    'district': district,
    'latitude': latitude,
    'longitude': longitude,
    'type': type.index,
    'hoursOfOperation': hoursOfOperation,
    'requiredDocuments': requiredDocuments,
  };

  OfficeModel copyWith({
    String? id,
    String? name,
    String? officerName,
    String? phoneNumber,
    String? address,
    String? state,
    String? district,
    double? latitude,
    double? longitude,
    OfficeType? type,
    String? hoursOfOperation,
    List<String>? requiredDocuments,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      officerName: officerName ?? this.officerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      hoursOfOperation: hoursOfOperation ?? this.hoursOfOperation,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
    );
  }
}
