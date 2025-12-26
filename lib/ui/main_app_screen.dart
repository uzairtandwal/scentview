import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
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

  // List of pages to be displayed
  final List<Widget> _pages = [
    const HomeScreen(),
    const ShopScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  // Bottom navigation bar items data
  final List<_NavItemData> _navItemsData = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItemData(
      icon: Icons.store_outlined,
      activeIcon: Icons.store_rounded,
      label: 'Shop',
    ),
    _NavItemData(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'Cart',
      showBadge: true,
    ),
    _NavItemData(
      icon: Icons.person_outlined,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the same tab, scroll to top if possible
      _scrollToTop();
    } else {
      setState(() {
        _selectedIndex = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _scrollToTop() {
    // This method can be expanded to scroll each page to top
    // Currently, it's a placeholder for future enhancement
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    
    // If on home screen, show exit confirmation
    if (_selectedIndex == 0) {
      if (_lastBackPressTime == null ||
          now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Press back again to exit',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
        return false;
      }
      return true;
    } else {
      // If not on home screen, go to home screen
      setState(() {
        _selectedIndex = 0;
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // Custom App Bar with dynamic title
        appBar: _buildCustomAppBar(),
        
        // PageView for smooth horizontal navigation
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: const BouncingScrollPhysics(),
          children: _pages,
        ),
        
        // Official Bottom Navigation Bar (Standard Design)
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // ================ CUSTOM APP BAR ================
  PreferredSizeWidget _buildCustomAppBar() {
    // Hide app bar on home screen for cleaner look
    if (_selectedIndex == 0) {
      return const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox(),
      );
    }
    
    // Show custom app bar on other screens
    return CustomAppBar(
      showSearch: _selectedIndex == 1, // Show search only on Shop screen
      hintText: _getAppBarHintText(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      showLogo: _selectedIndex == 1, // Show logo on Shop screen
    );
  }

  String _getAppBarHintText() {
    switch (_selectedIndex) {
      case 1: return 'Search products...';
      case 2: return 'Search in cart...';
      case 3: return 'Search profile...';
      default: return 'Search...';
    }
  }

  // ================ OFFICIAL BOTTOM NAVIGATION BAR ================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 
                  ? Icons.home_rounded 
                  : Icons.home_outlined,
                size: 24,
              ),
              label: 'Home',
              tooltip: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1 
                  ? Icons.store_rounded 
                  : Icons.store_outlined,
                size: 24,
              ),
              label: 'Shop',
              tooltip: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _selectedIndex == 2 
                      ? Icons.shopping_cart_rounded 
                      : Icons.shopping_cart_outlined,
                    size: 24,
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.itemCount > 9 ? '9+' : cart.itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
              tooltip: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3 
                  ? Icons.person_rounded 
                  : Icons.person_outlined,
                size: 24,
              ),
              label: 'Profile',
              tooltip: 'Profile',
            ),
          ],
        );
      },
    );
  }
}

// ================ NAVIGATION ITEM DATA CLASS ================
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
  });
}