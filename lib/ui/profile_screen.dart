import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: StreamBuilder<AuthUser?>(
        stream: authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'No name found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'No email found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              _buildProfileOption(
                context,
                icon: Icons.list_alt,
                title: 'My Orders',
                onTap: () =>
                    Navigator.pushNamed(context, MyOrdersScreen.routeName),
              ),
              _buildProfileOption(
                context,
                icon: Icons.location_on_outlined,
                title: 'Shipping Addresses',
                onTap: () =>
                    Navigator.pushNamed(context, AddressesScreen.routeName),
              ),
              _buildProfileOption(
                context,
                icon: Icons.payment,
                title: 'Payment Methods',
                onTap: () => Navigator.pushNamed(
                  context,
                  PaymentMethodsScreen.routeName,
                ),
              ),
              _buildProfileOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () =>
                    Navigator.pushNamed(context, SettingsScreen.routeName),
              ),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  authService.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
