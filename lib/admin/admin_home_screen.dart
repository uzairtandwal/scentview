import 'package:flutter/material.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/services/api_service.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;

// ================ CORRECT IMPORTS ================ 
import 'package:scentview/admin/product_list_screen.dart'; // Products list
import 'package:scentview/admin/categories_screen.dart'; // Categories list
import 'package:scentview/admin/product_form_screen.dart'; // Add Product
import 'package:scentview/admin/banners_screen.dart'; // Banners list
import 'package:scentview/admin/add_edit_banner_screen.dart'; // Add Banner
import 'package:scentview/admin/add_edit_category_screen.dart'; // Add Category

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _productsFuture = _apiService.fetchProducts();
      _categoriesFuture = _apiService.fetchCategories();
    });
    
    // Reset loading state after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // ================ WORKING NAVIGATION METHODS ================ 
  void _navigateToProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(), // CORRECT
      ),
    );
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriesScreen(), // CORRECT
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(), // CORRECT
      ),
    );
  }

  void _navigateToBanners(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BannersScreen(), // CORRECT
      ),
    );
  }

  void _navigateToAddBanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditBannerScreen(), // CORRECT
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(), // CORRECT
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dashboard statistics data
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
        'value': '150', 
        'icon': Icons.receipt_long_rounded, 
        'color': Colors.orange,
        'onTap': () => _showComingSoon(context, 'Orders Management'),
      },
      {
        'title': 'Total Users', 
        'value': '35', 
        'icon': Icons.people_alt_rounded, 
        'color': Colors.purple,
        'onTap': () => _showComingSoon(context, 'Users Management'),
      },
      {
        'title': 'Revenue', 
        'value': '\$12,450', 
        'icon': Icons.attach_money_rounded, 
        'color': Colors.green,
        'onTap': () => _showComingSoon(context, 'Revenue Reports'),
      },
      {
        'title': 'Pending Orders', 
        'value': '12', 
        'icon': Icons.pending_actions_rounded, 
        'color': Colors.red,
        'onTap': () => _showComingSoon(context, 'Pending Orders'),
      },
    ];

    // Quick actions
    final List<Map<String, dynamic>> quickActions = [
      {
        'title': 'Add Product', 
        'icon': Icons.add_circle_outline_rounded,
        'onTap': () => _navigateToAddProduct(context),
      },
      {
        'title': 'Manage Categories', 
        'icon': Icons.edit_note_rounded,
        'onTap': () => _navigateToCategories(context),
      },
      {
        'title': 'Upload Banner', 
        'icon': Icons.image_outlined,
        'onTap': () => _navigateToAddBanner(context),
      },
      {
        'title': 'View Reports', 
        'icon': Icons.analytics_outlined,
        'onTap': () => _showComingSoon(context, 'Analytics Reports'),
      },
    ];

    return AdminLayout(
      child: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: CustomScrollView(
          slivers: [
            // ================ HEADER SECTION ================ 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    Text(
                      'Welcome back, Admin!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here\'s what\'s happening with your store today',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================ STATISTICS SECTION ================ 
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stat = stats[index];
                    if (stat.containsKey('future')) {
                      return FutureBuilder<List<dynamic>>(
                        future: stat['future'],
                        builder: (context, snapshot) {
                          return _buildStatCard(
                            context,
                            title: stat['title'],
                            value: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                            icon: stat['icon'],
                            color: stat['color'],
                            isLoading: snapshot.connectionState == ConnectionState.waiting,
                            onTap: stat['onTap'],
                          );
                        },
                      );
                    }
                    return _buildStatCard(
                      context,
                      title: stat['title'],
                      value: stat['value'],
                      icon: stat['icon'],
                      color: stat['color'],
                      isLoading: false,
                      onTap: stat['onTap'],
                    );
                  },
                  childCount: stats.length,
                ),
              ),
            ),

            // ================ QUICK ACTIONS SECTION ================ 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final action = quickActions[index];
                    return _buildQuickActionCard(
                      context,
                      title: action['title'],
                      icon: action['icon'],
                      onTap: action['onTap'],
                    );
                  },
                  childCount: quickActions.length,
                ),
              ),
            ),

            // ================ RECENT ACTIVITY SECTION ================ 
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showComingSoon(context, 'Activity Log');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildRecentActivity(context),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ================ STAT CARD WIDGET ================ 
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon and Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Value
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                // Progress Indicator (for loading states)
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      minHeight: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================ QUICK ACTION CARD ================ 
  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================ RECENT ACTIVITY ================ 
  SliverList _buildRecentActivity(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'New order placed',
        'description': 'Order #ORD-2023-00123',
        'time': '5 minutes ago',
        'icon': Icons.shopping_cart_checkout_rounded,
        'color': Colors.green,
        'onTap': () => _showComingSoon(context, 'Order Details'),
      },
      {
        'title': 'Product added',
        'description': 'New product "Luxury Perfume" added',
        'time': '1 hour ago',
        'icon': Icons.add_box_rounded,
        'color': Colors.blue,
        'onTap': () => _navigateToProducts(context),
      },
      {
        'title': 'User registered',
        'description': 'New user "john@example.com"',
        'time': '2 hours ago',
        'icon': Icons.person_add_rounded,
        'color': Colors.purple,
        'onTap': () => _showComingSoon(context, 'Users Management'),
      },
      {
        'title': 'Category updated',
        'description': 'Category "Men\'s Fragrances" updated',
        'time': '3 hours ago',
        'icon': Icons.edit_rounded,
        'color': Colors.orange,
        'onTap': () => _navigateToCategories(context),
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final activity = activities[index];
          return GestureDetector(
            onTap: activity['onTap'],
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: activity['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity['icon'],
                          color: activity['color'],
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Activity Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Time
                      Text(
                        activity['time'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: activities.length,
      ),
    );
  }
}