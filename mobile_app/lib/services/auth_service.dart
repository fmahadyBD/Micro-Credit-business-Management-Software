// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/auth';

  /// Register user
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstname": firstName,
          "lastname": lastName,
          "email": email,
          "password": password,
        }),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  /// Login user and store JWT token
  Future<String?> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/authenticate");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Store the token
        if (token != null) {
          await _storeToken(token);
        }
        
        return token;
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Logout user by removing stored JWT token
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final removed = await prefs.remove('jwt_token');
      return removed;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      // Validate token format (basic check)
      if (token != null && token.isNotEmpty && token.contains('.')) {
        return token;
      } else {
        // Clear invalid token
        await prefs.remove('jwt_token');
        return null;
      }
    } catch (e) {
      print('Get token error: $e');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty && token.contains('.');
  }

  /// Clear all user data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Clear data error: $e');
      return false;
    }
  }

  /// Private method to store token
  Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } catch (e) {
      print('Store token error: $e');
    }
  }
}