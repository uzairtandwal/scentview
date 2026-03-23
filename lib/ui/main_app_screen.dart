import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../admin/admin_home_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'product_detail_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastBackPressTime;
  String _searchQuery = '';
  final ApiService _api = ApiService();
  bool _hasShownSalePopup = false;

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

  // ── Refresh Logic ─────────────────────────────────────────────────────────
  Future<void> _handleGlobalRefresh() async {
    _hasShownSalePopup = false;
    setState(() {}); // Trigger rebuild of children
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Fetch products to show sale popup
    try {
      final products = await _api.fetchProducts();
      if (products.isNotEmpty) {
        _showSalePopupIfNeeded(products);
      }
    } catch (_) {}
  }

  void _showSalePopupIfNeeded(List<Product> products) {
    if (_hasShownSalePopup) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || products.isEmpty || _hasShownSalePopup) return;
      final saleProducts = products
          .where((p) =>
              p.salePrice != null && p.salePrice! > 0 && p.salePrice! < p.price)
          .toList();
      if (saleProducts.isEmpty) return;
      
      _hasShownSalePopup = true;
      _showSaleDialog(saleProducts.first, products);
    });
  }

  void _showSaleDialog(Product product, List<Product> allProducts) {
    final discount =
        ((product.price - product.salePrice!) / product.price * 100).round();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sale',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.82, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => SaleDialog( // Assuming SaleDialog is accessible or I'll move it
        product: product,
        discount: discount,
        onViewDeal: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                allProducts: allProducts,
              ),
            ),
          );
        },
      ),
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
  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    List<Color> gradientColors;
    switch (_selectedIndex) {
      case 2: // Cart
        gradientColors = [const Color(0xFF059669), const Color(0xFF064E3B)];
        break;
      case 3: // Profile
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
        break;
      default: // Home & Shop
        gradientColors = [primary, Color.lerp(primary, Colors.black, 0.15) ?? primary];
    }

    return CustomAppBar(
      showSearch: _selectedIndex == 1 || _selectedIndex == 0,
      hintText: _selectedIndex == 0 ? 'Search products...' : 'Search fragrances...',
      onRefresh: _handleGlobalRefresh,
      gradientColors: gradientColors,
      onSearchChanged: (_selectedIndex == 0 || _selectedIndex == 1)
          ? (val) => setState(() => _searchQuery = val)
          : null,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Pages — rebuilt only when needed
    final pages = [
      HomeScreen(searchQuery: _searchQuery),
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
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
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

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    final user = Provider.of<AuthService>(context).currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Guest'),
            accountEmail: Text(user?.email ?? 'Login for full access'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name?[0].toUpperCase() ?? 'G',
                style: TextStyle(fontSize: 24, color: theme.colorScheme.primary),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.shopping_cart),
            title: const Text('My Cart'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(2);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.user),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo(3);
            },
          ),
          const Divider(),
          if (user?.role == 'admin')
            ListTile(
              leading: const Icon(Iconsax.setting_2, color: Colors.purple),
              title: const Text('Admin Panel', style: TextStyle(color: Colors.purple)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AdminHomeScreen.routeName);
              },
            ),
        ],
      ),
    );
  }
}

// ─── Sale Dialog (Internal for MainAppScreen) ─────────────────────────────────
// Copied from HomeScreen for global use
class SaleDialog extends StatefulWidget {
  final Product product;
  final int discount;
  final VoidCallback onViewDeal;

  const SaleDialog({
    super.key,
    required this.product,
    required this.discount,
    required this.onViewDeal,
  });

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late Timer _timer;
  int _secondsLeft = 2 * 3600 + 47 * 60 + 33;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { if (_secondsLeft > 0) _secondsLeft--; else _timer.cancel(); });
    });
  }

  @override
  void dispose() { _pulseCtrl.dispose(); _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    const fireRed = Color(0xFFE53935);
    const fireOrange = Color(0xFFFF6D00);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: 48),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: fireRed.withOpacity(0.3), blurRadius: 48, offset: const Offset(0, 20))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 16, 14),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFFF6D00)])),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('LIMITED TIME SALE!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: fireRed.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Image.network(widget.product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Iconsax.shop, color: fireRed)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Rs ${widget.product.price.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                          Text('Rs ${widget.product.salePrice!.toStringAsFixed(0)}', style: const TextStyle(color: fireRed, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: ElevatedButton(
                    onPressed: widget.onViewDeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fireRed, foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('GRAB THE DEAL!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
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
