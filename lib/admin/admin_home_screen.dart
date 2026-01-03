import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/services/api_service.dart';
import 'package:scentview/services/orders_service.dart';
import 'package:scentview/services/auth_service.dart'; // ✅ Added for Logout
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;

// ================ CORRECT IMPORTS ================ 
import 'package:scentview/admin/product_list_screen.dart';
import 'package:scentview/admin/categories_screen.dart';
import 'package:scentview/admin/product_form_screen.dart';
import 'package:scentview/admin/banners_screen.dart';
import 'package:scentview/admin/add_edit_banner_screen.dart';
import 'package:scentview/admin/add_edit_category_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String routeName = '/admin/dashboard';
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;
  late Future<List<app_category.Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _productsFuture = _apiService.fetchProducts();
      _categoriesFuture = _apiService.fetchCategories();
      Provider.of<OrdersService>(context, listen: false).fetchOrders();
    });
  }

  // ✅ New Method: Admin se User side switch karne ke liye
  void _logoutAndVisitShop(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // 1. Admin session clear karein
    await authService.signOut();
    
    // 2. Fresh redirect to home logic (App automatically normal user side dikhayegi)
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home-logic', (route) => false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switched to Shop View (User Mode)'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    }
  }

  // ================ NAVIGATION METHODS ================ 
  void _navigateToProducts(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductFormScreen()));
  }

  void _navigateToBanners(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const BannersScreen()));
  }

  void _navigateToAddBanner(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditBannerScreen()));
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditCategoryScreen()));
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is coming soon!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersService>(
      builder: (context, ordersService, child) {
        
        final List<Map<String, dynamic>> stats = [
          {
            'title': 'Total Products', 
            'future': _productsFuture, 
            'icon': Icons.shopping_bag_rounded, 
            'color': Colors.blue,
            'onTap': () => _navigateToProducts(context),
          },
          {
            'title': 'Total Categories', 
            'future': _categoriesFuture, 
            'icon': Icons.category_rounded, 
            'color': Colors.green,
            'onTap': () => _navigateToCategories(context),
          },
          {
            'title': 'Total Orders', 
            'value': ordersService.orders.length.toString(), 
            'icon': Icons.receipt_long_rounded, 
            'color': Colors.orange,
            'onTap': () => _showComingSoon(context, 'Orders Management'),
          },
          {
            'title': 'Revenue', 
            'value': '\$${ordersService.orders.fold<double>(0, (sum, item) => sum + item.total).toStringAsFixed(2)}', 
            'icon': Icons.attach_money_rounded, 
            'color': Colors.green,
            'onTap': () => _showComingSoon(context, 'Revenue Reports'),
          },
          {
            'title': 'Pending Orders', 
            'value': ordersService.orders.where((o) => o.status.toLowerCase() == 'pending').length.toString(), 
            'icon': Icons.pending_actions_rounded, 
            'color': Colors.red,
            'onTap': () => _showComingSoon(context, 'Pending Orders'),
          },
        ];

        final List<Map<String, dynamic>> quickActions = [
          {'title': 'Add Product', 'icon': Icons.add_circle_outline_rounded, 'onTap': () => _navigateToAddProduct(context)},
          {'title': 'Manage Categories', 'icon': Icons.edit_note_rounded, 'onTap': () => _navigateToCategories(context)},
          {'title': 'Upload Banner', 'icon': Icons.image_outlined, 'onTap': () => _navigateToAddBanner(context)},
          {'title': 'View Reports', 'icon': Icons.analytics_outlined, 'onTap': () => _showComingSoon(context, 'Analytics Reports')},
        ];

        return Scaffold(
          // ✅ AppBar with Visit Shop & Logout buttons
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text('Admin Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            actions: [
              TextButton.icon(
                onPressed: () => _logoutAndVisitShop(context),
                icon: const Icon(Icons.shopping_basket_outlined, color: Colors.pinkAccent),
                label: const Text('Visit Shop', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                onPressed: () => _logoutAndVisitShop(context),
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AdminLayout(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back, Admin!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Here\'s what\'s happening today', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),

                  // Stats Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.4,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final stat = stats[index];
                        if (stat.containsKey('future')) {
                          return FutureBuilder<List<dynamic>>(
                            future: stat['future'],
                            builder: (context, snapshot) => _buildStatCard(context, title: stat['title'], value: snapshot.hasData ? snapshot.data!.length.toString() : '...', icon: stat['icon'], color: stat['color'], isLoading: snapshot.connectionState == ConnectionState.waiting, onTap: stat['onTap']),
                          );
                        }
                        return _buildStatCard(context, title: stat['title'], value: stat['value'], icon: stat['icon'], color: stat['color'], isLoading: false, onTap: stat['onTap']);
                      }, childCount: stats.length),
                    ),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final action = quickActions[index];
                        return _buildQuickActionCard(context, title: action['title'], icon: action['icon'], onTap: action['onTap']);
                      }, childCount: quickActions.length),
                    ),
                  ),

                  // Recent Activity
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text('Recent Orders', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  _buildRecentOrdersList(context, ordersService),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================ ALL WIDGET HELPERS ================

  Widget _buildRecentOrdersList(BuildContext context, OrdersService ordersService) {
    if (ordersService.orders.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No orders yet.'),
      )));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final order = ordersService.orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
            title: Text('Order #${order.id}'),
            subtitle: Text('\$${order.total.toStringAsFixed(2)} - ${order.status}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _showComingSoon(context, 'Order Management'),
          ),
        );
      }, childCount: ordersService.orders.length > 5 ? 5 : ordersService.orders.length),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required bool isLoading, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}