import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop layout
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile layout
          return Scaffold(
            drawer: _buildSidebar(context),
            body: child,
          );
        }
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Text(
              'ScentView Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildSidebarItem(context, Icons.dashboard, "Dashboard", '/admin/dashboard'),
          _buildSidebarItem(context, Icons.view_carousel, "Manage Banners", '/admin/banners'),
          _buildSidebarItem(context, Icons.category, "Manage Categories", '/admin/categories'),
          _buildSidebarItem(context, Icons.shopping_bag, "Manage Products", '/admin/products'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == routeName;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
