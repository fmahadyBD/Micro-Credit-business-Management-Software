// lib/services/member_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/member_model.dart';
import 'package:mobile_app/services/auth_service.dart';

class MemberService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/members';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all members
  Future<List<MemberModel>> getAllMembers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MemberModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  /// Get member by ID
  Future<MemberModel> getMemberById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return MemberModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching member: $e');
    }
  }

  /// Create new member
  Future<MemberModel> createMember(MemberModel member) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(member.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MemberModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating member: $e');
    }
  }

  /// Update member
  Future<MemberModel> updateMember(MemberModel member) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/${member.id}'),
        headers: headers,
        body: jsonEncode(member.toJson()),
      );

      if (response.statusCode == 200) {
        return MemberModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating member: $e');
    }
  }

  /// Delete member
  Future<void> deleteMember(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting member: $e');
    }
  }

  /// Search members by keyword
  Future<List<MemberModel>> searchMembers(String keyword) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/search?keyword=${Uri.encodeComponent(keyword)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MemberModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to search members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching members: $e');
    }
  }
}