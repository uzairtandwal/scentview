import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
// import '../../widgets/app_logo.dart'; // 👈 Isay hata dein (Duplicate hai)
import 'app_logo.dart';
import '../cart_screen.dart';
import '../profile_screen.dart';
import '../search_results_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch;
  final String? hintText;
  final VoidCallback? onMenuTap;
  final VoidCallback? onRefresh;
  final Function(String)? onSearchChanged;
  final List<Color>? gradientColors;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    this.showSearch = true,
    this.hintText,
    this.onMenuTap,
    this.onRefresh,
    this.onSearchChanged,
    this.gradientColors,
    this.iconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = iconColor ?? theme.colorScheme.onPrimary;

    final List<Color> colors = gradientColors ??
        [
          primary,
          Color.lerp(primary, Colors.black, 0.15) ?? primary,
        ];

    // ✅ Status bar icons white on gradient
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // ── 1. MENU BUTTON ──────────────────────────────
                  Builder(
                    builder: (menuContext) => _AppBarButton(
                      icon: Icons.menu_rounded,
                      iconColor: onPrimary,
                      onTap: onMenuTap ?? () => Scaffold.of(menuContext).openDrawer(),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // ── 2. REFRESH BUTTON ───────────────────────────
                  _AppBarButton(
                    icon: Icons.refresh_rounded,
                    iconColor: onPrimary,
                    onTap: onRefresh,
                  ),

                  const SizedBox(width: 8),

                  // ── 3. SEARCH BAR ───────────────────────────────
                  if (showSearch)
                    Expanded(
                      child: _SearchBar(
                        hintText: hintText ?? 'Search products...',
                        onChanged: onSearchChanged,
                        onSubmitted: (query) {
                          if (query.trim().isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              SearchResultsScreen.routeName,
                              arguments: query.trim(),
                            );
                          }
                        },
                      ),
                    ),

                  const SizedBox(width: 8),

                  // ── 4. ACTION BUTTONS ───────────────────────────
                  Consumer<CartService>(
                    builder: (_, cart, __) => _AppBarButton(
                      icon: Icons.shopping_cart_outlined,
                      iconColor: onPrimary,
                      badgeCount: cart.itemCount,
                      onTap: () =>
                          Navigator.pushNamed(context, CartScreen.routeName),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _AppBarButton(
                    icon: Icons.person_outline_rounded,
                    iconColor: onPrimary,
                    onTap: () =>
                        Navigator.pushNamed(context, ProfileScreen.routeName),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const _SearchBar({
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: primary,
              size: 18,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 0), // Fix alignment
          ),
        ),
      ),
    );
  }
}

// ─── AppBar Button (consistent across all icons) ──────────────────────────────
class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final int badgeCount;

  const _AppBarButton({
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Button ──
        Material(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            splashColor: iconColor.withValues(alpha: 0.2),
            highlightColor: iconColor.withValues(alpha: 0.1),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),

        // ── Badge ──
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
