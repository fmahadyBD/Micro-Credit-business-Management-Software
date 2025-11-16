// lib/models/agent_model.dart
class AgentModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String zila;
  final String village;
  final String nidCard;
  final String? photo;
  final String? nominee;
  final String role;
  final String status;
  final DateTime joinDate;

  AgentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.zila,
    required this.village,
    required this.nidCard,
    this.photo,
    this.nominee,
    required this.role,
    required this.status,
    required this.joinDate,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    // Handle different date formats
    DateTime parseJoinDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    return AgentModel(
      id: (json['id'] ?? 0).toInt(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      zila: json['zila'] ?? '',
      village: json['village'] ?? '',
      nidCard: json['nidCard'] ?? '',
      photo: json['photo'],
      nominee: json['nominee'],
      role: json['role'] ?? 'AGENT',
      status: json['status'] ?? 'ACTIVE',
      joinDate: parseJoinDate(json['joinDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'zila': zila,
      'village': village,
      'nidCard': nidCard,
      'photo': photo,
      'nominee': nominee,
      'role': role,
      'status': status,
      'joinDate': joinDate.toIso8601String(),
    };
  }
}