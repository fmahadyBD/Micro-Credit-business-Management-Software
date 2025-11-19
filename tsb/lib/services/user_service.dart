import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/users';
  final AuthService _authService = AuthService();

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  /// Get user by ID
  Future<UserModel> getUserById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  /// Update user (with optional password change)
  Future<UserModel> updateUser(
    int id,
    String firstname,
    String lastname,
    String username,
    String role,
    String status, {
    String? password, // Optional password parameter
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build the request body
      final Map<String, dynamic> requestBody = {
        'firstname': firstname,
        'lastname': lastname,
        'username': username,
        'role': role,
        'status': status,
      };

      // Only include password if it's provided and not empty
      if (password != null && password.isNotEmpty) {
        requestBody['password'] = password;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  /// Update user status
  Future<UserModel> updateUserStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }
}