import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scentview/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy user data
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';
  String _userPhone = '+1 234 567 8900';
  String _userAddress = '123 Main St, Anytown USA';
  final String _userAvatarUrl = 'https://i.pravatar.cc/300';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement profile editing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(user),
                const SizedBox(height: 32),
                _buildProfileDetails(user),
                const SizedBox(height: 32),
                _buildActionButtons(authService),
                const SizedBox(height: 32),
                _buildAppSettings(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AuthUser? user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          backgroundImage: user?.photoUrl != null
              ? NetworkImage(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null
              ? Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Guest User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'guest@example.com',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(AuthUser? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDetailTile(
            context,
            Icons.phone_outlined,
            'Phone',
            user?.phoneNumber ?? 'N/A',
          ),
          _buildDetailTile(
            context,
            Icons.location_on_outlined,
            'Address',
            user?.address ?? 'N/A',
          ),
          _buildDetailTile(
            context,
            Icons.calendar_today_outlined,
            'Member Since',
            user?.createdAt != null
                ? 'Member since ${_formatDate(user!.createdAt!)}'
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthService authService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement order history navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order history coming soon!')),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('Order History'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Icons.notifications_none,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Notifications',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.brightness_medium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement dark mode toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Basic date formatting, you might want a more sophisticated package
    return '${date.day}/${date.month}/${date.year}';
  }
}