import 'package:scentview/models/product_model.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'widgets/product_card.dart';
import 'product_detail_screen.dart';

class TopPicksPage extends StatefulWidget {
  static const routeName = '/top-picks';

  const TopPicksPage({super.key});

  @override
  _TopPicksPageState createState() => _TopPicksPageState();
}

class _TopPicksPageState extends State<TopPicksPage> {
  late Future<List<Product>> _productsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts();
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Price: Low to High'),
              onTap: () {
                setState(() {
                  _productsFuture = _productsFuture!.then((products) {
                    products.sort((a, b) => a.originalPrice.compareTo(b.originalPrice));
                    return products;
                  });
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Price: High to Low'),
              onTap: () {
                setState(() {
                  _productsFuture = _productsFuture!.then((products) {
                    products.sort((a, b) => b.originalPrice.compareTo(a.originalPrice));
                    return products;
                  });
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Picks of the Season')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _showSortModal,
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement filter
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: products[index],
                      isCompact: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: products[index],
                              allProducts: products,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}