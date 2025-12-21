import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;
import 'package:scentview/models/banner.dart' as model;
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  static String? authToken;

  ApiService({this.baseUrl = 'https://scentview.alwaysdata.net'});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  static String? toAbsoluteUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    if (relativeUrl.startsWith('http')) return relativeUrl.replaceFirst('http://', 'https://');
    final baseUri = Uri.parse('https://scentview.alwaysdata.net');
    final finalUri = baseUri.resolve(relativeUrl);
    return finalUri.toString();
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

  // --- Auth ---
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(_u('/api/register'), headers: _headers(json: true), body: jsonEncode({'name': name, 'email': email, 'password': password}));
    if (res.statusCode != 200) throw Exception('Registration failed: ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    authToken = data['token'];
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(_u('/api/login'), headers: _headers(json: true), body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode != 200) throw Exception('Login failed: ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    authToken = data['token'];
    return data;
  }

  Future<void> logout({required String token}) async {
    final res = await http.post(_u('/api/logout'), headers: _headers(token: token));
    if (res.statusCode != 200) throw Exception('Logout failed: ${res.statusCode}');
    authToken = null;
  }

  // --- Categories ---
  Future<List<app_category.Category>> fetchCategories() async {
    final res = await http.get(_u('/api/categories'), headers: _headers());
    if (res.statusCode != 200) throw Exception('Failed to fetch categories');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => app_category.Category.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> createCategory({required String name, XFile? imageFile, required String token}) async {
    var request = http.MultipartRequest('POST', _u('/api/categories'));
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['name'] = name;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name));
    }
    final response = await request.send();
    if (response.statusCode >= 300) throw Exception('Create category failed');
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCategory({required String id, required String name, XFile? imageFile, required String token}) async {
    var request = http.MultipartRequest('POST', _u('/api/categories/$id'));
    request.fields['_method'] = 'PUT';
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['name'] = name;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name));
    }
    final response = await request.send();
    if (response.statusCode >= 300) throw Exception('Update category failed');
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String id, {required String token}) async {
    final res = await http.delete(_u('/api/categories/$id'), headers: _headers(token: token));
    if (res.statusCode >= 300) throw Exception('Delete category failed');
  }

  // --- Banners ---
  Future<List<model.Banner>> fetchBanners() async {
    final res = await http.get(_u('/api/banners'), headers: _headers());
    if (res.statusCode != 200) throw Exception('Banners ${res.statusCode}');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => model.Banner.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> createBanner({required String title, String? targetScreen, String? targetId, required XFile imageFile, int sortOrder = 0, bool isActive = true, required String token}) async {
    var request = http.MultipartRequest('POST', _u('/api/banners'));
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['title'] = title;
    request.fields['target_screen'] = targetScreen ?? '';
    request.fields['target_id'] = targetId ?? '';
    request.fields['sort_order'] = sortOrder.toString();
    request.fields['is_active'] = isActive ? '1' : '0';
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image_url', bytes, filename: imageFile.name));
    final response = await request.send();
    if (response.statusCode >= 300) throw Exception('Create banner failed');
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBanner({required String id, required String title, String? targetScreen, String? targetId, XFile? imageFile, int? sortOrder, bool? isActive, required String token}) async {
    var request = http.MultipartRequest('POST', _u('/api/banners/$id'));
    request.fields['_method'] = 'PUT';
    request.headers.addAll(_headers(multipart: true, token: token));
    request.fields['title'] = title;
    if (targetScreen != null) request.fields['target_screen'] = targetScreen;
    if (targetId != null) request.fields['target_id'] = targetId;
    if (sortOrder != null) request.fields['sort_order'] = sortOrder.toString();
    if (isActive != null) request.fields['is_active'] = isActive ? '1' : '0';
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('image_url', bytes, filename: imageFile.name));
    }
    final response = await request.send();
    if (response.statusCode >= 300) throw Exception('Update banner failed');
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  Future<void> deleteBanner(String id, {required String token}) async {
    final res = await http.delete(_u('/api/banners/$id'), headers: _headers(token: token));
    if (res.statusCode >= 300) throw Exception('Delete banner failed');
  }

  // --- PRODUCTS (UPDATED) ---
  Future<List<Product>> fetchProducts({String? query}) async {
    var path = '/api/products';
    if (query != null && query.isNotEmpty) path += '?q=$query';
    final res = await http.get(_u(path), headers: _headers());
    if (res.statusCode != 200) throw Exception('Products ${res.statusCode}');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product?> fetchProductById(String id) async {
    final res = await http.get(_u('/api/products/$id'), headers: _headers());
    if (res.statusCode != 200) return null;
    final Map<String, dynamic> e = jsonDecode(res.body) as Map<String, dynamic>;
    return Product.fromJson(e);
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    final res = await http.get(_u('/api/products/featured'), headers: _headers());
    if (res.statusCode != 200) throw Exception('Featured products ${res.statusCode}');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> fetchSliderProducts() async {
    final res = await http.get(_u('/api/slider-products'), headers: _headers());
    if (res.statusCode != 200) throw Exception('Slider products ${res.statusCode}');
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  // --- ADD PRODUCT (UPDATED) ---
  Future<Product> addProduct({
    required String name,
    required String description,
    required String price,
    String? salePrice,
    required String categoryId,
    required bool isFeatured,
    String? badgeText, // <--- ADDED
    XFile? imageFile,
    required String token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/api/products'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.trim(); // Trim Spaces
    request.fields['category_id'] = categoryId;
    request.fields['is_featured'] = isFeatured ? '1' : '0';

    // Badge Text Fix
    if (badgeText != null && badgeText.trim().isNotEmpty) {
      request.fields['badge_text'] = badgeText.trim();
    } else {
      request.fields['badge_text'] = "";
    }

    // Sale Price Fix
    if (salePrice != null && salePrice.trim().isNotEmpty) {
      request.fields['sale_price'] = salePrice.trim();
    } else {
      request.fields['sale_price'] = "";
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('main_image_url', bytes, filename: imageFile.name));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product: ${response.statusCode} ${response.body}');
    }
  }

  // --- UPDATE PRODUCT (UPDATED) ---
  Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required String price,
    String? salePrice,
    required String categoryId,
    required bool isFeatured,
    String? badgeText, // <--- ADDED
    XFile? imageFile,
    required String token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/api/products/$id'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields['_method'] = 'PUT';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.trim();
    request.fields['category_id'] = categoryId;
    request.fields['is_featured'] = isFeatured ? '1' : '0';

    // Badge Text Fix
    if (badgeText != null && badgeText.trim().isNotEmpty) {
      request.fields['badge_text'] = badgeText.trim();
    } else {
      request.fields['badge_text'] = "";
    }

    // Sale Price Fix
    if (salePrice != null && salePrice.trim().isNotEmpty) {
      request.fields['sale_price'] = salePrice.trim();
    } else {
      request.fields['sale_price'] = "";
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('main_image_url', bytes, filename: imageFile.name));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteProduct(String id, {required String token}) async {
    final response = await http.delete(
      _u('/api/products/$id'),
      headers: _headers(token: token),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.statusCode} ${response.body}');
    }
  }

  Future<String?> uploadImage(XFile image, {required String token}) async {
    final uri = _u('/api/upload');
    final request = http.MultipartRequest('POST', uri);
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    request.headers.addAll(_headers(multipart: true, token: token));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      if (kDebugMode) debugPrint('Image upload failed: ${res.statusCode} ${res.body}');
      return null;
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['url'] as String?;
  }
}
