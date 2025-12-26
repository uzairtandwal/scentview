import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartService with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  double get totalPrice {
    return _items.fold(0.0, (sum, current) => sum + current.originalPrice);
  }

  int get itemCount => _items.length;

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final currentQuantity = getQuantity(product);

    if (quantity < currentQuantity) {
      // Remove items
      for (int i = 0; i < currentQuantity - quantity; i++) {
        _items.removeWhere((item) => item.id == product.id);
      }
    } else if (quantity > currentQuantity) {
      // Add items
      for (int i = 0; i < quantity - currentQuantity; i++) {
        _items.add(product);
      }
    } else if (quantity == 0) {
      // Remove all instances
      _items.removeWhere((item) => item.id == product.id);
    }
    notifyListeners();
  }

  int getQuantity(Product product) {
    return _items.where((item) => item.id == product.id).length;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
