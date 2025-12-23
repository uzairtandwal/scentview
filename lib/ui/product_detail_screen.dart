import 'package:flutter/material.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/ui/widgets/product_card.dart';
import 'package:scentview/widgets/product_detail_bottom_bar.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  final Product product;
  final List<Product> allProducts;

  const ProductDetailScreen({
    required this.product,
    required this.allProducts,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- RELATED PRODUCTS FILTERING LOGIC ---
    final relatedProducts = allProducts.where((p) {
      return p.categoryId == product.categoryId && p.id != product.id;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      bottomNavigationBar: ProductDetailBottomBar(product: product),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 100, color: Colors.grey),
                      )
                    : Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.red),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Price
            _buildPriceSection(context),
            const SizedBox(height: 16),

            // Description
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),

            // --- RELATED PRODUCTS SECTION ---
            if (relatedProducts.isNotEmpty) ...[
              const Text(
                "You might also like",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300, // Fixed height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final relatedProduct = relatedProducts[index];
                    return SizedBox(
                      width: 200, // Fixed width for each card
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: ProductCard(
                          product: relatedProduct,
                          isCompact: false, // Or true, depending on desired look
                          onTap: () {
                            Navigator.push( // Use push instead of pushReplacement
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: relatedProduct,
                                  allProducts: allProducts,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    bool onSale = product.salePrice != null && product.salePrice! > 0;
    return onSale
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${product.salePrice!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${product.originalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ],
          )
        : Text(
            '\$${product.originalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          );
  }
}