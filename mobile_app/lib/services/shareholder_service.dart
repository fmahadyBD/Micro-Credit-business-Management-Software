// lib/services/shareholder_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/investment_history_model.dart';
import 'package:mobile_app/models/shareholder_model.dart';
import 'package:mobile_app/services/auth_service.dart';

class ShareholderService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/shareholders';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ShareholderModel>> getAllShareholders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShareholderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shareholders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching shareholders: $e');
    }
  }

  Future<ShareholderModel> getShareholderById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Shareholder not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Token may be invalid or expired');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You do not have permission');
      } else {
        throw Exception('Failed to load shareholder: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching shareholder: $e');
    }
  }

  Future<ShareholderModel> createShareholder(
      ShareholderModel shareholder) async {
    try {
      final headers = await _getHeaders();
      final jsonPayload = shareholder.toJson(forCreate: true);

      print('🚀 Creating shareholder with JSON:');
      print(jsonEncode(jsonPayload));

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(jsonPayload),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access Denied: You do not have permission to create shareholders');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        // ✅ Handle empty body
        if (response.body.isEmpty) {
          throw Exception(
              'Server error: Empty response (Status: ${response.statusCode})');
        }
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create shareholder');
      }
    } catch (e) {
      print('❌ Error in createShareholder: $e');
      rethrow;
    }
  }

  Future<ShareholderModel> updateShareholder(
      int id, ShareholderModel shareholder) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(shareholder.toJson()),
      );

      if (response.statusCode == 200) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Shareholder not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update shareholder');
      }
    } catch (e) {
      throw Exception('Error updating shareholder: $e');
    }
  }

  Future<void> deleteShareholder(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Shareholder not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete shareholder');
      }
    } catch (e) {
      throw Exception('Error deleting shareholder: $e');
    }
  }

  Future<List<ShareholderModel>> getActiveShareholders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShareholderModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load active shareholders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching active shareholders: $e');
    }
  }

  Future<List<ShareholderModel>> getInactiveShareholders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inactive'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShareholderModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load inactive shareholders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching inactive shareholders: $e');
    }
  }

// Add to lib/services/shareholder_service.dart

  Future<ShareholderModel> getShareholderByEmail(String email) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/by-email/$email'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Shareholder not found with email: $email');
      } else {
        throw Exception('Failed to find shareholder');
      }
    } catch (e) {
      throw Exception('Error searching shareholder: $e');
    }
  }

  Future<ShareholderModel> addInvestment(
    int shareholderId,
    double amount,
    String description,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$shareholderId/add-investment'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to add investment');
      }
    } catch (e) {
      throw Exception('Error adding investment: $e');
    }
  }

  Future<ShareholderModel> getCurrentShareholderProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ShareholderModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('আপনার শেয়ারহোল্ডার প্রোফাইল পাওয়া যায়নি');
      } else {
        throw Exception('প্রোফাইল লোড করতে সমস্যা হয়েছে');
      }
    } catch (e) {
      throw Exception('প্রোফাইল লোড করতে সমস্যা: $e');
    }
  }

  Future<List<InvestmentHistoryModel>> getMyInvestmentHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/me/investment-history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => InvestmentHistoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('বিনিয়োগ ইতিহাস লোড করতে ব্যর্থ');
      }
    } catch (e) {
      throw Exception('বিনিয়োগ ইতিহাস লোড করতে সমস্যা: $e');
    }
  }

  Future<List<InvestmentHistoryModel>> getInvestmentHistory(
      int shareholderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$shareholderId/investment-history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => InvestmentHistoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('বিনিয়োগ ইতিহাস লোড করতে ব্যর্থ');
      }
    } catch (e) {
      throw Exception('বিনিয়োগ ইতিহাস লোড করতে সমস্যা: $e');
    }
  }
}
