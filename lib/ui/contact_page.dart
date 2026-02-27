import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contact_data.dart';

class ContactPage extends StatelessWidget {
  static const routeName = '/contact';
  const ContactPage({super.key});

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore: avoid_print
      print('Could not launch: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ContactData.businessName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: const Text('Get in touch with us'),
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.place, label: ContactData.address),
          _InfoRow(icon: Icons.schedule, label: ContactData.hours),
          _InfoRow(icon: Icons.call, label: ContactData.phone),
          _InfoRow(icon: Icons.email, label: ContactData.email),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    _launchUri(Uri.parse('tel:${ContactData.phone}')),
                icon: const Icon(Icons.call),
                label: const Text('Call'),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _launchUri(Uri.parse('mailto:${ContactData.email}')),
                icon: const Icon(Icons.email),
                label: const Text('Email'),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchUri(
                  Uri.parse(
                    'https://wa.me/${ContactData.whatsapp.replaceAll('+', '').replaceAll('-', '').replaceAll(' ', '')}',
                  ),
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: const Text('WhatsApp'),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchUri(Uri.parse(ContactData.mapsUrl)),
                icon: const Icon(Icons.map),
                label: const Text('Maps'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (ContactData.facebook.isNotEmpty ||
              ContactData.instagram.isNotEmpty)
            Text('Social', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (ContactData.facebook.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.facebook),
              title: const Text('Facebook'),
              onTap: () => _launchUri(Uri.parse(ContactData.facebook)),
            ),
          if (ContactData.instagram.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Instagram'),
              onTap: () => _launchUri(Uri.parse(ContactData.instagram)),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact_data.dart';

class ContactPage extends StatelessWidget {
  static const routeName = '/contact';
  const ContactPage({super.key});

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open this link.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Contact Us',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Business Header ─────────────────────────────────
          _BusinessHeader(theme: theme),

          const SizedBox(height: 16),

          // ── Info Card ───────────────────────────────────────
          _InfoCard(theme: theme),

          const SizedBox(height: 16),

          // ── Quick Actions ───────────────────────────────────
          _SectionLabel(label: 'Reach Us', theme: theme),
          const SizedBox(height: 12),
          _QuickActions(
            onLaunch: (uri) => _launchUri(context, uri),
            theme: theme,
          ),

          const SizedBox(height: 20),

          // ── Social Links ────────────────────────────────────
          if (ContactData.facebook.isNotEmpty ||
              ContactData.instagram.isNotEmpty) ...[
            _SectionLabel(label: 'Follow Us', theme: theme),
            const SizedBox(height: 12),
            _SocialLinks(
              onLaunch: (uri) => _launchUri(context, uri),
              theme: theme,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

// ─── Business Header ──────────────────────────────────────────────────────────
class _BusinessHeader extends StatelessWidget {
  final ThemeData theme;
  const _BusinessHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Iconsax.shop, size: 26, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ContactData.businessName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Get in touch with us anytime',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final ThemeData theme;
  const _InfoCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Iconsax.location,
            label: ContactData.address,
            theme: theme,
          ),
          _InfoRow(
            icon: Iconsax.clock,
            label: ContactData.hours,
            theme: theme,
          ),
          _InfoRow(
            icon: Iconsax.call,
            label: ContactData.phone,
            theme: theme,
          ),
          _InfoRow(
            icon: Iconsax.sms,
            label: ContactData.email,
            theme: theme,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.theme,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
      ],
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final void Function(Uri) onLaunch;
  final ThemeData theme;

  const _QuickActions({required this.onLaunch, required this.theme});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        label: 'Call',
        icon: Iconsax.call,
        color: const Color(0xFF2E7D32),
        uri: Uri.parse('tel:${ContactData.phone}'),
      ),
      _ActionData(
        label: 'Email',
        icon: Iconsax.sms,
        color: const Color(0xFF1565C0),
        uri: Uri.parse('mailto:${ContactData.email}'),
      ),
      _ActionData(
        label: 'WhatsApp',
        iconWidget: const FaIcon(
          FontAwesomeIcons.whatsapp,
          size: 18,
          color: Colors.white,
        ),
        color: const Color(0xFF00897B),
        uri: Uri.parse(
          'https://wa.me/${ContactData.whatsapp.replaceAll(RegExp(r'[\s+\-]'), '')}',
        ),
      ),
      _ActionData(
        label: 'Maps',
        icon: Iconsax.location,
        color: const Color(0xFFE65100),
        uri: Uri.parse(ContactData.mapsUrl),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) => _ActionButton(
            data: a,
            onTap: () => onLaunch(a.uri),
            theme: theme,
          )).toList(),
    );
  }
}

class _ActionData {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color color;
  final Uri uri;

  const _ActionData({
    required this.label,
    required this.color,
    required this.uri,
    this.icon,
    this.iconWidget,
  });
}

class _ActionButton extends StatelessWidget {
  final _ActionData data;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ActionButton({
    required this.data,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              data.iconWidget ??
                  Icon(data.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                data.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Links ─────────────────────────────────────────────────────────────
class _SocialLinks extends StatelessWidget {
  final void Function(Uri) onLaunch;
  final ThemeData theme;

  const _SocialLinks({required this.onLaunch, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (ContactData.facebook.isNotEmpty)
            _SocialTile(
              icon: FontAwesomeIcons.facebook,
              label: 'Facebook',
              handle: 'Follow on Facebook',
              color: const Color(0xFF1877F2),
              onTap: () => onLaunch(Uri.parse(ContactData.facebook)),
              theme: theme,
              isLast: ContactData.instagram.isEmpty,
            ),
          if (ContactData.instagram.isNotEmpty)
            _SocialTile(
              icon: FontAwesomeIcons.instagram,
              label: 'Instagram',
              handle: 'Follow on Instagram',
              color: const Color(0xFFE1306C),
              onTap: () => onLaunch(Uri.parse(ContactData.instagram)),
              theme: theme,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String handle;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isLast;

  const _SocialTile({
    required this.icon,
    required this.label,
    required this.handle,
    required this.color,
    required this.onTap,
    required this.theme,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: color),
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            handle,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          trailing: Icon(
            Iconsax.arrow_right_3,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: theme.colorScheme.primary,
      ),
    );
  }
}