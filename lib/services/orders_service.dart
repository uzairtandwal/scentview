import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // ✅ API call ke liye
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/product_model.dart';
import 'api_service.dart'; // ✅ Auth token lene ke liye

class OrdersService with ChangeNotifier {
  static const _storageKey = 'orders_v1';
  final List<Order> _orders = [];
  final String _baseUrl = 'http://scentview.alwaysdata.net'; // ✅ Aapki API base URL

  List<Order> get orders => List.unmodifiable(_orders.reversed);

  // ✅ 1. API se Orders Load karne ka naya tareeqa
  Future<void> fetchOrders() async {
    final token = ApiService.authToken;
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
        _orders.clear();
        _orders.addAll(list.map(Order.fromJson));
        notifyListeners();
        _save(); // Local backup ke liye
      }
    } catch (e) {
      if (kDebugMode) print('Fetch Orders Error: $e');
    }
  }

  // Purana local load function (Backup ke liye)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _orders
        ..clear()
        ..addAll(list.map(Order.fromJson));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_orders.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // ✅ 2. Order ko Laravel API par bhejne ka function
  Future<Order?> placeOrder({
    required List<Product> products,
    required String paymentMethod,
    required String shippingAddress,
    required String phoneNumber, // ✅ Phone number add kiya
  }) async {
    final token = ApiService.authToken;
    if (token == null) return null;

    // Items ko Laravel ke format mein taiyar karna
    final List<Map<String, dynamic>> orderItems = products.map((p) {
      return {
        'product_id': p.id,
        'quantity': 1, // Filhal default 1, agar quantity handle karni hai to p.quantity use karein
        'price': p.salePrice ?? p.originalPrice,
      };
    }).toList();

    final total = products.fold<double>(
      0.0,
      (sum, p) => sum + (p.salePrice ?? p.originalPrice),
    );

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'total_amount': total,
          'shipping_address': shippingAddress,
          'phone_number': phoneNumber,
          'payment_method': paymentMethod,
          'items': orderItems,
        }),
      );

      if (response.statusCode == 201) {
        // Agar Laravel ne order save kar liya
        final data = jsonDecode(response.body);
        final newOrder = Order(
          id: data['order_id'].toString(),
          createdAt: DateTime.now(),
          items: products.map((p) => OrderItem.fromProduct(p)).toList(),
          total: total,
          paymentMethod: paymentMethod,
          shippingAddress: shippingAddress,
        );

        _orders.add(newOrder);
        await _save();
        notifyListeners();
        return newOrder;
      } else {
        if (kDebugMode) print('Server Error: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Place Order Error: $e');
      return null;
    }
  }

  // Purana local add function (Aapki logic ke mutabiq detail rakhi hai)
  Future<Order> addOrder(List<Product> products, {required String paymentMethod, required String shippingAddress}) async {
    final items = products.map((p) => OrderItem.fromProduct(p)).toList();
    final total = items.fold<double>(
      0.0,
      (sum, i) => sum + (i.price * i.quantity),
    );
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      items: items,
      total: total,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
    );
    _orders.add(order);
    await _save();
    notifyListeners();
    return order;
  }
}