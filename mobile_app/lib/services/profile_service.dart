import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/profile_model.dart';
import 'package:mobile_app/services/auth_service.dart';

class ProfileService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/profile';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    print('🔵 ProfileService: Getting headers...');
    final token = await _authService.getToken();
    print('🔵 ProfileService: Token exists: ${token != null}');
    if (token != null) {
      print('🔵 ProfileService: Token preview: ${token.substring(0, 20)}...');
    }
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ProfileModel> getMyProfile() async {
    print('🔵 ProfileService: getMyProfile called');
    print('🔵 ProfileService: API URL: $baseUrl');
    
    try {
      final headers = await _getHeaders();
      print('🔵 ProfileService: Making GET request...');
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('🔵 ProfileService: Response status: ${response.statusCode}');
      print('🔵 ProfileService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('✅ ProfileService: Successfully decoded JSON');
        print('   - Data keys: ${jsonData.keys}');
        
        final profile = ProfileModel.fromJson(jsonData);
        print('✅ ProfileService: Profile created');
        print('   - ID: ${profile.id}');
        print('   - Name: ${profile.fullName}');
        print('   - Email: ${profile.username}');
        print('   - Role: ${profile.role}');
        
        return profile;
      } else {
        print('❌ ProfileService: Failed with status ${response.statusCode}');
        print('   - Response: ${response.body}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ProfileService: Error in getMyProfile: $e');
      print('   - Stack trace: $stackTrace');
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<ProfileModel> updateMyProfile({
    String? firstname,
    String? lastname,
    String? password,
  }) async {
    print('🔵 ProfileService: updateMyProfile called');
    print('   - firstname: $firstname');
    print('   - lastname: $lastname');
    print('   - password: ${password != null ? "***" : "null"}');
    
    try {
      final headers = await _getHeaders();
      
      final Map<String, dynamic> requestBody = {};
      if (firstname != null && firstname.isNotEmpty) {
        requestBody['firstname'] = firstname;
      }
      if (lastname != null && lastname.isNotEmpty) {
        requestBody['lastname'] = lastname;
      }
      if (password != null && password.isNotEmpty) {
        requestBody['password'] = password;
      }

      print('🔵 ProfileService: Request body: ${jsonEncode(requestBody)}');
      print('🔵 ProfileService: Making PUT request to: $baseUrl');

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('🔵 ProfileService: Update response status: ${response.statusCode}');
      print('🔵 ProfileService: Update response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ ProfileService: Profile updated successfully');
        return ProfileModel.fromJson(jsonDecode(response.body));
      } else {
        print('❌ ProfileService: Update failed with status ${response.statusCode}');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ProfileService: Error in updateMyProfile: $e');
      print('   - Stack trace: $stackTrace');
      throw Exception('Error updating profile: $e');
    }
  }
}