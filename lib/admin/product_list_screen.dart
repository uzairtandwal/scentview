import 'package:flutter/material.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/admin/product_form_screen.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  static const String routeName = '/admin/products';

  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _apiService.fetchProducts();
    });
  }

  Future<void> _deleteProduct(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      const String authToken = "YOUR_AUTH_TOKEN_HERE";
      try {
        await _apiService.deleteProduct(id, token: authToken);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));
        _refreshProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Color _getBadgeColor(String? text) {
    if (text == null || text.isEmpty) return Colors.blue;
    String label = text.toLowerCase();
    if (label.contains('new')) return Colors.green;
    if (label.contains('sale') || label.contains('%')) return Colors.red;
    if (label.contains('sold')) return Colors.grey;
    if (label.contains('coming soon')) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Product Management"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      onSave: _refreshProducts,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found. Add some!'));
            }

            final products = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Badge')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: products.map((product) {
                    return DataRow(cells: [
                      DataCell(
                        product.imageUrl.isNotEmpty
                            ? Image.network(ApiService.toAbsoluteUrl(product.imageUrl)!, width: 40, height: 40, fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported))
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      DataCell(Text(product.name)),
                      DataCell(
                        product.salePrice != null && product.salePrice! > 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PKR ${product.salePrice!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  Text('PKR ${product.originalPrice.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10)),
                                ],
                              )
                            : Text('PKR ${product.originalPrice.toStringAsFixed(0)}'),
                      ),
                      DataCell(
                        product.badgeText != null && product.badgeText!.isNotEmpty
                            ? Chip(
                                label: Text(product.badgeText!, style: const TextStyle(fontSize: 10)),
                                backgroundColor: _getBadgeColor(product.badgeText),
                                labelStyle: const TextStyle(color: Colors.white),
                                padding: EdgeInsets.zero,
                              )
                            : const Text('-'),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductFormScreen(
                                      product: product,
                                      onSave: _refreshProducts,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product.id.toString()),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
