import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/product_model.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class ProductService {
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/api/products';
  final AuthService _authService = AuthService();

  /// Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all products - FIXED
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('Get all products response status: ${response.statusCode}');
      print('Get all products response body: ${response.body}');

      if (response.statusCode == 200) {
        // Backend returns List<ProductResponseDTO> directly
        final List<dynamic> products = jsonDecode(response.body);
        return products.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all products error: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Product not found');
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// Create product without images - FIXED
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final headers = await _getHeaders();

      // Prepare the request body according to your backend DTO
      final requestBody = {
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'price': product.price,
        'costPrice': product.costPrice,
        'isDeliveryRequired': product.isDeliveryRequired,
        if (product.soldByAgentId != null)
          'soldByAgentId': product.soldByAgentId,
        if (product.whoRequestId != null) 'whoRequestId': product.whoRequestId,
      };

      print('Creating product with data: $requestBody');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Create product response status: ${response.statusCode}');
      print('Create product response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return ProductModel.fromJson(responseData['product']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create product');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      print('Create product error: $e');
      throw Exception('Error creating product: $e');
    }
  }

  /// Create product with images - FIXED
  Future<ProductModel> createProductWithImages({
    required ProductModel product,
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

      // Prepare product data according to backend DTO
      final productData = {
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'price': product.price,
        'costPrice': product.costPrice,
        'isDeliveryRequired': product.isDeliveryRequired,
        if (product.soldByAgentId != null)
          'soldByAgentId': product.soldByAgentId,
        if (product.whoRequestId != null) 'whoRequestId': product.whoRequestId,
      };

      // Add product data as JSON string
      request.fields['product'] = jsonEncode(productData);

      // Add images
      for (var image in images) {
        request.files.add(image);
      }

      print('Creating product with images: $productData');
      print('Number of images: ${images.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create product with images response status: ${response.statusCode}');
      print('Create product with images response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return ProductModel.fromJson(responseData['product']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create product');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      print('Create product with images error: $e');
      throw Exception('Error creating product with images: $e');
    }
  }

 /// Update product - FIXED
Future<ProductModel> updateProduct(ProductModel product) async {
  try {
    final headers = await _getHeaders();

    final requestBody = {
      'name': product.name,
      'category': product.category,
      'description': product.description,
      'price': product.price,
      'costPrice': product.costPrice,
      'isDeliveryRequired': product.isDeliveryRequired,
      'soldByAgentId': product.soldByAgentId, // Ensure this is included
      'whoRequestId': product.whoRequestId, // Ensure this is included
    };

    print('Updating product ID: ${product.id} with data: $requestBody');

    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    print('Update product response status: ${response.statusCode}');
    print('Update product response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return ProductModel.fromJson(responseData['product']);
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to update product');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ??
          'Failed to update product: ${response.statusCode}');
    }
  } catch (e) {
    print('Update product error: $e');
    throw Exception('Error updating product: $e');
  }
}

  /// Delete product
  Future<void> deleteProduct(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to delete product');
        }
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Product not found');
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  /// Upload product images
  Future<void> uploadProductImages(
      int productId, List<http.MultipartFile> images) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$productId/images'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      for (var image in images) {
        request.files.add(image);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Failed to upload images');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading product images: $e');
    }
  }

  /// Delete product image
  Future<void> deleteProductImage(int productId, String filePath) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/$productId/images?filePath=${Uri.encodeComponent(filePath)}'),
        headers: headers,
      );

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
      throw Exception('Error deleting product image: $e');
    }
  }

  /// Helper method to create MultipartFile from image file
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