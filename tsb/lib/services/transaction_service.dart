// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/balance_model.dart';
import 'auth_service.dart';

class TransactionService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/main-balance';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/transactions');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map<TransactionModel>((e) {
          if (e is Map<String, dynamic>) {
            return TransactionModel.fromJson(e);
          } else if (e is Map) {
            return TransactionModel.fromJson(Map<String, dynamic>.from(e));
          } else {
            throw Exception('Unexpected transaction item type: ${e.runtimeType}');
          }
        }).toList();
      } else {
        throw Exception('Expected list from transactions endpoint');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode} ${response.body}');
    }
  }

  Future<BalanceModel> getCurrentBalance() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/current');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return BalanceModel.fromJson(decoded);
      } else if (decoded is Map) {
        return BalanceModel.fromJson(Map<String, dynamic>.from(decoded));
      } else {
        throw Exception('Invalid balance format from server');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load balance: ${response.statusCode} ${response.body}');
    }
  }

  // Optional: fetch by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/transactions/type/$type');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map<TransactionModel>((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        throw Exception('Expected list for transactions by type');
      }
    } else {
      throw Exception('Failed to load transactions by type: ${response.statusCode}');
    }
  }
}
