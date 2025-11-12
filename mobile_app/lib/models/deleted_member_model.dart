// lib/models/deleted_member_model.dart
class DeletedMemberModel {
  final int id;
  final String name;
  final String phone;
  final String zila;
  final String village;
  final String nidCardNumber;
  final String? nidCardImagePath;
  final String? photoPath;
  final String nomineeName;
  final String nomineePhone;
  final String nomineeNidCardNumber;
  final String? nomineeNidCardImagePath;
  final DateTime joinDate;
  final DateTime deletedDate;

  DeletedMemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.zila,
    required this.village,
    required this.nidCardNumber,
    this.nidCardImagePath,
    this.photoPath,
    required this.nomineeName,
    required this.nomineePhone,
    required this.nomineeNidCardNumber,
    this.nomineeNidCardImagePath,
    required this.joinDate,
    required this.deletedDate,
  });

  factory DeletedMemberModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          try {
            if (value.contains('T') == false) {
              return DateTime.parse('${value}T00:00:00Z');
            }
            return DateTime.parse(value);
          } catch (e2) {
            return DateTime.now();
          }
        }
      }
      return DateTime.now();
    }

    return DeletedMemberModel(
      id: parseId(json['id']),
      name: parseString(json['name']),
      phone: parseString(json['phone']),
      zila: parseString(json['zila']),
      village: parseString(json['village']),
      nidCardNumber: parseString(json['nidCardNumber']),
      nidCardImagePath: json['nidCardImagePath']?.toString(),
      photoPath: json['photoPath']?.toString(),
      nomineeName: parseString(json['nomineeName']),
      nomineePhone: parseString(json['nomineePhone']),
      nomineeNidCardNumber: parseString(json['nomineeNidCardNumber']),
      nomineeNidCardImagePath: json['nomineeNidCardImagePath']?.toString(),
      joinDate: parseDateTime(json['joinDate']),
      deletedDate: parseDateTime(json['deletedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'zila': zila,
      'village': village,
      'nidCardNumber': nidCardNumber,
      'nidCardImagePath': nidCardImagePath,
      'photoPath': photoPath,
      'nomineeName': nomineeName,
      'nomineePhone': nomineePhone,
      'nomineeNidCardNumber': nomineeNidCardNumber,
      'nomineeNidCardImagePath': nomineeNidCardImagePath,
      'joinDate': joinDate.toIso8601String(),
      'deletedDate': deletedDate.toIso8601String(),
    };
  }
}