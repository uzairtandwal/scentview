import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';
import 'widgets/custom_app_bar.dart';

class MainAppScreen extends StatefulWidget {
  static const routeName = '/main-app';
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  DateTime? _lastBackPressTime;
  String _searchQuery = '';

  // ── Nav items config ──────────────────────────────────────────────────────
  static const _navItems = [
    _NavItem(label: 'Home',    icon: Iconsax.home,          activeIcon: Iconsax.home_15),
    _NavItem(label: 'Shop',    icon: Iconsax.shop,           activeIcon: Iconsax.shop5),
    _NavItem(label: 'Cart',    icon: Iconsax.shopping_cart,  activeIcon: Iconsax.shopping_cart5),
    _NavItem(label: 'Profile', icon: Iconsax.user,           activeIcon: Iconsax.user5),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) _navigateTo(args);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _navigateTo(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // ── Back press — double tap to exit ──────────────────────────────────────
  bool _handleBackPress() {
    // Not on home tab → go home
    if (_selectedIndex != 0) {
      _navigateTo(0);
      return true; // handled
    }

    // On home tab → double tap to exit
    final now = DateTime.now();
    final isSecondPress = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) <= const Duration(seconds: 2);

    if (isSecondPress) return false; // allow exit

    _lastBackPressTime = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Press back again to exit'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    return true; // handled — don't exit yet
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  // Home has its own AppBar — for other tabs we use CustomAppBar
  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 0) return null; // HomeScreen handles its own

    return CustomAppBar(
      showSearch: _selectedIndex == 1, // only Shop tab
      hintText: 'Search fragrances...',
      showLogo: _selectedIndex == 1,
      onSearchChanged: _selectedIndex == 1
          ? (val) => setState(() => _searchQuery = val)
          : null,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pages — rebuilt only when needed
    final pages = [
      const HomeScreen(),
      ShopScreen(searchQuery: _searchQuery),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: PageView(
          controller: _pageController,
          // ✅ Disable swipe — prevents accidental page changes
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _selectedIndex = i),
          children: pages,
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: _navigateTo,
          navItems: _navItems,
        ),
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> navItems;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CartService>(
      builder: (_, cart, __) {
        return NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          destinations: navItems.asMap().entries.map((entry) {
            final i    = entry.key;
            final item = entry.value;

            // Cart tab — show badge
            if (i == 2) {
              return NavigationDestination(
                icon: _CartIcon(
                  icon: item.icon,
                  count: cart.itemCount,
                  isActive: false,
                  theme: theme,
                ),
                selectedIcon: _CartIcon(
                  icon: item.activeIcon,
                  count: cart.itemCount,
                  isActive: true,
                  theme: theme,
                ),
                label: item.label,
              );
            }

            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon),
              label: item.label,
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Cart Icon with Badge ─────────────────────────────────────────────────────
class _CartIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final ThemeData theme;

  const _CartIcon({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}