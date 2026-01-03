import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/theme/app_theme.dart';
import 'package:scentview/admin/admin_home_screen.dart';
import 'package:scentview/ui/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _emailNotifications = true;
  bool _promotionalEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          final bool isLoggedIn = authService.isAuthenticated;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with Gradient
              SliverAppBar(
                expandedHeight: 160,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (isLoggedIn)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.edit_2, size: 20, color: Colors.white),
                      ),
                      onPressed: () => _showEditProfileDialog(context, user),
                    ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Card with Glass Effect
                      _buildProfileCard(context, user, isLoggedIn),

                      const SizedBox(height: 24),

                      // Guest Login Section
                      if (!isLoggedIn) ...[
                        _buildLoginCard(context),
                        const SizedBox(height: 24),
                      ],

                      // Account Section
                      if (isLoggedIn) ...[
                        _buildSectionHeader('Account Settings'),
                        const SizedBox(height: 12),
                        _buildAccountSection(context, authService),
                        const SizedBox(height: 24),
                      ],

                      // Preferences Section
                      _buildSectionHeader('Preferences'),
                      const SizedBox(height: 12),
                      _buildPreferencesSection(),
                      const SizedBox(height: 24),

                      // Support Section
                      _buildSectionHeader('Support'),
                      const SizedBox(height: 12),
                      _buildSupportSection(),

                      const SizedBox(height: 32),

                      // Logout Button
                      if (isLoggedIn) _buildLogoutButton(context, authService),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Profile Card with Glass Morphism Effect
  Widget _buildProfileCard(BuildContext context, AuthUser? user, bool isLoggedIn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Image with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Profile Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  color: Colors.grey.shade100,
                  image: user?.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user!.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user?.photoUrl == null
                    ? const Icon(
                        Iconsax.user,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),

              // Edit Button
              if (isLoggedIn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Iconsax.camera, size: 16, color: Colors.blue),
                      onPressed: () => _showImagePicker(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // User Info
          Text(
            isLoggedIn ? (user?.name ?? 'User') : 'Guest User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isLoggedIn ? (user?.email ?? '') : 'Login to access all features',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // User Stats
          if (isLoggedIn)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('12', 'Orders'),
                _buildStatItem('8', 'Wishlist'),
                _buildStatItem('4.8', 'Rating'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Login Card for Guests
  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.user_tag,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock Full Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to manage orders, wishlist and profile',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, LoginScreen.routeName),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B82F6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login / Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  // Account Section
  Widget _buildAccountSection(BuildContext context, AuthService authService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin Dashboard
          if (authService.currentUser?.role == 'admin')
            _buildAccountTile(
              icon: Iconsax.setting_2,
              title: 'Admin Dashboard',
              subtitle: 'Manage store & orders',
              onTap: () => Navigator.pushNamed(context, AdminHomeScreen.routeName),
            ),

          // Orders
          _buildAccountTile(
            icon: Iconsax.bag_2,
            title: 'My Orders',
            subtitle: 'Track and view orders',
            onTap: () => _navigateToOrders(context),
          ),

          // Wishlist
          _buildAccountTile(
            icon: Iconsax.heart,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () => _navigateToWishlist(context),
          ),

          // Addresses
          _buildAccountTile(
            icon: Iconsax.location,
            title: 'Addresses',
            subtitle: 'Shipping addresses',
            onTap: () => _navigateToAddresses(context),
          ),
        ],
      ),
    );
  }

  // Account Tile
  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(
        Iconsax.arrow_right_3,
        size: 20,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Preferences Section
  Widget _buildPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceTile(
            icon: Iconsax.notification,
            title: 'Notifications',
            subtitle: 'Order updates and alerts',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildPreferenceTile(
            icon: Iconsax.moon,
            title: 'Dark Mode',
            subtitle: 'Switch app theme',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildPreferenceTile(
            icon: Iconsax.finger_cricle,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint/face ID',
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
          ),
        ],
      ),
    );
  }

  // Preference Tile
  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          activeTrackColor: Colors.blue.shade200,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Support Section
  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSupportTile(
            icon: Iconsax.message_question,
            title: 'Help Center',
            subtitle: 'Get help with your account',
            onTap: () {},
          ),
          _buildSupportTile(
            icon: Iconsax.document_text,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () {},
          ),
          _buildSupportTile(
            icon: Iconsax.info_circle,
            title: 'About Us',
            subtitle: 'Learn about ScentView',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Support Tile
  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.green,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(
        Iconsax.arrow_right_3,
        size: 20,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Logout Button
  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, authService),
        icon: const Icon(
          Iconsax.logout_1,
          size: 20,
        ),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade100, width: 1),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Navigation & Dialog Methods (SAME AS BEFORE)
  void _navigateToOrders(BuildContext context) {}
  void _navigateToWishlist(BuildContext context) {}
  void _navigateToAddresses(BuildContext context) {}
  void _showEditProfileDialog(BuildContext context, AuthUser? user) {}
  void _showImagePicker(BuildContext context) {}
  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authService.signOut();
              Navigator.pop(ctx);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}