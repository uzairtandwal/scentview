import 'package:flutter/material.dart';
import 'package:scentview/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isCompact;
  final VoidCallback onTap;
  final bool showFavorite;
  final bool showQuickAdd;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onQuickAddTap;

  final bool isFavorite;

  const ProductCard({
    required this.product,
    required this.isCompact,
    required this.onTap,
    this.showFavorite = true,
    this.showQuickAdd = true,
    this.onFavoriteTap,
    this.onQuickAddTap,
    this.isFavorite = false,
    super.key,
  });

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
    bool hasImage = product.imageUrl.isNotEmpty;


    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // ✅ More rounded
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================ IMAGE SECTION ================
                Expanded(
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      // Product Image
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade50,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: hasImage
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: Colors.blue.shade300,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                  size: 48,
                                ),
                              ),
                      ),

                      // ================ BADGE ================
                      if (hasBadge)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(product.badgeText),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              product.badgeText!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ================ PRODUCT INFO SECTION ================
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),

                      // ================ PRICE + RATING SECTION ================
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sale Price
                                if (onSale)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${product.originalPrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      
                                      Text(
                                        '\$${product.salePrice!.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  // Regular Price
                                  Text(
                                    '\$${product.originalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // ================ RATING ================

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ================ FLOATING ACTION BUTTONS ================
            // FAVORITE BUTTON
            if (showFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // QUICK ADD TO CART BUTTON
            if (showQuickAdd && onQuickAddTap != null)
              Positioned(
                bottom: 60,
                right: 8,
                child: GestureDetector(
                  onTap: onQuickAddTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade600.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_shopping_cart_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

            // ================ STOCK STATUS ================
            if (product.stock != null && product.stock! <= 10)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border(
                      top: BorderSide(
                        color: Colors.orange.shade100,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Only ${product.stock} left!',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}