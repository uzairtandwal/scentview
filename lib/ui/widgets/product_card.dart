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
    if (text == null) return Colors.blue.shade600;
    switch (text.toLowerCase()) {
      case 'best seller':
      case 'bestseller':
        return Colors.blue.shade600;
      case 'new':
      case 'new arrival':
        return Colors.green.shade600;
      case 'limited':
      case 'limited edition':
        return Colors.purple.shade600;
      case 'sale':
        return Colors.red.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool onSale = product.salePrice != null && product.salePrice! > 0;
    final bool hasBadge = product.badgeText != null && product.badgeText!.isNotEmpty;
    final bool hasImage = product.imageUrl.isNotEmpty;
    final bool isOutOfStock = product.stock != null && product.stock! == 0;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isOutOfStock ? null : onTap, // Disable tap if out of stock
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // MAIN COLUMN: image + info + stock
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== IMAGE AREA (TOP) ====
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // PRODUCT IMAGE
                        hasImage
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey.shade400,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade300,
                                  size: 48,
                                ),
                              ),
                        
                        // OUT OF STOCK OVERLAY
                        if (isOutOfStock)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ==== INFO AREA (TEXT + PRICE) ====
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // PRODUCT NAME
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                            height: 1.2,
                          ),
                        ),

                        // PRICE ROW (IMPROVED FORMATTING)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (onSale) ...[
                              // REGULAR PRICE (STRIKETHROUGH)
                              Text(
                                'Rs ${product.originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // SALE PRICE (BOLD & COLORED)
                              Text(
                                'Rs ${product.salePrice!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ] else
                              // REGULAR PRICE ONLY
                              Text(
                                'Rs ${product.originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==== STOCK STRIP (BOTTOM) - ONLY FOR LOW STOCK (1-10) ====
                if (product.stock != null && product.stock! > 0 && product.stock! <= 10)
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.orange.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.orange.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Only ${product.stock} left!',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ==== BADGE (BEST SELLER / NEW ARRIVAL) ====
            if (hasBadge && !isOutOfStock) // Don't show badge if out of stock
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(product.badgeText),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    product.badgeText!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

            // ==== FAVORITE BUTTON ====
            if (showFavorite && !isOutOfStock)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onFavoriteTap,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red.shade600 : Colors.grey.shade700,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ),
              ),

            // ==== QUICK ADD TO CART BUTTON ====
            if (showQuickAdd && onQuickAddTap != null && !isOutOfStock)
              Positioned(
                bottom: 35,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade700.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onQuickAddTap,
                    icon: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}