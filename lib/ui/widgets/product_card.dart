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

  bool get _isOutOfStock => product.stock != null && product.stock! == 0;
  bool get _isLowStock =>
      product.stock != null && product.stock! > 0 && product.stock! <= 10;
  bool get _onSale => product.salePrice != null && product.salePrice! > 0;
  bool get _hasBadge =>
      product.badgeText != null && product.badgeText!.isNotEmpty;

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
        onTap: _isOutOfStock ? null : onTap, // ✅ Connectivity check parent karein
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Area ──────────────────────────────────
            Expanded(
              flex: isCompact ? 6 : 7,
              child: _ImageSection(
                imageUrl: imageUrl,
                isOutOfStock: _isOutOfStock,
                hasBadge: _hasBadge,
                badgeText: product.badgeText,
                showFavorite: showFavorite,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
                showQuickAdd: showQuickAdd && !_isOutOfStock,
                onQuickAddTap: onQuickAddTap,
                theme: theme,
              ),
            ),

            // ── Info Area ───────────────────────────────────
            _InfoSection(
              name: product.name,
              originalPrice: product.originalPrice,
              salePrice: _onSale ? product.salePrice : null,
              isCompact: isCompact,
              theme: theme,
            ),

            // ── Low Stock Strip ─────────────────────────────
            if (_isLowStock)
              _LowStockStrip(stock: product.stock!, theme: theme),
          ],
        ),
      ),
    );
  }
}

// ─── Image Section ────────────────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  final String? imageUrl;
  final bool isOutOfStock;
  final bool hasBadge;
  final String? badgeText;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showQuickAdd;
  final VoidCallback? onQuickAddTap;
  final ThemeData theme;

  const _ImageSection({
    required this.imageUrl,
    required this.isOutOfStock,
    required this.hasBadge,
    required this.badgeText,
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

        // Out of stock overlay
        if (isOutOfStock) const _OutOfStockOverlay(),

        // Badge
        if (hasBadge && !isOutOfStock)
          Positioned(
            top: 10,
            left: 10,
            child: _BadgeChip(text: badgeText!, theme: theme),
          ),

        // Favorite button
        if (showFavorite && !isOutOfStock)
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
class _OutOfStockOverlay extends StatelessWidget {
  const _OutOfStockOverlay();

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
            'OUT OF STOCK',
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

  const _BadgeChip({required this.text, required this.theme});

  Color _badgeColor() => switch (text.toLowerCase()) {
        'best seller' || 'bestseller' => const Color(0xFF1565C0),
        'new' || 'new arrival'        => const Color(0xFF2E7D32),
        'limited' || 'limited edition'=> const Color(0xFF6A1B9A),
        'sale'                        => const Color(0xFFC62828),
        _                             => const Color(0xFFE65100),
      };

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
  final double originalPrice;
  final double? salePrice;
  final bool isCompact;
  final ThemeData theme;

  const _InfoSection({
    required this.name,
    required this.originalPrice,
    required this.isCompact,
    required this.theme,
    this.salePrice,
  });

  @override
  Widget build(BuildContext context) {
    final onSale = salePrice != null;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (onSale) ...[
                Text(
                  'Rs ${originalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
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
                    color: theme.colorScheme.error,
                  ),
                ),
              ] else
                Text(
                  'Rs ${originalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 13 : 15,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Low Stock Strip ──────────────────────────────────────────────────────────
class _LowStockStrip extends StatelessWidget {
  final int stock;
  final ThemeData theme;

  const _LowStockStrip({required this.stock, required this.theme});

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
            'Only $stock left!',
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