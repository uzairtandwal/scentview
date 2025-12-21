import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import 'widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListArgs {
  final String categoryKey;
  const ProductListArgs({required this.categoryKey});
}

class ProductListScreen extends StatefulWidget {
  static const routeName = '/products';
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _firestoreService = FirestoreService();
  late final ProductListArgs _args;
  late Stream<List<Product>> _productsStream;
  late Future<Category> _categoryFuture;

  // List of local images to cycle through
  final _imagePaths = [
    'assets/images/product_11.webp',
    'assets/images/product_12.webp',
    'assets/images/product_13.webp',
    'assets/images/product_14.webp',
    'assets/images/product_15.webp',
    'assets/images/product_16.webp',
    'assets/images/product_17.webp',
    'assets/images/product_18.webp',
    'assets/images/product_19.webp',
    'assets/images/product_20.webp',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments here as it's safer than initState
    _args = ModalRoute.of(context)!.settings.arguments as ProductListArgs;
    _productsStream = _firestoreService.getProductsByCategoryStream(
      _args.categoryKey,
    );
    _categoryFuture = _firestoreService.getCategory(_args.categoryKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Category>(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Products');
            }
            return Text(snapshot.data!.name);
          },
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products found in this category.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // Create a new product instance with the local image path
              final productWithLocalImage = product.copyWith(
                imageUrl: _imagePaths[index % _imagePaths.length],
              );
              return ProductCard(
                product: productWithLocalImage,
                isCompact: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: productWithLocalImage,
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
    );
  }
}
