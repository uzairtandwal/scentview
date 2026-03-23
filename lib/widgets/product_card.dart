import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scentview/models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isCompact;
  final VoidCallback onTap;
  final bool showFavorite;
  final bool showQuickAdd;

  const ProductCard({
    required this.product,
    required this.isCompact,
    required this.onTap,
    this.showFavorite = true,
    this.showQuickAdd = true,
    super.key,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;
  bool _isWishlisted = false;

  // ✅ Sale check
  bool get _onSale =>
      widget.product.salePrice != null &&
      widget.product.salePrice! > 0 &&
      widget.product.salePrice! < widget.product.price;

  // ✅ Discount % auto calculate
  int get _discountPercent {
    if (!_onSale) return 0;
    return (((widget.product.price - widget.product.salePrice!) /
                widget.product.price) *
            100)
        .round();
  }

  // ✅ Out of stock — quantity 10 se kam
  bool get _isOutOfStock => widget.product.quantity < 10;

  // ✅ Badge colors
  Color _getBadgeColor(String? text) {
    if (text == null) return Colors.blue;
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('sold') || lowerText.contains('out')) {
      return Colors.red;
    }
    if (lowerText.contains('new')) {
      return Colors.blue;
    }
    if (lowerText.contains('sale') || lowerText.contains('%')) {
      return Colors.red;
    }

    switch (lowerText) {
      case 'hot':
        return Colors.orange;
      case 'coming soon':
      case 'soon':
      case 'upcoming':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressCtrl,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: widget.isCompact ? _buildListTile() : _buildGridCard(),
      ),
    );
  }

  // ─── Grid Card ───────────────────────────────────────────────
  Widget _buildGridCard() {
    final product = widget.product;
    final bool hasBadge =
        product.badgeText != null && product.badgeText!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // ── Image ──
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey.shade50, Colors.white],
                      ),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(Iconsax.image,
                              color: Colors.grey.shade300, size: 36),
                        ),
                      ),
                    ),
                  ),

                  // ✅ Priority: OUT OF STOCK > Badge (NEW/SALE/HOT/COMING SOON)
                  if (_isOutOfStock)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildOutOfStockBadge(),
                    )
                  else if (hasBadge)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildBadge(product.badgeText!),
                    ),

                  // ── Wishlist ──
                  if (widget.showFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFavoriteButton(),
                    ),

                  // ✅ Discount % — bottom left (only if on sale & in stock)
                  if (_onSale && !_isOutOfStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: _buildDiscountBadge(),
                    ),
                ],
              ),
            ),

            // ── Name + Price ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildPriceRow(isList: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── List Tile ───────────────────────────────────────────────
  Widget _buildListTile() {
    final product = widget.product;
    final bool hasBadge =
        product.badgeText != null && product.badgeText!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // ── Image ──
            Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey.shade50,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: Center(
                          child: Icon(Iconsax.image,
                              color: Colors.grey.shade400, size: 28)),
                    ),
                  ),
                ),
                // ✅ OUT OF STOCK > Badge
                if (_isOutOfStock)
                  Positioned(
                    top: 7,
                    left: 7,
                    child: _buildOutOfStockBadge(small: true),
                  )
                else if (hasBadge)
                  Positioned(
                    top: 7,
                    left: 7,
                    child: _buildBadge(product.badgeText!, small: true),
                  ),

                // ✅ Discount badge
                if (_onSale && !_isOutOfStock)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _buildDiscountBadge(small: true),
                  ),
              ],
            ),

            // ── Details ──
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(isList: true),
                  ],
                ),
              ),
            ),

            if (widget.showQuickAdd)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildQuickAddButton(),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Badge Widgets ───────────────────────────────────────────

  // ✅ OUT OF STOCK badge
  Widget _buildOutOfStockBadge({bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 12, vertical: small ? 3 : 6),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'OUT OF STOCK',
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 7 : 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ✅ Discount % badge
  Widget _buildDiscountBadge({bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 7, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        '-$_discountPercent%',
        style: TextStyle(
            color: Colors.white,
            fontSize: small ? 9 : 10,
            fontWeight: FontWeight.w800),
      ),
    );
  }

  // ✅ Text badge (NEW / COMING SOON / SALE / HOT)
  Widget _buildBadge(String text, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: _getBadgeColor(text),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            color: Colors.white,
            fontSize: small ? 8 : 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5),
      ),
    );
  }

  // ✅ Wishlist button
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () => setState(() => _isWishlisted = !_isWishlisted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _isWishlisted ? Colors.red.shade50 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12), blurRadius: 8)
          ],
        ),
        child: Icon(
          _isWishlisted ? Iconsax.heart5 : Iconsax.heart,
          size: 16,
          color: _isWishlisted ? Colors.red : Colors.grey.shade500,
        ),
      ),
    );
  }

  // ✅ Price row — sale strikethrough + red bold
  Widget _buildPriceRow({required bool isList}) {
    final product = widget.product;
    const Color primaryColor = Color(0xFF6C63FF);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_onSale) ...[
                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade400,
                    color: Colors.grey.shade400,
                    fontSize: isList ? 11 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PKR ${product.salePrice!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isList ? 17 : 15,
                    color: Colors.red.shade600,
                  ),
                ),
              ] else
                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isList ? 17 : 15,
                    color: primaryColor,
                  ),
                ),
            ],
          ),
        ),
        if (!isList && widget.showQuickAdd) _buildQuickAddButton(),
      ],
    );
  }

  // ✅ Cart button
  Widget _buildQuickAddButton() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Iconsax.shopping_cart, size: 15, color: Colors.white),
    );
  }
}