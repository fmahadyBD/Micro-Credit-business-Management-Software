// lib/services/payment_schedule_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/payment_schedule_model.dart';
import 'package:mobile_app/services/auth_service.dart';

class PaymentScheduleService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/payment-schedules';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create payment
  Future<PaymentScheduleModel> createPayment({
    required int installmentId,
    required int agentId,
    required double amount,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();

      final requestBody = {
        'installmentId': installmentId,
        'agentId': agentId,
        'amount': amount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('Creating payment: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/pay'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Payment response status: ${response.statusCode}');
      print('Payment response body: ${response.body}');

      if (response.statusCode == 201) {
        return PaymentScheduleModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      print('Create payment error: $e');
      throw Exception('Error creating payment: $e');
    }
  }

  /// Get monthly installment amount
  Future<double> getMonthlyAmount(int installmentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/installment/$installmentId/monthly-amount'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['monthlyAmount'] ?? 0).toDouble();
      } else {
        throw Exception('Failed to load monthly amount');
      }
    } catch (e) {
      throw Exception('Error fetching monthly amount: $e');
    }
  }

  /// Get payments by installment ID
  // Future<List<PaymentScheduleModel>> getPaymentsByInstallmentId(int installmentId) async {
  //   try {
  //     final headers = await _getHeaders();
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/installment/$installmentId'),
  //       headers: headers,
  //     );

  //     print('Get payments response: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((json) => PaymentScheduleModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load payments');
  //     }
  //   } catch (e) {
  //     print('Get payments error: $e');
  //     throw Exception('Error fetching payments: $e');
  //   }
  // }

  /// Get payments by installment ID
  Future<List<PaymentScheduleModel>> getPaymentsByInstallmentId(
      int installmentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/installment/$installmentId'),
        headers: headers,
      );

      print('Get payments response: ${response.statusCode}');
      print('Get payments body: ${response.body}'); // Add this for debugging

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List) {
          return responseData
              .map((json) => PaymentScheduleModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Unexpected response format: expected List');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load payments');
      }
    } catch (e) {
      print('Get payments error: $e');
      throw Exception('Error fetching payments: $e');
    }
  }

  /// Get installment balance
  Future<InstallmentBalanceModel> getInstallmentBalance(
      int installmentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/installment/$installmentId/balance'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return InstallmentBalanceModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      throw Exception('Error fetching balance: $e');
    }
  }

  /// Get payments by agent
  Future<List<PaymentScheduleModel>> getPaymentsByAgentId(int agentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/agent/$agentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load agent payments');
      }
    } catch (e) {
      throw Exception('Error fetching agent payments: $e');
    }
  }

  /// Get payments by member
  Future<List<PaymentScheduleModel>> getPaymentsByMemberId(int memberId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/member/$memberId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load member payments');
      }
    } catch (e) {
      throw Exception('Error fetching member payments: $e');
    }
  }

  /// Delete payment
  Future<void> deletePayment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete payment');
      }
    } catch (e) {
      throw Exception('Error deleting payment: $e');
    }
  }

  /// Check if payment exists this month
  Future<bool> hasPaymentThisMonth(int installmentId) async {
    try {
      final payments = await getPaymentsByInstallmentId(installmentId);

      if (payments.isEmpty) return false;

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);

      return payments.any((payment) {
        final paymentMonth = DateTime(
          payment.paymentDate.year,
          payment.paymentDate.month,
        );
        return paymentMonth == thisMonth;
      });
    } catch (e) {
      return false;
    }
  }
}
