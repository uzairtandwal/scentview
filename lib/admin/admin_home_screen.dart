import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/services/api_service.dart';
import 'package:scentview/services/orders_service.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;

import 'package:scentview/admin/product_list_screen.dart';
import 'package:scentview/admin/categories_screen.dart';
import 'package:scentview/admin/product_form_screen.dart';
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

  static const Color _bg       = Color(0xFFF7F8FC);
  static const Color _white    = Colors.white;
  static const Color _primary  = Color(0xFFFF6B9D);
  static const Color _textDark = Color(0xFF1A1D2E);
  static const Color _textSub  = Color(0xFF9094A6);

  // ── Dummy Orders (jab tak real DB na aaye) ─────────────────────
  final List<Map<String, dynamic>> _dummyOrders = [
    {'id': '#1001', 'user': 'Ahmed Khan',    'product': 'Rose Perfume',   'rate': '\$45.00', 'address': 'Lahore, Punjab',   'status': 'Pending'},
    {'id': '#1002', 'user': 'Sara Ali',      'product': 'Oud Musk',       'rate': '\$78.00', 'address': 'Karachi, Sindh',   'status': 'Completed'},
    {'id': '#1003', 'user': 'Bilal Raza',    'product': 'Jasmine Essence','rate': '\$32.00', 'address': 'Islamabad',        'status': 'Pending'},
    {'id': '#1004', 'user': 'Hina Shafiq',   'product': 'Amber Wood',     'rate': '\$95.00', 'address': 'Faisalabad',       'status': 'Cancelled'},
    {'id': '#1005', 'user': 'Usman Tariq',   'product': 'Blue Ocean',     'rate': '\$55.00', 'address': 'Multan, Punjab',   'status': 'Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _productsFuture   = _apiService.fetchProducts();
      _categoriesFuture = _apiService.fetchCategories();
      Provider.of<OrdersService>(context, listen: false).fetchOrders();
    });
  }

  void _logoutAndVisitShop(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home-logic', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Switched to Shop View'), backgroundColor: Color(0xFFFF6B9D)),
      );
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon'),
        content: Text('$feature jald aa raha hai!'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Color(0xFFFF6B9D))))],
      ),
    );
  }

  void _nav(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersService>(
      builder: (context, ordersService, _) {

        // ── Stats ──────────────────────────────────────────────────
        final stats = [
          _StatItem(title: 'Products',   future: _productsFuture,   icon: Icons.shopping_bag_rounded,   iconBg: const Color(0xFFE8F0FE), iconColor: const Color(0xFF4A6CF7), onTap: () => _nav(context, const ProductListScreen())),
          _StatItem(title: 'Categories', future: _categoriesFuture, icon: Icons.category_rounded,        iconBg: const Color(0xFFE6F9F0), iconColor: const Color(0xFF27AE60), onTap: () => _nav(context, const CategoriesScreen())),
          _StatItem(title: 'Orders',     value: ordersService.orders.isEmpty ? _dummyOrders.length.toString() : ordersService.orders.length.toString(), icon: Icons.receipt_long_rounded,    iconBg: const Color(0xFFFFF3E0), iconColor: const Color(0xFFF39C12), onTap: () => _showComingSoon(context, 'Orders Management')),
          _StatItem(title: 'Revenue',    value: '\$${ordersService.orders.fold<double>(0, (s, o) => s + o.total).toStringAsFixed(0)}', icon: Icons.attach_money_rounded,    iconBg: const Color(0xFFFCE4EC), iconColor: _primary, onTap: () => _showComingSoon(context, 'Revenue Reports')),
          _StatItem(title: 'Pending',    value: ordersService.orders.where((o) => o.status.toLowerCase() == 'pending').length.toString(), icon: Icons.pending_actions_rounded, iconBg: const Color(0xFFFDEDED), iconColor: const Color(0xFFE74C3C), onTap: () => _showComingSoon(context, 'Pending Orders')),
        ];

        // ── Quick Actions (4 items — 2x2 grid) ─────────────────────
        final actions = [
          _ActionItem(title: 'Add Product',   subtitle: 'Naya product',  icon: Icons.add_box_rounded,            color: const Color(0xFF4A6CF7), onTap: () => _nav(context, const ProductFormScreen())),
          _ActionItem(title: 'Categories',    subtitle: 'Manage karein', icon: Icons.folder_special_rounded,     color: const Color(0xFF27AE60), onTap: () => _nav(context, const CategoriesScreen())),
          _ActionItem(title: 'Add Banner',    subtitle: 'Upload karein', icon: Icons.add_photo_alternate_rounded,color: _primary,                onTap: () => _nav(context, const AddEditBannerScreen())),
          _ActionItem(title: 'Reports',       subtitle: 'Analytics',     icon: Icons.bar_chart_rounded,          color: const Color(0xFFF39C12), onTap: () => _showComingSoon(context, 'Analytics Reports')),
        ];

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _white,
            elevation: 0,
            centerTitle: false,
            title: const Text('Dashboard', style: TextStyle(color: Color(0xFF1A1D2E), fontWeight: FontWeight.w800, fontSize: 20)),
            actions: [
              TextButton.icon(
                onPressed: () => _logoutAndVisitShop(context),
                icon: const Icon(Icons.storefront_outlined, color: Color(0xFFFF6B9D), size: 18),
                label: const Text('Shop', style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.w700)),
              ),
              IconButton(icon: const Icon(Icons.logout_rounded, color: Color(0xFF9094A6)), onPressed: () => _logoutAndVisitShop(context), tooltip: 'Logout'),
              const SizedBox(width: 6),
            ],
          ),
          body: AdminLayout(
            child: RefreshIndicator(
              color: _primary,
              onRefresh: () async => _loadData(),
              child: CustomScrollView(
                slivers: [

                  // ── Welcome Banner ───────────────────────────────
                  SliverToBoxAdapter(child: _buildHeader()),

                  // ── Stats Grid ───────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        // FIX 1: childAspectRatio badha diya — overflow band
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.35,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _buildStatCard(stats[i]),
                        childCount: stats.length,
                      ),
                    ),
                  ),

                  // ── Quick Actions Title ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E))),
                    ),
                  ),

                  // FIX 2: Quick Actions — 2x2 Grid (2 cards per row)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.6,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _buildActionCard(actions[i]),
                        childCount: actions.length,
                      ),
                    ),
                  ),

                  // ── Recent Orders Title ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: const Text('Recent Orders', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E))),
                    ),
                  ),

                  // FIX 3: Proper Table for Orders
                  SliverToBoxAdapter(child: _buildOrdersTable()),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Welcome Banner ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back! 👋', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Aaj ka overview neeche dekhein', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // ─── Stat Card (FIX 1: overflow band kiya) ────────────────────
  Widget _buildStatCard(_StatItem stat) {
    Widget valueWidget = stat.future != null
        ? FutureBuilder<List<dynamic>>(
            future: stat.future,
            builder: (_, snap) => Text(
              snap.hasData ? snap.data!.length.toString() : (snap.hasError ? '–' : '...'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
              overflow: TextOverflow.ellipsis,
            ),
          )
        : Text(
            stat.value ?? '0',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
            overflow: TextOverflow.ellipsis,
          );

    return GestureDetector(
      onTap: stat.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: stat.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(stat.icon, color: stat.iconColor, size: 18),
            ),
            // Value + title — flex se overflow nahi hoga
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                valueWidget,
                const SizedBox(height: 2),
                Text(
                  stat.title,
                  style: const TextStyle(color: Color(0xFF9094A6), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Action Card (FIX 2: 2x2 grid style) ────────────────
  Widget _buildActionCard(_ActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: action.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(action.title,   style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1D2E)), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(action.subtitle,style: const TextStyle(fontSize: 11, color: Color(0xFF9094A6)),                              overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Orders Table (FIX 3: proper table) ───────────────────────
  Widget _buildOrdersTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF7F8FC)),
            headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9094A6)),
            dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1A1D2E)),
            columnSpacing: 20,
            horizontalMargin: 16,
            dividerThickness: 0.8,
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Rate')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Status')),
            ],
            rows: _dummyOrders.map((order) {
              final status = order['status'] as String;
              final statusColor = status == 'Completed'
                  ? const Color(0xFF27AE60)
                  : status == 'Pending'
                      ? const Color(0xFFF39C12)
                      : const Color(0xFFE74C3C);

              return DataRow(cells: [
                DataCell(Text(order['id'],      style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(order['user'])),
                DataCell(Text(order['product'])),
                DataCell(Text(order['rate'],    style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(order['address'])),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────
class _StatItem {
  final String title;
  final String? value;
  final Future<List<dynamic>>? future;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  _StatItem({required this.title, this.value, this.future, required this.icon, required this.iconBg, required this.iconColor, required this.onTap});
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ActionItem({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
}