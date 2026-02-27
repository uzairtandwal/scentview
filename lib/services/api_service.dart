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
  
  // ✅ NEW: Helper method to set token globally
  static void setAuthToken(String? token) {
    authToken = token;
    if (kDebugMode) print("🔑 ApiService: Token updated: ${token != null ? 'EXISTS' : 'NULL'}");
  }
  
  // ✅ GATEKEEPER: Loop rokne ke liye
  static bool _isFcmSynced = false; 

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
    h['Connection'] = 'Keep-Alive'; 

    if (!multipart) {
      if (json) h['Content-Type'] = 'application/json';
    }

    final effectiveToken = token ?? ApiService.authToken;
    
    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $effectiveToken';
      print("🔑 Token used in Request: $effectiveToken"); 
    } else {
      print("⚠️ No Token found for request!"); 
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
    } catch (_) {}
    return 'Request failed with status: $statusCode';
  }

  // ================ 🛒 ORDER METHODS (AB ORDER SAVE HOGA) ================
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        _u('/orders'),
        headers: _headers(json: true),
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Order successfully saved in Database");
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseError(response.statusCode, response.body));
      }
    } catch (e) {
      print("❌ Order Placement Error: $e");
      throw Exception('Failed to place order: $e');
    }
  }

  // ✅ FCM TOKEN SYNC (Loop protection ke saath)
  Future<void> updateFcmToken(String token) async {
    if (_isFcmSynced) return; 

    try {
      final response = await http.post(
        _u('/update-fcm-token'), 
        headers: _headers(json: true),
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        _isFcmSynced = true; 
        print("✅ FCM Token Synced Successfully (Only Once)");
      }
    } catch (e) {
      print("❌ FCM Token Sync Exception: $e");
    }
  }

  // ================ CATEGORY METHODS (OPTIMIZED) ================
  Future<List<app_category.Category>> fetchCategories() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return [];

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
    // ✅ Token handling improved
    request.headers.addAll(_headers(multipart: true, token: token ?? ApiService.authToken));
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
    // ✅ Token handling improved
    request.headers.addAll(_headers(multipart: true, token: token ?? ApiService.authToken));
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
    final res = await http.delete(_u('/categories/$id'), headers: _headers(token: token ?? ApiService.authToken));
    if (res.statusCode >= 300) throw Exception('Delete category failed');
  }
  // ================ BANNER METHODS ================
  Future<List<model.Banner>> fetchBanners() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return await _dbHelper.getBanners();

    try {
      final res = await http.get(_u('/banners'), headers: _headers());
      if (res.statusCode != 200) throw Exception('Failed to fetch banners: ${res.statusCode}');
      final List data = jsonDecode(res.body) as List;
      List<model.Banner> banners = data.map((e) => model.Banner.fromJson(e)).toList();
      await _dbHelper.insertBanners(banners);
      return banners;
    } catch (e) {
      return await _dbHelper.getBanners();
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
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
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
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
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

  // ================ PRODUCT METHODS ================
  Future<List<Product>> fetchProducts({String? query}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return await _dbHelper.getProducts();

    try {
      var path = '/products';
      if (query != null && query.isNotEmpty) path += '?q=$query';
      final res = await http.get(_u(path), headers: _headers());
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        List<Product> products = data.map((e) => Product.fromJson(e)).toList();
        if (query == null || query.isEmpty) await _dbHelper.insertProducts(products);
        return products;
      } else {
        throw Exception('Products ${res.statusCode}');
      }
    } catch (e) {
      return await _dbHelper.getProducts();
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final res = await http.get(_u('/products/search?q=$query'), headers: _headers());
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> fetchSliderProducts() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isSlider).toList();
    }
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

  Future<List<Product>> fetchFeaturedProducts() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isFeatured).toList();
    }
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
    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price.trim(),
      'category_id': categoryId,
      'is_featured': isFeatured ? '1' : '0',
    });
    request.fields['stock'] = (stock != null && stock.isNotEmpty) ? stock.trim() : '0';
    if (badgeText != null) request.fields['badge_text'] = badgeText.trim();
    if (salePrice != null && salePrice.isNotEmpty) request.fields['sale_price'] = salePrice.trim();
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('main_image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

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
    if (stock != null && stock.isNotEmpty) request.fields['stock'] = stock.trim();
    if (badgeText != null) request.fields['badge_text'] = badgeText.trim();
    if (salePrice != null && salePrice.trim().isNotEmpty) request.fields['sale_price'] = salePrice.trim();
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('main_image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
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
    if (response.statusCode != 204 && response.statusCode != 200) throw Exception('Failed to delete product');
  }
}