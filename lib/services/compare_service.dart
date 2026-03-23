import 'package:flutter/material.dart';

class CompareService with ChangeNotifier {
  final List<dynamic> _compareList = [];

  List<dynamic> get compareList => [..._compareList];

  void addToCompare(dynamic product) {
    if (_compareList.length < 2 && !_compareList.any((p) => p.id == product.id)) {
      _compareList.add(product);
      notifyListeners();
    }
  }

  void removeFromCompare(dynamic product) {
    _compareList.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  void clearCompare() {
    _compareList.clear();
    notifyListeners();
  }

  bool isInCompare(dynamic product) {
    return _compareList.any((p) => p.id == product.id);
  }
}
