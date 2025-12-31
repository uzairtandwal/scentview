import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:scentview/services/auth_service.dart';
import 'package:scentview/theme/app_theme.dart';

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
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          return CustomScrollView(
            slivers: [
              // App Bar with Gradient
              SliverAppBar(
                expandedHeight: 140,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'My Profile',
                    style: AppTheme.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Iconsax.edit_2, color: Colors.white),
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
                      const SizedBox(height: 24),

                      // Profile Card
                      _buildProfileCard(context, user),

                      const SizedBox(height: 24),

                      // Account Section
                      _buildSectionTitle('Account Settings'),
                      const SizedBox(height: 12),
                      _buildAccountSection(context, authService),

                      const SizedBox(height: 24),

                      // Preferences Section
                      _buildSectionTitle('Preferences'),
                      const SizedBox(height: 12),
                      _buildPreferencesSection(),

                      const SizedBox(height: 24),

                      // Support Section
                      _buildSectionTitle('Support'),
                      const SizedBox(height: 12),
                      _buildSupportSection(),

                      const SizedBox(height: 32),

                      // Logout Button
                      _buildLogoutButton(context, authService),

                      const SizedBox(height: 40),
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

  // Profile Card
  Widget _buildProfileCard(BuildContext context, AuthUser? user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      padding: AppTheme.largePadding,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 3,
                  ),
                  gradient: AppTheme.primaryGradient,
                ),
                child: ClipOval(
                  child: user?.photoUrl != null
                      ? Image.network(
                          user!.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: IconButton(
                  icon: Icon(Iconsax.camera, size: 18, color: AppTheme.primaryColor),
                  onPressed: () => _showImagePicker(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'Guest User',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'guest@example.com',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileStat('Orders', '12'),
              const SizedBox(
                height: 30,
                child: VerticalDivider(thickness: 1),
              ),
              _buildProfileStat('Wishlist', '8'),
              const SizedBox(
                height: 30,
                child: VerticalDivider(thickness: 1),
              ),
              _buildProfileStat('Reviews', '23'),
            ],
          ),
        ], // ✅ Bracket Fixed Here
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Iconsax.user,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProfileStat(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.heading5.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  // Account Section
  Widget _buildAccountSection(BuildContext context, AuthService authService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Iconsax.bag_2,
            title: 'My Orders',
            subtitle: 'Track and view your orders',
            onTap: () => _navigateToOrders(context),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.heart,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () => _navigateToWishlist(context),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.location,
            title: 'Addresses',
            subtitle: 'Manage shipping addresses',
            onTap: () => _navigateToAddresses(context),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.card,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () => _navigateToPayments(context),
            showTrailing: true,
          ),
        ],
      ),
    );
  }

  // Preferences Section
  Widget _buildPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Iconsax.notification,
            title: 'Push Notifications',
            subtitle: 'Receive order updates',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Iconsax.moon,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Iconsax.finger_cricle,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint/face ID',
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Iconsax.sms,
            title: 'Email Notifications',
            subtitle: 'Receive promotional emails',
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Iconsax.gift,
            title: 'Promotional Emails',
            subtitle: 'Get offers and discounts',
            value: _promotionalEmails,
            onChanged: (value) => setState(() => _promotionalEmails = value),
          ),
        ],
      ),
    );
  }

  // Support Section
  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.largeRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Iconsax.headphone,
            title: 'Help Center',
            subtitle: 'Get help with your account',
            onTap: () => _openHelpCenter(),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.message_question,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () => _openFAQ(),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.info_circle,
            title: 'About Us',
            subtitle: 'Learn about ScentView',
            onTap: () => _openAbout(),
            showTrailing: true,
          ),
          _buildDivider(),
          _buildListTile(
            icon: Iconsax.document_text,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () => _openPrivacyPolicy(),
            showTrailing: true,
          ),
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTheme.heading5.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // List Tile
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showTrailing = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
      ),
      trailing: showTrailing
          ? Icon(Iconsax.arrow_right_3, size: 20, color: AppTheme.textTertiary)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Switch Tile
  Widget _buildSwitchTile({
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
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.borderColor,
      ),
    );
  }

  // Logout Button
  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, authService),
        icon: const Icon(Iconsax.logout_1, size: 20),
        label: Text(
          'Logout',
          style: AppTheme.buttonMedium.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.largeRadius,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToOrders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Orders screen coming soon!', style: AppTheme.bodyMedium),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
      ),
    );
  }

  void _navigateToWishlist(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wishlist screen coming soon!', style: AppTheme.bodyMedium),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
      ),
    );
  }

  void _navigateToAddresses(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Addresses screen coming soon!', style: AppTheme.bodyMedium),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
      ),
    );
  }

  void _navigateToPayments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payments screen coming soon!', style: AppTheme.bodyMedium),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.mediumRadius),
      ),
    );
  }

  // Support Methods
  void _openHelpCenter() {}
  void _openFAQ() {}
  void _openAbout() {}
  void _openPrivacyPolicy() {}

  // Dialog Methods
  void _showEditProfileDialog(BuildContext context, AuthUser? user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile', style: AppTheme.heading5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: user?.name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Iconsax.user, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: AppTheme.mediumRadius),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Iconsax.sms, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: AppTheme.mediumRadius),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.phoneNumber,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Iconsax.call, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: AppTheme.mediumRadius),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile updated successfully!', style: AppTheme.bodyMedium),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text('Save Changes', style: AppTheme.buttonMedium),
            ),
          ],
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Iconsax.camera, color: AppTheme.primaryColor),
                title: Text('Take Photo', style: AppTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Iconsax.gallery, color: AppTheme.primaryColor),
                title: Text('Choose from Gallery', style: AppTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTheme.bodyMedium),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout', style: AppTheme.heading5),
          content: Text('Are you sure you want to logout?', style: AppTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await authService.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: Text('Logout', style: AppTheme.buttonMedium.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}