// lib/services/installment_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'installment_model.dart';
import '../../services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class InstallmentService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/installments';
  final AuthService _authService = AuthService();

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


// In your InstallmentService, update the getImageUrl method:

/// Get image URL from path - FIXED to handle both relative paths and full URLs
String getImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return '';
  
  // If the path is already a full URL (starts with http), return it as is
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    print('🖼️ Image is already a full URL: $imagePath');
    return imagePath;
  }
  
  String apiBase = baseUrl.split('/api').first;
  
  // Remove any leading slashes from imagePath to avoid double slashes
  String cleanImagePath = imagePath.replaceAll(RegExp(r'^/'), '');
  
  // Construct the URL
  String url = '$apiBase/uploads/$cleanImagePath';
  
  print('🖼️ Image URL Construction:');
  print('  - API Base: $apiBase');
  print('  - Image Path: $imagePath');
  print('  - Clean Path: $cleanImagePath');
  print('  - Final URL: $url');
  
  return url;
}
 
  /// Test if image URL is accessible - ADD THIS METHOD
  Future<bool> testImageUrl(String imagePath) async {
    try {
      final url = getImageUrl(imagePath);
      print('🔍 Testing installment image URL: $url');
      
      final response = await http.head(Uri.parse(url));
      print('📊 Installment image response status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Installment image URL test failed: $e');
      return false;
    }
  }

  // Create installment without images - FIXED
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return InstallmentModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create installment');
      }
    } catch (e) {
      print('Create installment error: $e');
      throw Exception('Error creating installment: $e');
    }
  }

  // Create installment with images - FIXED
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

      // Add images with correct field name
      for (var image in images) {
        request.files.add(image);
      }

      print('Creating installment with images: $installmentData');
      print('Number of images: ${images.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return InstallmentModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create installment');
      }
    } catch (e) {
      print('Create installment with images error: $e');
      throw Exception('Error creating installment with images: $e');
    }
  }

  // Upload images to existing installment - FIXED
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

      print('Upload images response status: ${response.statusCode}');
      print('Upload images response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 202) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload installment images error: $e');
      throw Exception('Error uploading images: $e');
    }
  }

  // Get all installments - IMPROVED with image URL conversion
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
        
        // Convert image paths to full URLs
        final installments = data.map((json) {
          final installment = InstallmentModel.fromJson(json);
          
          // Convert image paths to full URLs
          if (installment.imageFilePaths.isNotEmpty) {
            final imageUrls = installment.imageFilePaths.map((path) => getImageUrl(path)).toList();
            return installment.copyWith(imageFilePaths: imageUrls);
          }
          
          return installment;
        }).toList();
        
        return installments;
      } else {
        throw Exception('Failed to load installments: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all installments error: $e');
      throw Exception('Error fetching installments: $e');
    }
  }

  // Get installment by ID - IMPROVED with image URL conversion
  Future<InstallmentModel> getInstallmentById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print('Get installment by ID response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final installmentData = jsonDecode(response.body);
        final installment = InstallmentModel.fromJson(installmentData);
        
        // Convert image paths to full URLs
        if (installment.imageFilePaths.isNotEmpty) {
          final imageUrls = installment.imageFilePaths.map((path) => getImageUrl(path)).toList();
          return installment.copyWith(imageFilePaths: imageUrls);
        }
        
        return installment;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Installment not found');
      }
    } catch (e) {
      print('Get installment by ID error: $e');
      throw Exception('Error fetching installment: $e');
    }
  }

  // Update installment - FIXED
  Future<InstallmentModel> updateInstallment(int id, InstallmentModel installment) async {
    try {
      final headers = await _getHeaders();
      
      final requestBody = {
        'totalAmountOfProduct': installment.totalAmountOfProduct,
        'otherCost': installment.otherCost,
        'advanced_paid': installment.advancedPaid,
        'installmentMonths': installment.installmentMonths,
        'interestRate': installment.interestRate,
        'status': installment.status,
      };

      print('Updating installment: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Update response: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return InstallmentModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update installment');
      }
    } catch (e) {
      print('Update installment error: $e');
      throw Exception('Error updating installment: $e');
    }
  }

  // Update installment with images - ADD THIS METHOD
  Future<InstallmentModel> updateInstallmentWithImages({
    required int id,
    required InstallmentModel installment,
    required List<http.MultipartFile> images,
  }) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/$id/with-images'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final installmentData = {
        'totalAmountOfProduct': installment.totalAmountOfProduct,
        'otherCost': installment.otherCost,
        'advanced_paid': installment.advancedPaid,
        'installmentMonths': installment.installmentMonths,
        'interestRate': installment.interestRate,
        'status': installment.status,
      };

      request.fields['installment'] = jsonEncode(installmentData);

      // Add images
      for (var image in images) {
        request.files.add(image);
      }

      print('Updating installment with images: $installmentData');
      print('Number of new images: ${images.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update with images response status: ${response.statusCode}');
      print('Update with images response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return InstallmentModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update installment');
      }
    } catch (e) {
      print('Update installment with images error: $e');
      throw Exception('Error updating installment with images: $e');
    }
  }

  // Delete installment - FIXED
  Future<void> deleteInstallment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print('Delete installment response: ${response.statusCode}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete installment');
      }
    } catch (e) {
      print('Delete installment error: $e');
      throw Exception('Error deleting installment: $e');
    }
  }

  // Delete installment image - ADD THIS METHOD
  Future<void> deleteInstallmentImage(int installmentId, String filePath) async {
    try {
      final headers = await _getHeaders();
      
      // URL encode the file path to handle special characters
      final encodedFilePath = Uri.encodeComponent(filePath);
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$installmentId/images?filePath=$encodedFilePath'),
        headers: headers,
      );

      print('Delete installment image response status: ${response.statusCode}');
      print('Delete installment image response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to delete image');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to delete image: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete installment image error: $e');
      throw Exception('Error deleting installment image: $e');
    }
  }

  // Search installments - IMPROVED
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
        
        // Convert image paths to full URLs
        final installments = data.map((json) {
          final installment = InstallmentModel.fromJson(json);
          
          if (installment.imageFilePaths.isNotEmpty) {
            final imageUrls = installment.imageFilePaths.map((path) => getImageUrl(path)).toList();
            return installment.copyWith(imageFilePaths: imageUrls);
          }
          
          return installment;
        }).toList();
        
        return installments;
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

  // Get installment images - IMPROVED with URL conversion
  Future<List<String>> getInstallmentImages(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id/images'),
        headers: headers,
      );

      print('Get installment images response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Convert paths to full URLs
        return data.map((path) => getImageUrl(path.toString())).toList();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      print('Get installment images error: $e');
      throw Exception('Error fetching images: $e');
    }
  }

  // Helper method to create MultipartFile from image - FIXED field name
  static Future<http.MultipartFile> createMultipartFile(
    List<int> fileBytes,
    String fileName,
  ) async {
    return http.MultipartFile.fromBytes(
      'images', // Make sure this matches your backend expectation
      fileBytes,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );
  }

  /// Validate image file size before upload
  static bool validateImageSize(int sizeInBytes) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    return sizeInBytes <= maxSize;
  }

  /// Get human-readable file size
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
