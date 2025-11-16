// lib/services/installment_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/installment/installment_model.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class InstallmentService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/installments';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create installment without images
  Future<InstallmentModel> createInstallment(InstallmentModel installment) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        'productId': installment.productId,
        'memberId': installment.memberId,
        'totalAmountOfProduct': installment.totalAmountOfProduct,
        'otherCost': installment.otherCost,
        'advanced_paid': installment.advancedPaid,
        'installmentMonths': installment.installmentMonths,
        'interestRate': installment.interestRate,
        'status': installment.status,
        'agentId': installment.agentId,
      };

      print('Creating installment: $requestBody');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Create installment response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return InstallmentModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create installment');
      }
    } catch (e) {
      print('Create installment error: $e');
      throw Exception('Error creating installment: $e');
    }
  }

  // Create installment with images
  Future<InstallmentModel> createInstallmentWithImages({
    required InstallmentModel installment,
    required List<http.MultipartFile> images,
  }) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/with-images'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final installmentData = {
        'productId': installment.productId,
        'memberId': installment.memberId,
        'totalAmountOfProduct': installment.totalAmountOfProduct,
        'otherCost': installment.otherCost,
        'advanced_paid': installment.advancedPaid,
        'installmentMonths': installment.installmentMonths,
        'interestRate': installment.interestRate,
        'status': installment.status,
        'agentId': installment.agentId,
      };

      request.fields['installment'] = jsonEncode(installmentData);

      for (var image in images) {
        request.files.add(image);
      }

      print('Creating installment with images: $installmentData');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return InstallmentModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create installment');
      }
    } catch (e) {
      print('Create installment with images error: $e');
      throw Exception('Error creating installment with images: $e');
    }
  }

  // Upload images to existing installment
  Future<void> uploadInstallmentImages(int installmentId, List<http.MultipartFile> images) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$installmentId/images'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      for (var image in images) {
        request.files.add(image);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 202) {
        throw Exception('Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  // Get all installments
  Future<List<InstallmentModel>> getAllInstallments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('Get all installments response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InstallmentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load installments: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all installments error: $e');
      throw Exception('Error fetching installments: $e');
    }
  }


//   // Get all installments
// Future<List<InstallmentModel>> getAllInstallments() async {
//   try {
//     final headers = await _getHeaders();
//     final response = await http.get(
//       Uri.parse(baseUrl),
//       headers: headers,
//     );

//     print('Get all installments response: ${response.statusCode}');
//     print('Raw response body: ${response.body}'); // Add this line

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
      
//       // Print each item to see which fields are null
//       for (int i = 0; i < data.length; i++) {
//         print('Item $i: ${data[i]}');
        
//         // Check for null fields in each item
//         data[i].forEach((key, value) {
//           if (value == null) {
//             print('NULL FIELD: $key is null in item $i');
//           }
//         });
//       }
      
//       return data.map((json) => InstallmentModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load installments: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Get all installments error: $e');
//     throw Exception('Error fetching installments: $e');
//   }
// }

  // Get installment by ID
  Future<InstallmentModel> getInstallmentById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return InstallmentModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Installment not found');
      }
    } catch (e) {
      throw Exception('Error fetching installment: $e');
    }
  }

  // Update installment
  Future<InstallmentModel> updateInstallment(int id, InstallmentModel installment) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        if (installment.totalAmountOfProduct != null) 
          'totalAmountOfProduct': installment.totalAmountOfProduct,
        if (installment.otherCost != null) 
          'otherCost': installment.otherCost,
        if (installment.advancedPaid != null) 
          'advanced_paid': installment.advancedPaid,
        if (installment.installmentMonths != null) 
          'installmentMonths': installment.installmentMonths,
        if (installment.interestRate != null) 
          'interestRate': installment.interestRate,
        if (installment.status != null) 
          'status': installment.status,
      };

      print('Updating installment: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return InstallmentModel.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update installment');
      }
    } catch (e) {
      print('Update installment error: $e');
      throw Exception('Error updating installment: $e');
    }
  }

  // Delete installment
  Future<void> deleteInstallment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete installment');
      }
    } catch (e) {
      throw Exception('Error deleting installment: $e');
    }
  }

  // Search installments
  Future<List<InstallmentModel>> searchInstallments(String keyword) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/search?keyword=${Uri.encodeComponent(keyword)}'),
        headers: headers,
      );

      print('Search response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InstallmentModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to search installments: ${response.statusCode}');
      }
    } catch (e) {
      print('Search installments error: $e');
      throw Exception('Error searching installments: $e');
    }
  }

  // Get installment images
  Future<List<String>> getInstallmentImages(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id/images'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }

  // Helper method to create MultipartFile from image
  static Future<http.MultipartFile> createMultipartFile(
    List<int> fileBytes,
    String fileName,
  ) async {
    return http.MultipartFile.fromBytes(
      'images',
      fileBytes,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );
  }
}