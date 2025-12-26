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

  // Badge ka rang set karne ke liye chota sa function (SAME)
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
      elevation: 2, // ✅ Softer shadow
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // ✅ More rounded corners
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // ✅ Match card border
        splashColor: Colors.blue.withOpacity(0.1), // ✅ Better ripple effect
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100, width: 1), // ✅ Subtle border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================ IMAGE SECTION ================
              Expanded(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    // Product Image with better styling
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
                      child: Image.network(
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
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),

                    // ================ BADGE (IMPROVED DESIGN) ================
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
                            borderRadius: BorderRadius.circular(20), // ✅ Pill shape
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
                padding: const EdgeInsets.all(12.0), // ✅ More padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                      maxLines: 2, // ✅ Allow 2 lines for longer names
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),

                    // ================ PRICE SECTION ================
                    if (onSale)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Original Price (Striked)
                          Text(
                            '\$${product.originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Sale Price with Tag
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.red.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'SALE',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              Expanded(
                                child: Text(
                                  '\$${product.salePrice!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      // Regular Price
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    
                    // ================ RATING (OPTIONAL ADDITION) ================
                    // Agar product mein rating field hai to yeh add kar sakte hain
                    /* if (product.rating != null && product.rating! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ), */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}