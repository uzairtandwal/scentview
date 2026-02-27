import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // ✅ Stylish icons ke liye
import 'help_center_screen.dart'; // ✅ Help Center link karne ke liye

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
      backgroundColor: const Color(0xFFF8FAFC), // ✅ Clean background color
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                      icon: Iconsax.notification, // ✅ Updated Icon
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      trailing: Switch.adaptive( // ✅ Smoother switch
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() => _pushNotifications = value);
                          _showSnackbar(context, value ? 'Notifications enabled' : 'Notifications disabled');
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.direct_send, // ✅ Updated Icon
                      title: 'Marketing Emails',
                      subtitle: 'Receive promotional emails',
                      trailing: Switch.adaptive(
                        value: _marketingEmails,
                        onChanged: (value) {
                          setState(() => _marketingEmails = value);
                          _showSnackbar(context, value ? 'Marketing emails enabled' : 'Marketing emails disabled');
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.finger_scan, // ✅ Updated Icon
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID',
                      trailing: Switch.adaptive(
                        value: _biometricLogin,
                        onChanged: (value) async {
                          if (value) {
                            final confirmed = await _showBiometricConfirmation(context);
                            if (confirmed != true) return;
                          }
                          setState(() => _biometricLogin = value);
                        },
                        activeColor: Colors.blue,
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
                      icon: Iconsax.moon, // ✅ Updated Icon
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      trailing: Switch.adaptive(
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() => _darkMode = value);
                          _showSnackbar(context, value ? 'Dark mode enabled' : 'Light mode enabled');
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.volume_high, // ✅ Updated Icon
                      title: 'Sound Effects',
                      subtitle: 'Enable app sounds',
                      trailing: Switch.adaptive(
                        value: _soundEffects,
                        onChanged: (value) {
                          setState(() => _soundEffects = value);
                          _showSnackbar(context, value ? 'Sounds enabled' : 'Sounds disabled');
                        },
                        activeColor: Colors.blue,
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
                      icon: Iconsax.global, // ✅ Updated Icon
                      title: 'Language',
                      subtitle: 'App language',
                      trailing: _buildDropdownButton(
                        value: _selectedLanguage,
                        items: _languages,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLanguage = value);
                            _showSnackbar(context, 'Language changed to $value');
                          }
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.coin, // ✅ Updated Icon
                      title: 'Currency',
                      subtitle: 'Display currency',
                      trailing: _buildDropdownButton(
                        value: _selectedCurrency,
                        items: _currencies,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCurrency = value);
                            _showSnackbar(context, 'Currency changed to $value');
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================ HELP & SUPPORT (NEW) ================
                _buildSectionTitle(context, 'Help & Support'),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.message_question, // ✅ New Support Icon
                      title: 'Help Center',
                      subtitle: 'FAQs and Support Contact',
                      onTap: () {
                        Navigator.pushNamed(context, HelpCenterScreen.routeName);
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsOption(
                      context,
                      icon: Iconsax.document_text,
                      title: 'Privacy Policy',
                      subtitle: 'Read our terms and conditions',
                      onTap: () => _showComingSoon(context, 'Privacy Policy'),
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
                      icon: Iconsax.trash,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () => _showDeleteAccountConfirmation(context),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Center(child: Text("ScentView v1.0.7", style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- PRESERVED ORIGINAL METHODS ---

  Widget _buildSectionTitle(BuildContext context, String title, {Color? color}) {
    return Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color ?? Colors.blueGrey));
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children, Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsOption(BuildContext context, {required IconData icon, required String title, required String subtitle, Widget? trailing, VoidCallback? onTap, Color? titleColor, Color? iconColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: (iconColor ?? Colors.blue).withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor ?? Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDropdownButton({required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      underline: const SizedBox(),
      icon: const Icon(Iconsax.arrow_down_1, size: 14),
      items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade50);

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('$feature Coming Soon'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
  }

  Future<bool?> _showBiometricConfirmation(BuildContext context) async {
    return showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Enable Biometric'), content: const Text('Do you want to enable faster access?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enable'))]));
  }

  Future<bool?> _showDeleteAccountConfirmation(BuildContext context) async {
    return showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Account'), content: const Text('This action cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red)))]));
  }
}