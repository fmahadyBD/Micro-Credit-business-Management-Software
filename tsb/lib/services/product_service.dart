import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'auth_service.dart';
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

  /// Get image URL from path - FIXED to handle both relative paths and full URLs
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // If the path is already a full URL (starts with http), return it as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print('🖼️ Product Image is already a full URL: $imagePath');
      return imagePath;
    }
    
    String apiBase = baseUrl.split('/api').first;
    
    // Remove any leading slashes from imagePath to avoid double slashes
    String cleanImagePath = imagePath.replaceAll(RegExp(r'^/'), '');
    
    // Construct the URL
    String url = '$apiBase/uploads/$cleanImagePath';
    
    print('🖼️ Product Image URL Construction:');
    print('  - API Base: $apiBase');
    print('  - Image Path: $imagePath');
    print('  - Clean Path: $cleanImagePath');
    print('  - Final URL: $url');
    
    return url;
  }

  /// Get all products - IMPROVED
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print('Get all products response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> products = jsonDecode(response.body);
        
        // Convert and add full image URLs
        final productList = products.map((json) {
          final product = ProductModel.fromJson(json);
          
          // Convert image paths to full URLs
          if (product.imageFilePaths.isNotEmpty) {
            final imageUrls = product.imageFilePaths.map((path) => getImageUrl(path)).toList();
            return product.copyWith(imageFilePaths: imageUrls);
          }
          
          return product;
        }).toList();
        
        return productList;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all products error: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  /// Get product by ID - IMPROVED
  Future<ProductModel> getProductById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        final product = ProductModel.fromJson(productData);
        
        // Convert image paths to full URLs
        if (product.imageFilePaths.isNotEmpty) {
          final imageUrls = product.imageFilePaths.map((path) => getImageUrl(path)).toList();
          return product.copyWith(imageFilePaths: imageUrls);
        }
        
        return product;
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
        'soldByAgentId': product.soldByAgentId,
        'whoRequestId': product.whoRequestId,
      };

      print('Creating product with data: $requestBody');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Create product response status: ${response.statusCode}');
      print('Create product response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
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
        'soldByAgentId': product.soldByAgentId,
        'whoRequestId': product.whoRequestId,
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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
        'soldByAgentId': product.soldByAgentId,
        'whoRequestId': product.whoRequestId,
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

  /// Update product with images - ADD THIS METHOD
  Future<ProductModel> updateProductWithImages({
    required ProductModel product,
    required List<http.MultipartFile> images,
  }) async {
    try {
      final token = await _authService.getToken();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/${product.id}/with-images'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Prepare product data
      final productData = {
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'price': product.price,
        'costPrice': product.costPrice,
        'isDeliveryRequired': product.isDeliveryRequired,
        'soldByAgentId': product.soldByAgentId,
        'whoRequestId': product.whoRequestId,
      };

      // Add product data as JSON string
      request.fields['product'] = jsonEncode(productData);

      // Add images
      for (var image in images) {
        request.files.add(image);
      }

      print('Updating product with images: $productData');
      print('Number of new images: ${images.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update product with images response status: ${response.statusCode}');
      print('Update product with images response body: ${response.body}');

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
      print('Update product with images error: $e');
      throw Exception('Error updating product with images: $e');
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

  /// Upload product images - FIXED
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

      print('Upload product images response status: ${response.statusCode}');
      print('Upload product images response body: ${response.body}');

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
      print('Upload product images error: $e');
      throw Exception('Error uploading product images: $e');
    }
  }

  /// Delete product image - FIXED
  Future<void> deleteProductImage(int productId, String filePath) async {
    try {
      final headers = await _getHeaders();
      
      // URL encode the file path to handle special characters
      final encodedFilePath = Uri.encodeComponent(filePath);
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId/images?filePath=$encodedFilePath'),
        headers: headers,
      );

      print('Delete product image response status: ${response.statusCode}');
      print('Delete product image response body: ${response.body}');

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
      print('Delete product image error: $e');
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

  /// Test if image URL is accessible - FIXED
  Future<bool> testImageUrl(String imagePath) async {
    try {
      final url = getImageUrl(imagePath);
      print('🔍 Testing product image URL: $url');
      
      final response = await http.head(Uri.parse(url));
      print('📊 Product image response status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Product image URL test failed: $e');
      return false;
    }
  }
}
