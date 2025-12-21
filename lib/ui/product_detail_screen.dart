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
    final relatedProducts = allProducts.where((p) => p.id != product.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      bottomNavigationBar: ProductDetailBottomBar(product: product),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            product.imageUrl.isEmpty
                ? Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 100, color: Colors.grey),
                  )
                : Image.network(
                    product.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 16),

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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Related Products
            const Text(
              "You might also like",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final relatedProduct = relatedProducts[index];
                return ProductCard(
                  product: relatedProduct,
                  isCompact: false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: relatedProduct,
                          allProducts: allProducts,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    bool onSale = product.salePrice != null && product.salePrice! > 0;
    return onSale
        ? Row(
            children: [
              Text(
                '\$${product.originalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${product.salePrice!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
            ],
          )
        : Text(
            '\$${product.originalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          );
  }
}