import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/product_model.dart';

class OrdersService with ChangeNotifier {
  static const _storageKey = 'orders_v1';
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders.reversed);

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

  Future<Order> addOrder(List<Product> products) async {
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
    );
    _orders.add(order);
    await _save();
    notifyListeners();
    return order;
  }
}
