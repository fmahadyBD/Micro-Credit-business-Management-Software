// lib/models/user_model.dart
class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String role;
  final String status;
  final int? referenceId;
  final DateTime createdDate;
  final DateTime lastModifiedDate;

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.role,
    required this.status,
    this.referenceId,
    required this.createdDate,
    required this.lastModifiedDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print the JSON to see what's coming from API
    print('User JSON: $json');
    
    // Safely parse each field with type checking
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
      if (value is List) {
        // If it's a list, take the first element or return empty
        return value.isNotEmpty ? value.first.toString() : '';
      }
      return value.toString();
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return UserModel(
      id: parseId(json['id']),
      firstname: parseString(json['firstname']),
      lastname: parseString(json['lastname']),
      username: parseString(json['username']),
      role: parseString(json['role']),
      status: parseString(json['status']),
      referenceId: json['referenceId'] != null ? parseId(json['referenceId']) : null,
      createdDate: parseDateTime(json['createdDate']),
      lastModifiedDate: parseDateTime(json['lastModifiedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'role': role,
      'status': status,
      'referenceId': referenceId,
      'createdDate': createdDate.toIso8601String(),
      'lastModifiedDate': lastModifiedDate.toIso8601String(),
    };
  }
}