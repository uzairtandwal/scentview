import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/order.dart';
import 'package:scentview/models/category.dart' as app_category;
import 'package:scentview/models/banner.dart' as model;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:scentview/database/db_helper.dart'; 

import 'package:scentview/utils/url_utils.dart';

class ApiService {
  final String baseUrl;
  static String? authToken;
  
  static void setAuthToken(String? token) {
    authToken = token;
    if (kDebugMode) print("🔑 ApiService: Token updated: ${token != null ? 'EXISTS' : 'NULL'}");
  }
  
  static bool _isFcmSynced = false; 
  final DBHelper _dbHelper = DBHelper();

  // Yahan hum domain aur api path ko set kar rahe hain
  // Agar ye galat ho toh TimeoutException aati hai
  static const String domainUrl = UrlUtils.domainUrl;
  
  ApiService({this.baseUrl = '${UrlUtils.domainUrl}/api/v1'});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  static String? toAbsoluteUrl(String? relativeUrl) {
    return UrlUtils.toAbsoluteUrl(relativeUrl);
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

  // ================ 🛒 ORDER METHODS ================
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        _u('/orders'),
        headers: _headers(json: true),
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseError(response.statusCode, response.body));
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<void> updateFcmToken(String token) async {
    if (_isFcmSynced) return; 
    try {
      final response = await http.post(
        _u('/update-fcm-token'), 
        headers: _headers(json: true),
        body: jsonEncode({'fcm_token': token}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _isFcmSynced = true; 
      }
    } catch (_) {}
  }

  // ================ LOCAL DATA METHODS ================
  Future<List<app_category.Category>> fetchCategoriesLocal() async {
    final maps = await _dbHelper.getCategories();
    return maps.map((e) => app_category.Category.fromJson(e)).toList();
  }

  Future<List<model.Banner>> fetchBannersLocal() async {
    return await _dbHelper.getBanners();
  }

  Future<List<Product>> fetchProductsLocal() async {
    return await _dbHelper.getProducts();
  }

  // ================ CATEGORY METHODS ================
  Future<List<app_category.Category>> fetchCategories() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return await fetchCategoriesLocal();
    }

    try {
      final res = await http.get(_u('/categories'), headers: _headers()).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          list = (data is List) ? data : (data is Map ? data['data'] ?? [] : []);
        }
        
        // Save to local DB
        await _dbHelper.insertCategories(list.cast<Map<String, dynamic>>());
        
        return list.map((e) => app_category.Category.fromJson(e)).toList();
      }
      return await fetchCategoriesLocal();
    } catch (e) {
      debugPrint("Fetch Categories Error: $e");
      return await fetchCategoriesLocal();
    }
  }

  // ================ BANNER METHODS ================
  Future<List<model.Banner>> fetchBanners() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) return await _dbHelper.getBanners();

    try {
      final res = await http.get(_u('/banners'), headers: _headers()).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          list = (data is List) ? data : (data is Map ? data['data'] ?? [] : []);
        }
        List<model.Banner> banners = list.map((e) => model.Banner.fromJson(e)).toList();
        await _dbHelper.insertBanners(banners);
        return banners;
      }
      return await _dbHelper.getBanners();
    } catch (e) {
      return await _dbHelper.getBanners();
    }
  }

  // ================ PRODUCT METHODS ================
  Future<List<Product>> fetchProducts({String? query}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) return await _dbHelper.getProducts();

    try {
      var path = '/products';
      if (query != null && query.isNotEmpty) path += '?q=$query';
      final res = await http.get(_u(path), headers: _headers()).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> productList = [];
        
        if (decoded is List) {
          productList = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is List) {
            productList = data;
          } else if (data is Map && data.containsKey('data')) {
            productList = data['data'];
          }
        }
// ✅ DEBUG — console mein URL dikhega
if (productList.isNotEmpty) {
  debugPrint("🖼️ RAW image_url: ${productList[0]['image_url']}");
}
        List<Product> products = productList.map((e) => Product.fromJson(e)).toList();
        if (query == null || query.isEmpty) await _dbHelper.insertProducts(products);
        return products;
      }
      return await _dbHelper.getProducts();
    } catch (e) {
      debugPrint("Fetch Products Error: $e");
      return await _dbHelper.getProducts();
    }
  }

  Future<List<Product>> fetchSliderProducts() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isSlider).toList();
    }
    try {
      final res = await http.get(_u('/products?is_slider=1'), headers: _headers()).timeout(const Duration(seconds: 60
      
      ));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          list = (data is List) ? data : (data is Map ? data['data'] ?? [] : []);
        }
        return list.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      List<Product> allProducts = await _dbHelper.getProducts();
      return allProducts.where((p) => p.isFeatured).toList();
    }
    try {
      final res = await http.get(_u('/products?is_featured=1'), headers: _headers()).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          list = (data is List) ? data : (data is Map ? data['data'] ?? [] : []);
        }
        return list.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Product> addProduct({
    required String name,
    required String description,
    required String price,
    String? salePrice,
    required String category,
    required bool isFeatured,
    bool isSlider = false,
    String? scentFamily,
    String? brand,
    String? size,
    String? quantity,
    String? notesTop,
    String? notesMiddle,
    String? notesBase,
    String? badgeText,
    XFile? imageFile,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/products'));
    request.headers.addAll(_headers(token: token, multipart: true));
    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price.trim(),
      'category': category,
      'is_featured': isFeatured ? '1' : '0',
      'is_slider': isSlider ? '1' : '0',
    });
    if (salePrice != null && salePrice.isNotEmpty) request.fields['sale_price'] = salePrice.trim();
    if (quantity != null && quantity.isNotEmpty) request.fields['quantity'] = quantity.trim();
    if (scentFamily != null) request.fields['scent_family'] = scentFamily.trim();
    if (brand != null) request.fields['brand'] = brand.trim();
    if (size != null) request.fields['size'] = size.trim();
    if (notesTop != null) request.fields['notes_top'] = notesTop.trim();
    if (notesMiddle != null) request.fields['notes_middle'] = notesMiddle.trim();
    if (notesBase != null) request.fields['notes_base'] = notesBase.trim();
    if (badgeText != null) request.fields['badge_text'] = badgeText.trim();
    
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('main_image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
    }
    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Product.fromJson(decoded['data'] ?? decoded);
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
    required String category,
    required bool isFeatured,
    bool isSlider = false,
    String? scentFamily,
    String? brand,
    String? size,
    String? quantity,
    String? notesTop,
    String? notesMiddle,
    String? notesBase,
    String? badgeText,
    XFile? imageFile,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/products/$id'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields.addAll({
      'name': name,
      'description': description,
      'price': price.trim(),
      'category': category,
      'is_featured': isFeatured ? '1' : '0',
      'is_slider': isSlider ? '1' : '0',
    });
    if (salePrice != null && salePrice.isNotEmpty) request.fields['sale_price'] = salePrice.trim();
    if (quantity != null && quantity.isNotEmpty) request.fields['quantity'] = quantity.trim();
    if (scentFamily != null) request.fields['scent_family'] = scentFamily.trim();
    if (brand != null) request.fields['brand'] = brand.trim();
    if (size != null) request.fields['size'] = size.trim();
    if (notesTop != null) request.fields['notes_top'] = notesTop.trim();
    if (notesMiddle != null) request.fields['notes_middle'] = notesMiddle.trim();
    if (notesBase != null) request.fields['notes_base'] = notesBase.trim();
    if (badgeText != null) request.fields['badge_text'] = badgeText.trim();

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes('main_image', bytes, filename: imageFile.name, contentType: mimeType != null ? MediaType.parse(mimeType) : null));
    }
    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Product.fromJson(decoded['data'] ?? decoded);
    } else {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> deleteProduct({required String id, String? token}) async {
    await http.delete(_u('/products/$id'), headers: _headers(token: token)).timeout(const Duration(seconds: 30));
  }

  // ================ BANNER CRUD METHODS ================
  Future<void> createBanner({
    required String title,
    required String targetScreen,
    required String targetId,
    required XFile imageFile,
    int sortOrder = 0,
    bool isActive = true,
    String? description,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/banners'));
    request.headers.addAll(_headers(token: token, multipart: true));
    request.fields.addAll({
      'title': title,
      'target_screen': targetScreen,
      'target_id': targetId,
      'sort_order': sortOrder.toString(),
      'is_active': isActive ? '1' : '0',
    });
    if (description != null) request.fields['description'] = description;

    final bytes = await imageFile.readAsBytes();
    final mimeType = lookupMimeType(imageFile.path);
    request.files.add(http.MultipartFile.fromBytes(
      'image', 
      bytes, 
      filename: imageFile.name, 
      contentType: mimeType != null ? MediaType.parse(mimeType) : null
    ));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> updateBanner({
    required String id,
    required String title,
    required String targetScreen,
    required String targetId,
    XFile? imageFile,
    int sortOrder = 0,
    bool isActive = true,
    String? description,
    String? currentImageUrl,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/banners/$id'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields.addAll({
      'title': title,
      'target_screen': targetScreen,
      'target_id': targetId,
      'sort_order': sortOrder.toString(),
      'is_active': isActive ? '1' : '0',
    });
    if (description != null) request.fields['description'] = description;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        bytes, 
        filename: imageFile.name, 
        contentType: mimeType != null ? MediaType.parse(mimeType) : null
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> deleteBanner({required String id, String? token}) async {
    final response = await http.delete(_u('/banners/$id'), headers: _headers(token: token)).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  // ================ CATEGORY CRUD METHODS ================
  Future<void> createCategory({
    required String name,
    XFile? imageFile,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/categories'));
    request.headers.addAll(_headers(token: token, multipart: true));
    request.fields['name'] = name;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        bytes, 
        filename: imageFile.name, 
        contentType: mimeType != null ? MediaType.parse(mimeType) : null
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    XFile? imageFile,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _u('/categories/$id'));
    request.headers.addAll(_headers(token: token, multipart: true));
    
    request.fields['name'] = name;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        bytes, 
        filename: imageFile.name, 
        contentType: mimeType != null ? MediaType.parse(mimeType) : null
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  Future<void> deleteCategory({required String id, String? token}) async {
    final response = await http.delete(_u('/categories/$id'), headers: _headers(token: token)).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_parseError(response.statusCode, response.body));
    }
  }

  // ================ ADMIN ORDER METHODS ================
  Future<List<Order>> fetchAdminOrders() async {
    try {
      final response = await http.get(
        _u('/admin/orders'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          list = decoded['data'] ?? [];
        }
        return list.map((e) => Order.fromJson(e)).toList();
      } else {
        throw Exception(_parseError(response.statusCode, response.body));
      }
    } catch (e) {
      throw Exception('Failed to fetch admin orders: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final response = await http.put(
        _u('/admin/orders/$id/status'),
        headers: _headers(json: true),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(_parseError(response.statusCode, response.body));
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
