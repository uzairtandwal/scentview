import 'package:flutter/material.dart';

Color getBadgeColor(String? badgeText) {
  if (badgeText == null) {
    return Colors.transparent;
  }
  final text = badgeText.toLowerCase();
  if (text.contains('sold') || text.contains('stock')) {
    return Colors.grey;
  }
  if (text.contains('new')) {
    return Colors.green;
  }
  if (text.contains('sale') || text.contains('%')) {
    return Colors.redAccent;
  }
  return Colors.blue;
}