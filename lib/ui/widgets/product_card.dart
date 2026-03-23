import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/services/api_service.dart';

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
    super.key,
    required this.product,
    required this.onTap,
    this.isCompact = false,
    this.showFavorite = true,
    this.showQuickAdd = true,
    this.onFavoriteTap,
    this.onQuickAddTap,
    this.isFavorite = false,
  });

  bool get _isOutOfquantity => product.quantity == 0;
  bool get _isLowquantity =>
      product.quantity > 0 && product.quantity <= 10;
  
  bool get _onSale =>
      product.salePrice != null &&
      product.salePrice! > 0 &&
      product.salePrice! < product.price;

  int get _discountPercent {
    if (!_onSale) return 0;
    return (((product.price - product.salePrice!) / product.price) * 100).round();
  }

  bool get _hasBadge =>
      (product.badgeText != null && product.badgeText!.isNotEmpty) || _onSale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? imageUrl = ApiService.toAbsoluteUrl(product.imageUrl);

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _isOutOfquantity ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Area ──────────────────────────────────
            Expanded(
              flex: isCompact ? 6 : 7,
              child: _ImageSection(
                imageUrl: imageUrl,
                isOutOfquantity: _isOutOfquantity,
                hasBadge: _hasBadge,
                badgeText: _onSale ? '${_discountPercent}% OFF' : product.badgeText,
                isSaleBadge: _onSale,
                showFavorite: showFavorite,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
                showQuickAdd: showQuickAdd && !_isOutOfquantity,
                onQuickAddTap: onQuickAddTap,
                theme: theme,
              ),
            ),

            // ── Info Area ───────────────────────────────────
            _InfoSection(
              name: product.name,
              price: product.price,
              salePrice: product.salePrice,
              onSale: _onSale,
              isCompact: isCompact,
              theme: theme,
            ),

            // ── Low quantity Strip ─────────────────────────────
            if (_isLowquantity)
              _LowquantityStrip(quantity: product.quantity, theme: theme),
          ],
        ),
      ),
    );
  }
}

// ─── Image Section ────────────────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  final String? imageUrl;
  final bool isOutOfquantity;
  final bool hasBadge;
  final String? badgeText;
  final bool isSaleBadge;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showQuickAdd;
  final VoidCallback? onQuickAddTap;
  final ThemeData theme;

  const _ImageSection({
    required this.imageUrl,
    required this.isOutOfquantity,
    required this.hasBadge,
    required this.badgeText,
    this.isSaleBadge = false,
    required this.showFavorite,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.showQuickAdd,
    required this.onQuickAddTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Product image
        _ProductImage(imageUrl: imageUrl, theme: theme),

        // Out of Stock overlay
        if (isOutOfquantity) const _OutOfquantityOverlay(),

        // Badge
        if (hasBadge)
          Positioned(
            top: 10,
            left: 10,
            child: _BadgeChip(text: badgeText!, theme: theme, isSale: isSaleBadge),
          ),

        // Favorite button
        if (showFavorite && !isOutOfquantity)
          Positioned(
            top: 8,
            right: 8,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onTap: onFavoriteTap,
              theme: theme,
            ),
          ),

        // Quick add button
        if (showQuickAdd && onQuickAddTap != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: _QuickAddButton(onTap: onQuickAddTap!, theme: theme),
          ),
      ],
    );
  }
}

// ─── Product Image ────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final ThemeData theme;

  const _ProductImage({required this.imageUrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
    );

    final errorWidget = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 40,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return errorWidget;

    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => errorWidget,
    );
  }
}

// ─── Out of Stock Overlay ─────────────────────────────────────────────────────
class _OutOfquantityOverlay extends StatelessWidget {
  const _OutOfquantityOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Out of Stock',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final String text;
  final ThemeData theme;
  final bool isSale;

  const _BadgeChip({required this.text, required this.theme, this.isSale = false});

  Color _badgeColor() {
    if (isSale) return const Color(0xFFC62828); // Red for Sale
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('sold') || lowerText.contains('out')) {
      return const Color(0xFFC62828); // Red for Sold/Out
    }
    if (lowerText.contains('new')) {
      return const Color(0xFF1565C0); // Blue for New
    }
    if (lowerText.contains('sale') || lowerText.contains('%')) {
      return const Color(0xFFC62828); // Red for Sale
    }

    return switch (lowerText) {
      'best seller' || 'bestseller' => const Color(0xFFE65100), // Orange
      'limited' || 'limited edition'=> const Color(0xFF6A1B9A), // Purple
      _                             => const Color(0xFFE65100), // Default Orange
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _badgeColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Favorite Button ──────────────────────────────────────────────────────────
class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? const Color(0xFFC62828) : Colors.grey.shade600,
            size: 17,
          ),
        ),
      ),
    );
  }
}

// ─── Quick Add Button ─────────────────────────────────────────────────────────
class _QuickAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final ThemeData theme;

  const _QuickAddButton({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Material(
      color: primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: primary.withValues(alpha: 0.45),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.add_shopping_cart_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ─── Info Section ─────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String name;
  final double price;
  final double? salePrice;
  final bool onSale;
  final bool isCompact;
  final ThemeData theme;

  const _InfoSection({
    required this.name,
    required this.price,
    this.salePrice,
    this.onSale = false,
    required this.isCompact,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.fromLTRB(12, isCompact ? 6 : 8, 12, isCompact ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1.1,
            ),
          ),

          SizedBox(height: isCompact ? 3 : 5),

          // Price row
          if (onSale) ...[
            Row(
              children: [
                Text(
                  'Rs ${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Rs ${salePrice!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 13 : 15,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Rs ${price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isCompact ? 13 : 15,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Low quantity Strip ──────────────────────────────────────────────────────────
class _LowquantityStrip extends StatelessWidget {
  final int quantity;
  final ThemeData theme;

  const _LowquantityStrip({required this.quantity, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 13,
            color: Color(0xFFE65100),
          ),
          const SizedBox(width: 4),
          Text(
            'Only $quantity left!',
            style: const TextStyle(
              color: Color(0xFFE65100),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
