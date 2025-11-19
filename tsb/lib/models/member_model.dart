// lib/models/member_model.dart
class MemberModel {
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
  final String status;
  final List<dynamic> agents;
  final List<dynamic> installments;

  MemberModel({
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
    required this.status,
    required this.agents,
    required this.installments,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
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
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value.toString();
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          // Handle Java LocalDate format (yyyy-MM-dd)
          if (!value.contains('T') && !value.contains(' ')) {
            final parts = value.split('-');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
            }
          }
          // Handle ISO 8601 format
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date: $value, error: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    List<dynamic> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value;
      return [];
    }

    return MemberModel(
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
      status: parseString(json['status']),
      agents: parseList(json['agents']),
      installments: parseList(json['installments']),
    );
  }

  Map<String, dynamic> toJson({bool forCreate = false}) {
    final json = <String, dynamic>{
      'name': name,
      'phone': phone,
      'zila': zila,
      'village': village,
      'nidCardNumber': nidCardNumber,
      'nomineeName': nomineeName,
      'nomineePhone': nomineePhone,
      'nomineeNidCardNumber': nomineeNidCardNumber,
      'status': status,
    };

    if (!forCreate) {
      json['id'] = id;

      if (nidCardImagePath != null) {
        json['nidCardImagePath'] = nidCardImagePath!;
      }
      if (photoPath != null) json['photoPath'] = photoPath!;
      if (nomineeNidCardImagePath != null) {
        json['nomineeNidCardImagePath'] = nomineeNidCardImagePath!;
      }

      // 🧹 Clean installments before sending
      if (installments.isNotEmpty) {
        json['installments'] = installments.map((e) {
          final map = Map<String, dynamic>.from(e);
          map.remove('createdTime'); // remove Java LocalDateTime field
          return map;
        }).toList();
      }

      if (agents.isNotEmpty) json['agents'] = agents;
    }

    return json;
  }

  String getFormattedJoinDate() {
    return '${joinDate.day.toString().padLeft(2, '0')}/${joinDate.month.toString().padLeft(2, '0')}/${joinDate.year}';
  }

  // Copy with method for updates
  MemberModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? zila,
    String? village,
    String? nidCardNumber,
    String? nidCardImagePath,
    String? photoPath,
    String? nomineeName,
    String? nomineePhone,
    String? nomineeNidCardNumber,
    String? nomineeNidCardImagePath,
    DateTime? joinDate,
    String? status,
    List<dynamic>? agents,
    List<dynamic>? installments,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      zila: zila ?? this.zila,
      village: village ?? this.village,
      nidCardNumber: nidCardNumber ?? this.nidCardNumber,
      nidCardImagePath: nidCardImagePath ?? this.nidCardImagePath,
      photoPath: photoPath ?? this.photoPath,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineePhone: nomineePhone ?? this.nomineePhone,
      nomineeNidCardNumber: nomineeNidCardNumber ?? this.nomineeNidCardNumber,
      nomineeNidCardImagePath:
          nomineeNidCardImagePath ?? this.nomineeNidCardImagePath,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      agents: agents ?? this.agents,
      installments: installments ?? this.installments,
    );
  }
}
