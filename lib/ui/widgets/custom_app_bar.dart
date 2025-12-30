import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../cart_screen.dart';
import '../profile_screen.dart';
import '../search_results_screen.dart';
import 'app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch;
  final String? hintText;
  final Color? backgroundColor;
  final bool showLogo;
  final VoidCallback? onMenuTap; // <-- ADDED FOR MENU
  
  const CustomAppBar({
    super.key,
    this.showSearch = true,
    this.hintText,
    this.backgroundColor,
    this.showLogo = true,
    this.onMenuTap, // <-- ADDED
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = TextEditingController();
    
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // ================ MENU BUTTON (HAMBURGER ICON) ================
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Menu',
              onPressed: onMenuTap ?? () {
                // Default behavior: open drawer if available
                Scaffold.of(context).openDrawer();
              },
              splashRadius: 24,
            ),
          ),
          
          // ================ SEARCH BAR ================
          if (showSearch)
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText ?? 'Search products...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      filled: false,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        searchController.clear();
                        Navigator.pushNamed(
                          context,
                          SearchResultsScreen.routeName,
                          arguments: query.trim(),
                        );
                      }
                    },
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ),
            ),
          
          // ================ APP LOGO ================
          if (showLogo)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: AppLogo(
                size: 38,
                backgroundColor: Colors.white.withOpacity(0.1),
                tintColor: Colors.white,
                padding: const EdgeInsets.all(6),
              ),
            ),
        ],
      ),
      // ================ ACTION BUTTONS ================
      actions: [
        // CART BUTTON
        Consumer<CartService>(
          builder: (context, cart, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Cart',
                    onPressed: () =>
                        Navigator.pushNamed(context, CartScreen.routeName),
                    splashRadius: 24,
                  ),
                ),
                
                // CART BADGE
                if (cart.itemCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        cart.itemCount > 9 ? '9+' : cart.itemCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        
        const SizedBox(width: 4),
        
        // PROFILE BUTTON
        Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.pushNamed(context, ProfileScreen.routeName),
            splashRadius: 24,
          ),
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}