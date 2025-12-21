
import 'package:flutter/material.dart';

class AdminProductLabelInput extends StatelessWidget {
  final TextEditingController controller;

  const AdminProductLabelInput({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Product Label / Badge (e.g., New, 50% Off)',
        border: OutlineInputBorder(),
        hintText: 'Enter badge text',
      ),
    );
  }
}
