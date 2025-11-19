// lib/models/member_model.dart
class MemberModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? zila;
  final String? village;
  final String? nidCard;
  final String? nominee;
  final String? role;
  final String? status;
  final String? photo;
  final DateTime? joinDate;

  MemberModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.zila,
    this.village,
    this.nidCard,
    this.nominee,
    this.role,
    this.status,
    this.photo,
    this.joinDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      zila: json['zila'],
      village: json['village'],
      nidCard: json['nidCard'],
      nominee: json['nominee'],
      role: json['role'],
      status: json['status'],
      photo: json['photo'],
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (zila != null) 'zila': zila,
      if (village != null) 'village': village,
      if (nidCard != null) 'nidCard': nidCard,
      if (nominee != null) 'nominee': nominee,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (photo != null) 'photo': photo,
      if (joinDate != null) 'joinDate': joinDate!.toIso8601String(),
    };
  }
}