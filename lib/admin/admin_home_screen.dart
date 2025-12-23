import 'package:flutter/material.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/services/api_service.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/models/category.dart' as app_category;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) { // Adjust breakpoint as needed
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                            child: FutureBuilder<List<Product>>(
                              future: _productsFuture,
                              builder: (context, snapshot) {
                                return _buildStatCard(
                                  title: 'Total Products',
                                  value: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                                  icon: Icons.shopping_bag,
                                  color: Colors.blue,
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                            child: FutureBuilder<List<app_category.Category>>(
                              future: _categoriesFuture,
                              builder: (context, snapshot) {
                                return _buildStatCard(
                                  title: 'Total Categories',
                                  value: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                                  icon: Icons.category,
                                  color: Colors.green,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FutureBuilder<List<Product>>(
                                future: _productsFuture,
                                builder: (context, snapshot) {
                                  return _buildStatCard(
                                    title: 'Total Products',
                                    value: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                                    icon: Icons.shopping_bag,
                                    color: Colors.blue,
                                  );
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FutureBuilder<List<app_category.Category>>(
                                future: _categoriesFuture,
                                builder: (context, snapshot) {
                                  return _buildStatCard(
                                    title: 'Total Categories',
                                    value: snapshot.hasData ? snapshot.data!.length.toString() : '...',
                                    icon: Icons.category,
                                    color: Colors.green,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                // Add more dashboard widgets here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}