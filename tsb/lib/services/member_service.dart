// lib/services/member_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/member_model.dart';
import '../models/deleted_member_model.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';

class MemberService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/members';
  final AuthService _authService = AuthService();

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get image URL from path
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
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

  /// Debug method to check URL construction
  void debugImageUrls(MemberModel member) {
    print('=== DEBUG IMAGE URLS ===');
    
    if (member.photoPath != null) {
      final photoUrl = getImageUrl(member.photoPath);
      print('Photo Path: ${member.photoPath}');
      print('Photo URL: $photoUrl');
    }
    
    if (member.nidCardImagePath != null) {
      final nidUrl = getImageUrl(member.nidCardImagePath);
      print('NID Path: ${member.nidCardImagePath}');
      print('NID URL: $nidUrl');
    }
    
    if (member.nomineeNidCardImagePath != null) {
      final nomineeUrl = getImageUrl(member.nomineeNidCardImagePath);
      print('Nominee Path: ${member.nomineeNidCardImagePath}');
      print('Nominee URL: $nomineeUrl');
    }
    
    print('Base URL: $baseUrl');
    print('API Base: ${baseUrl.split('/api').first}');
    print('========================');
  }

  /// Test if image URL is accessible
  Future<bool> testImageUrl(String imagePath) async {
    try {
      final url = getImageUrl(imagePath);
      print('🔍 Testing URL: $url');
      
      final response = await http.head(Uri.parse(url));
      print('📊 Response Status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Image URL test failed: $e');
      return false;
    }
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
        final members = data.map((json) => MemberModel.fromJson(json)).toList();
        
        // Debug the first member's image URLs
        if (members.isNotEmpty) {
          debugImageUrls(members.first);
          
          // Test first image URL accessibility
          if (members.first.photoPath != null) {
            final accessible = await testImageUrl(members.first.photoPath!);
            print('🔄 First photo accessible: $accessible');
          }
        }
        
        return members;
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
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Member not found');
      } else {
        throw Exception('Failed to load member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching member: $e');
    }
  }

  /// Create new member with images
  Future<Map<String, dynamic>> createMemberWithImages({
    required MemberModel member,
    required http.MultipartFile nidCardImage,
    required http.MultipartFile photo,
    required http.MultipartFile nomineeNidCardImage,
  }) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Use forCreate: true to exclude joinDate from the request
      request.fields['member'] = jsonEncode(member.toJson(forCreate: true));

      // Add images
      request.files.add(nidCardImage);
      request.files.add(photo);
      request.files.add(nomineeNidCardImage);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create member');
      }
    } catch (e) {
      throw Exception('Error creating member: $e');
    }
  }

  /// Update member with optional images
  Future<Map<String, dynamic>> updateMemberWithImages({
    required int id,
    required MemberModel member,
    http.MultipartFile? nidCardImage,
    http.MultipartFile? photo,
    http.MultipartFile? nomineeNidCardImage,
  }) async {
    try {
      final token = await _authService.getToken();
      final request =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id/with-images'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // For update, include all member data
      request.fields['member'] = jsonEncode(member.toJson());

      // Add images if provided
      if (nidCardImage != null) request.files.add(nidCardImage);
      if (photo != null) request.files.add(photo);
      if (nomineeNidCardImage != null) request.files.add(nomineeNidCardImage);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update member');
      }
    } catch (e) {
      throw Exception('Error updating member: $e');
    }
  }

  /// Delete member
  Future<Map<String, dynamic>> deleteMember(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Member not found');
      } else {
        throw Exception('Failed to delete member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting member: $e');
    }
  }

  /// Get all deleted members
  Future<List<DeletedMemberModel>> getDeletedMembers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/deleted'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DeletedMemberModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load deleted members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching deleted members: $e');
    }
  }

  /// Helper method to create MultipartFile from image file with size validation
  static Future<http.MultipartFile> createMultipartFile(
    String fieldName,
    List<int> fileBytes,
    String fileName,
  ) async {
    // Check file size (5MB limit)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (fileBytes.length > maxSize) {
      throw Exception('Image size must be less than 5MB');
    }

    return http.MultipartFile.fromBytes(
      fieldName,
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
