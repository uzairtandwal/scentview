import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _marketingEmails = false;
  bool _darkMode = false;
  bool _soundEffects = true;
  bool _biometricLogin = false;
  bool _autoSaveCart = true;
  
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD (\$)';
  String _selectedRegion = 'Pakistan';
  
  final List<String> _languages = ['English', 'Urdu', 'Arabic', 'Spanish', 'French'];
  final List<String> _currencies = ['USD (\$)', 'PKR (₨)', 'EUR (€)', 'GBP (£)', 'INR (₹)'];
  final List<String> _regions = ['Pakistan', 'USA', 'UK', 'India', 'UAE', 'Saudi Arabia'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ================ ACCOUNT SETTINGS ================
                _buildSectionTitle(context, 'Account'),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      trailing: Switch(
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() {
                            _pushNotifications = value;
                          });
                          _showSnackbar(
                            context,
                            value ? 'Notifications enabled' : 'Notifications disabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.email_outlined,
                      title: 'Marketing Emails',
                      subtitle: 'Receive promotional emails',
                      trailing: Switch(
                        value: _marketingEmails,
                        onChanged: (value) {
                          setState(() {
                            _marketingEmails = value;
                          });
                          _showSnackbar(
                            context,
                            value ? 'Marketing emails enabled' : 'Marketing emails disabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.fingerprint_outlined,
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID',
                      trailing: Switch(
                        value: _biometricLogin,
                        onChanged: (value) async {
                          // TODO: Check device biometric support
                          if (value) {
                            final confirmed = await _showBiometricConfirmation(context);
                            if (confirmed != true) return;
                          }
                          setState(() {
                            _biometricLogin = value;
                          });
                          _showSnackbar(
                            context,
                            value ? 'Biometric login enabled' : 'Biometric login disabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================ APP PREFERENCES ================
                _buildSectionTitle(context, 'App Preferences'),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() {
                            _darkMode = value;
                          });
                          // TODO: Implement theme switching
                          _showSnackbar(
                            context,
                            value ? 'Dark mode enabled' : 'Light mode enabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.volume_up_outlined,
                      title: 'Sound Effects',
                      subtitle: 'Enable app sounds',
                      trailing: Switch(
                        value: _soundEffects,
                        onChanged: (value) {
                          setState(() {
                            _soundEffects = value;
                          });
                          _showSnackbar(
                            context,
                            value ? 'Sounds enabled' : 'Sounds disabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.shopping_cart_outlined,
                      title: 'Auto-save Cart',
                      subtitle: 'Save cart items automatically',
                      trailing: Switch(
                        value: _autoSaveCart,
                        onChanged: (value) {
                          setState(() {
                            _autoSaveCart = value;
                          });
                          _showSnackbar(
                            context,
                            value ? 'Cart auto-save enabled' : 'Cart auto-save disabled',
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================ REGIONAL SETTINGS ================
                _buildSectionTitle(context, 'Regional'),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'App language',
                      trailing: _buildDropdownButton(
                        value: _selectedLanguage,
                        items: _languages,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                            _showSnackbar(context, 'Language changed to $value');
                          }
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.currency_exchange_outlined,
                      title: 'Currency',
                      subtitle: 'Display currency',
                      trailing: _buildDropdownButton(
                        value: _selectedCurrency,
                        items: _currencies,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCurrency = value;
                            });
                            _showSnackbar(context, 'Currency changed to $value');
                          }
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Region',
                      subtitle: 'Your country/region',
                      trailing: _buildDropdownButton(
                        value: _selectedRegion,
                        items: _regions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRegion = value;
                            });
                            _showSnackbar(context, 'Region changed to $value');
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================ ABOUT ================
                _buildSectionTitle(context, 'About'),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: 'Current version information',
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      onTap: () {
                        // TODO: Navigate to terms screen
                        _showComingSoon(context, 'Terms of Service');
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () {
                        // TODO: Navigate to privacy policy
                        _showComingSoon(context, 'Privacy Policy');
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.contact_support_outlined,
                      title: 'Contact Support',
                      subtitle: 'Get help from our support team',
                      onTap: () {
                        // TODO: Navigate to contact support
                        _showComingSoon(context, 'Contact Support');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ================ DANGER ZONE ================
                _buildSectionTitle(context, 'Danger Zone', color: Colors.red),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  borderColor: Colors.red.shade100,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Icons.delete_outline_rounded,
                      title: 'Clear Cache',
                      subtitle: 'Clear all cached data',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        final confirmed = await _showClearCacheConfirmation(context);
                        if (confirmed == true) {
                          // TODO: Clear cache logic
                          _showSnackbar(context, 'Cache cleared successfully');
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Icons.delete_forever_outlined,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        final confirmed = await _showDeleteAccountConfirmation(context);
                        if (confirmed == true) {
                          // TODO: Delete account logic
                          _showSnackbar(context, 'Account deletion requested');
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ================ SECTION TITLE ================
  Widget _buildSectionTitle(BuildContext context, String title, {Color? color}) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // ================ SETTINGS CARD ================
  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ================ SETTINGS OPTION ================
  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ================ DROPDOWN BUTTON ================
  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      underline: const SizedBox(),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================ DIVIDER ================
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  // ================ SNACKBAR HELPER ================
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  // ================ COMING SOON DIALOG ================
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('$feature Coming Soon'),
        content: Text('This feature is currently under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ================ BIOMETRIC CONFIRMATION ================
  Future<bool?> _showBiometricConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Enable Biometric Login'),
        content: const Text('Do you want to enable biometric login for faster access?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  // ================ CLEAR CACHE CONFIRMATION ================
  Future<bool?> _showClearCacheConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  // ================ DELETE ACCOUNT CONFIRMATION ================
  Future<bool?> _showDeleteAccountConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}