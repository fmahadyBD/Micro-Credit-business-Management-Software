// lib/models/shareholder_model.dart
class ShareholderModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String nidCard;
  final String nominee;
  final String zila;
  final String house;
  final double investment;
  final int totalShare;
  final double totalEarning;
  final double currentBalance;
  final String role;
  final String status;
  final DateTime joinDate;
  final double roi;
  final double totalValue;

  ShareholderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nidCard,
    required this.nominee,
    required this.zila,
    required this.house,
    required this.investment,
    required this.totalShare,
    required this.totalEarning,
    required this.currentBalance,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.roi,
    required this.totalValue,
  });

  factory ShareholderModel.fromJson(Map<String, dynamic> json) {
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

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
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
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return ShareholderModel(
      id: parseId(json['id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
      nidCard: parseString(json['nidCard']),
      nominee: parseString(json['nominee']),
      zila: parseString(json['zila']),
      house: parseString(json['house']),
      investment: parseDouble(json['investment']),
      totalShare: parseInt(json['totalShare']),
      totalEarning: parseDouble(json['totalEarning']),
      currentBalance: parseDouble(json['currentBalance']),
      role: parseString(json['role']),
      status: parseString(json['status']),
      joinDate: parseDateTime(json['joinDate']),
      roi: parseDouble(json['roi']),
      totalValue: parseDouble(json['totalValue']),
    );
  }

  Map<String, dynamic> toJson({bool forCreate = false}) {
    final json = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'nidCard': nidCard,
      'nominee': nominee,
      'zila': zila,
      'house': house,
      'investment': investment,
      'role': role,
      'status': status,
      'joinDate': joinDate.toIso8601String().split('T')[0],
      // ✅ ALWAYS include these fields with proper defaults
      'totalShare': totalShare,
      'totalEarning': totalEarning,
      'currentBalance': currentBalance,
    };

    // Only include these fields for updates (non-create operations)
    if (!forCreate) {
      json['id'] = id;
      json['roi'] = roi;
      json['totalValue'] = totalValue;
    }

    return json;
  }

  String getFormattedJoinDate() {
    return '${joinDate.day.toString().padLeft(2, '0')}/${joinDate.month.toString().padLeft(2, '0')}/${joinDate.year}';
  }

  String getFormattedInvestment() {
    return '৳${investment.toStringAsFixed(2)}';
  }

  String getFormattedTotalValue() {
    return '৳${totalValue.toStringAsFixed(2)}';
  }

  String getFormattedBalance() {
    return '৳${currentBalance.toStringAsFixed(2)}';
  }

  ShareholderModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? nidCard,
    String? nominee,
    String? zila,
    String? house,
    double? investment,
    int? totalShare,
    double? totalEarning,
    double? currentBalance,
    String? role,
    String? status,
    DateTime? joinDate,
    double? roi,
    double? totalValue,
  }) {
    return ShareholderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nidCard: nidCard ?? this.nidCard,
      nominee: nominee ?? this.nominee,
      zila: zila ?? this.zila,
      house: house ?? this.house,
      investment: investment ?? this.investment,
      totalShare: totalShare ?? this.totalShare,
      totalEarning: totalEarning ?? this.totalEarning,
      currentBalance: currentBalance ?? this.currentBalance,
      role: role ?? this.role,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      roi: roi ?? this.roi,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}