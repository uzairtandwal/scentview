import 'package:flutter/material.dart';
import 'package:scentview/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isCompact;
  final VoidCallback onTap;

  const ProductCard({
    required this.product,
    required this.isCompact,
    required this.onTap,
    super.key,
  });

  // Badge ka rang set karne ke liye chota sa function
  Color _getBadgeColor(String? text) {
    if (text == null) return Colors.red;
    switch (text.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'sale':
        return Colors.red;
      case 'hot':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool onSale = product.salePrice != null && product.salePrice! > 0;
    bool hasBadge = product.badgeText != null && product.badgeText!.isNotEmpty;

    return Card(
      elevation: 4,
      // Clip.antiAlias lagana zaroori hai taake click ka animation card ke andar rahe
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // ✅ InkWell mobile touch ko behtar samajhta hai
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  // Product Image
                  product.imageUrl.isEmpty
                      ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 40))
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  // Badge (New/Sale)
                  if (hasBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(product.badgeText),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Name and Price
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (onSale)
                    Row(
                      children: [
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.salePrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '\$${product.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}