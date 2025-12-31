import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;
import 'package:scentview/models/banner.dart' as model;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:scentview/database/db_helper.dart'; 

class ApiService {
  final String baseUrl;
  static String? authToken;
  
  final DBHelper _dbHelper = DBHelper();

  // Base Domain
  static const String domainUrl = 'https://scentview.alwaysdata.net';

  ApiService({this.baseUrl = 'https://scentview.alwaysdata.net/api'});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  static String? toAbsoluteUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    if (relativeUrl.startsWith('http')) return relativeUrl;
    if (relativeUrl.startsWith('/storage')) {
       return '$domainUrl$relativeUrl'; 
    }
    return '$domainUrl/storage/$relativeUrl'; 
  }

  Map<String, String> _headers({bool json = false, bool multipart = false, String? token}) {
    final h = <String, String>{};
    h['Accept'] = 'application/json';
    if (!multipart) {
      if (json) h['Content-Type'] = 'application/json';
    }

    final effectiveToken = token ?? ApiService.authToken;
    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $effectiveToken';
    }
    return h;
  }

  String _parseError(int statusCode, String responseBody) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map && body.containsKey('message')) {
        if (body.containsKey('errors')) {
           return "${body['message']}: ${body['errors'].toString()}";
        }
        return body['message'];
      }
      if (body is Map && body.containsKey('errors')) {
         return body['errors'].toString();
      }
    } catch (_) {
      return "Status $statusCode: $responseBody";
    }
    return 'Request failed with status: $statusCode';
  }

  // ================ CATEGORY METHODS ================
  Future<List<app_category.Category>> fetchCategories() async {
    // 1. Offline Check (Crash Fix)
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return []; // Offline mein empty list return karo
    }

    try {
      final res = await http.get(_u('/categories'), headers: _headers());
      if (res.statusCode != 200) throw Exception('Failed to fetch categories');
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => app_category.Category.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createCategory({required String name, XFile? imageFile, String? token}) async {
    var request = http.MultipartRequest('POST', _u('/categories'));
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['name'] = name;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
    }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 300) throw Exception(_parseError(response.statusCode, responseBody));
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory({required String id, required String name, XFile? imageFile, String? token}) async {
    var request = http.MultipartRequest('POST', _u('/categories/$id'));
    request.fields['_method'] = 'PUT';
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['name'] = name;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
    }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 300) throw Exception(_parseError(response.statusCode, responseBody));
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<void> deleteCategory({required String id, String? token}) async {
    final res = await http.delete(_u('/categories/$id'), headers: _headers(token: token));
    if (res.statusCode >= 300) throw Exception('Delete category failed');
  }

  // ================ BANNER METHODS (UPDATED FOR OFFLINE) ================
  Future<List<model.Banner>> fetchBanners() async {
    // 1. Internet Check
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.none) {
      // 📴 OFFLINE: Local DB se data lo
      print("📴 No Internet. Fetching Banners from SQLite...");
      return await _dbHelper.getBanners();
    
    } else {
      // ✅ ONLINE: API se lo aur DB mein save karo
      try {
        final res = await http.get(_u('/banners'), headers: _headers());
        
        if (res.statusCode != 200) throw Exception('Failed to fetch banners: ${res.statusCode}');
        
        final List data = jsonDecode(res.body) as List;
        List<model.Banner> banners = data.map((e) => model.Banner.fromJson(e)).toList();
        
        // Save to Database
        await _dbHelper.insertBanners(banners);
        print("💾 Banners saved to Local DB");
        
        return banners;
      } catch (e) {
        // Agar API error de, to Offline try karo
        print("⚠️ API Error: $e. Trying Local DB...");
        return await _dbHelper.getBanners();
      }
    }
  }

  Future<Map<String, dynamic>> createBanner({
    required String title,
    String? targetScreen,
    String? targetId,
    required XFile imageFile,
    int sortOrder = 0,
    bool isActive = true,
    String? description,
    String? token,
  }) async {
    var request = http.MultipartRequest('POST', _u('/banners'));
    request.headers.addAll(_headers(multipart: true, token: token));
    
    request.fields['title'] = title;
    if (targetScreen != null) request.fields['target_screen'] = targetScreen;
    if (targetId != null) request.fields['target_id'] = targetId;
    if (description != null) request.fields['description'] = description;
    request.fields['sort_order'] = sortOrder.toString();
    request.fields['is_active'] = isActive ? '1' : '0';
    
    final bytes = await imageFile.readAsBytes();
    final mimeType = lookupMimeType(imageFile.path);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image', 
        bytes,
        filename: imageFile.name,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
    );
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } else {
      throw Exception(_parseError(response.statusCode, responseBody));
    }
  }

  Future<Map<String, dynamic>> updateBanner({
    required String id,
    required String title,
    String? targetScreen,
    String? targetId,
    XFile? imageFile,
    int? sortOrder,
    bool? isActive,
    String? description,
    String? currentImageUrl,
    String? token,
  }) async {
    var request = http.MultipartRequest('POST', _u('/banners/$id'));
    request.fields['_method'] = 'PUT';
    request.headers.addAll(_headers(multipart: true, token: token));
    
    request.fields['title'] = title;
    if (targetScreen != null) request.fields['target_screen'] = targetScreen;
    if (targetId != null) request.fields['target_id'] = targetId;
    if (description != null) request.fields['description'] = description;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();
    if (isActive != null) request.fields['is_active'] = isActive ? '1' : '0';
    
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    } 
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } else {
      throw Exception(_parseError(response.statusCode, responseBody));
    }
  }

  Future<void> deleteBanner({required String id, String? token}) async {
    final response = await http.delete(_u('/banners/$id'), headers: _headers(token: token));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete banner: ${response.statusCode}');
    }
  }

  // ================ PRODUCT METHODS (OFFLINE SUPPORTED) ================
  
  Future<List<Product>> fetchProducts({String? query}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.none) {
      // 📴 OFFLINE
      print("📴 No Internet. Fetching from SQLite...");
      return await _dbHelper.getProducts();
    } else {
      // ✅ ONLINE
      try {
        var path = '/products';
        if (query != null && query.isNotEmpty) path += '?q=$query';
        final res = await http.get(_u(path), headers: _headers());
        
        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body) as List;
          List<Product> products = data.map((e) => Product.fromJson(e)).toList();
          if (query == null || query.isEmpty) { 
             await _dbHelper.insertProducts(products);
             print("💾 Products saved to Local DB");
          }
          return products;
        } else {
          throw Exception('Products ${res.statusCode}');
        }
      } catch (e) {
        print("⚠️ API Error: $e. Trying Local DB...");
        return await _dbHelper.getProducts();
      }
    }
  }

  Future<List<Product>> fetchSliderProducts() async {
    // 1. Offline Check
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.none) {
      // 📴 OFFLINE: Local DB se 'isSlider' filter karo
      print("📴 No Internet. Fetching Slider from SQLite...");
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isSlider).toList();
    } else {
      // ✅ ONLINE
      try {
        final res = await http.get(_u('/slider-products'), headers: _headers());
        if (res.statusCode != 200) throw Exception('Slider products ${res.statusCode}');
        final List data = jsonDecode(res.body) as List;
        return data.map((e) => Product.fromJson(e)).toList();
      } catch (e) {
        List<Product> allProducts = await _dbHelper.getProducts();
        return allProducts.where((p) => p.isSlider).toList();
      }
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    // 1. Offline Check
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.none) {
      // 📴 OFFLINE: Local DB se 'isFeatured' filter karo
      print("📴 No Internet. Fetching Featured from SQLite...");
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isFeatured).toList();
    } else {
      // ✅ ONLINE
      try {
        final res = await http.get(_u('/products/featured'), headers: _headers());
        if (res.statusCode != 200) throw Exception('Featured products ${res.statusCode}');
        final List data = jsonDecode(res.body) as List;
        return data.map((e) => Product.fromJson(e)).toList();
      } catch (e) {
        List<Product> allProducts = await _dbHelper.getProducts();
        return allProducts.where((p) => p.isFeatured).toList();
      }
    }
  }

  // === PRODUCT ADD FUNCTION ===
  Future<Product> addProduct({
    required String name,
    required String description,
    required String price,
    String? salePrice,
    required String categoryId,
    required bool isFeatured,
    String? badgeText,
    String? stock,
    XFile? imageFile,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/products'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    print("🚀 Adding Product: $name");

    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price.trim(),
      'category_id': categoryId,
      'is_featured': isFeatured ? '1' : '0',
    });

    if (stock != null && stock.isNotEmpty) {
      request.fields['stock'] = stock.trim();
    } else {
      request.fields['stock'] = '0';
    }

    if (badgeText != null) {
      request.fields['badge_text'] = badgeText.trim();
    }
    
    if (salePrice != null && salePrice.isNotEmpty) {
      request.fields['sale_price'] = salePrice.trim();
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes(
        'main_image', 
        bytes, 
        filename: imageFile.name, 
        contentType: mimeType != null ? MediaType.parse(mimeType) : null
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("📡 STATUS: ${response.statusCode}");
    print("📩 RESPONSE: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  // === PRODUCT UPDATE FUNCTION ===
  Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required String price,
    String? salePrice,
    required String categoryId,
    required bool isFeatured,
    String? badgeText,
    String? stock, 
    XFile? imageFile,
    String? existingImageUrl,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/products/$id'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields['_method'] = 'PUT';
    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price.trim(),
      'category_id': categoryId,
      'is_featured': isFeatured ? '1' : '0',
    });

    if (stock != null && stock.isNotEmpty) {
      request.fields['stock'] = stock.trim();
    }

    if (badgeText != null) {
      request.fields['badge_text'] = badgeText.trim();
    }
    
    if (salePrice != null && salePrice.trim().isNotEmpty) {
      request.fields['sale_price'] = salePrice.trim();
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes(
        'main_image', 
        bytes, 
        filename: imageFile.name, 
        contentType: mimeType != null ? MediaType.parse(mimeType) : null
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> deleteProduct({required String id, String? token}) async {
    final response = await http.delete(_u('/products/$id'), headers: _headers(token: token));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}