import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  static const routeName = '/help-center';
  const HelpCenterScreen({super.key});

  // ── Data ────────────────────────────────────────────────────────────────────
  static const List<_FAQItem> _faqs = [
    _FAQItem(
      question: 'How long does delivery take?',
      answer: 'Usually 2–4 working days across Pakistan. Remote areas may take up to 6 days.',
    ),
    _FAQItem(
      question: 'Are your perfumes original?',
      answer: 'Yes, we only stock 100% authentic designer and niche fragrances. Every product is sourced directly from authorized distributors.',
    ),
    _FAQItem(
      question: 'What is the return policy?',
      answer: 'You can request a return within 7 days if the seal is unbroken and the product is in its original condition.',
    ),
    _FAQItem(
      question: 'Do you offer Cash on Delivery?',
      answer: 'Yes, COD is available all over Pakistan at no extra charge.',
    ),
    _FAQItem(
      question: 'How do I track my order?',
      answer: 'Once your order is shipped, you\'ll receive a tracking number via SMS and email.',
    ),
    _FAQItem(
      question: 'Can I cancel my order?',
      answer: 'Orders can be cancelled within 2 hours of placement. After that, please contact our support team.',
    ),
  ];

  // ── Launch Helper ───────────────────────────────────────────────────────────
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
          'Help Center',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Banner ───────────────────────────────
            _HeaderBanner(theme: theme),

            const SizedBox(height: 24),

            // ── FAQ ─────────────────────────────────────────
            _SectionLabel(label: 'Frequently Asked Questions', theme: theme),
            const SizedBox(height: 12),
            _FAQSection(faqs: _faqs, theme: theme),

            const SizedBox(height: 24),

            // ── Contact ─────────────────────────────────────
            _SectionLabel(label: 'Still Need Help?', theme: theme),
            const SizedBox(height: 12),
            _ContactSection(
              onLaunch: (uri) => _launchUri(context, uri),
              theme: theme,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────
class _HeaderBanner extends StatelessWidget {
  final ThemeData theme;
  const _HeaderBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            Color.lerp(primary, Colors.purple, 0.45) ?? primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Iconsax.message_question5,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Browse FAQs or reach out to us directly',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
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

// ─── FAQ Data Model ───────────────────────────────────────────────────────────
class _FAQItem {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});
}

// ─── FAQ Section ──────────────────────────────────────────────────────────────
class _FAQSection extends StatelessWidget {
  final List<_FAQItem> faqs;
  final ThemeData theme;

  const _FAQSection({required this.faqs, required this.theme});

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: faqs.asMap().entries.map((entry) {
            final isLast = entry.key == faqs.length - 1;
            return Column(
              children: [
                _FAQTile(item: entry.value, theme: theme),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final _FAQItem item;
  final ThemeData theme;

  const _FAQTile({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return Theme(
      // Override ExpansionTile divider color locally
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: primary,
        collapsedIconColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Iconsax.message_question, size: 16, color: primary),
        ),
        title: Text(
          item.question,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        children: [
          Text(
            item.answer,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Section ──────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  final void Function(Uri) onLaunch;
  final ThemeData theme;

  const _ContactSection({required this.onLaunch, required this.theme});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      _ContactData(
        icon: FontAwesomeIcons.whatsapp,
        isFaIcon: true,
        title: 'Chat on WhatsApp',
        subtitle: '+92 300 1234567',
        color: const Color(0xFF00897B),
        uri: Uri.parse('https://wa.me/923001234567'),
      ),
      _ContactData(
        icon: Iconsax.sms,
        title: 'Email Support',
        subtitle: 'support@scentview.com',
        color: const Color(0xFF1565C0),
        uri: Uri.parse('mailto:support@scentview.com'),
      ),
      _ContactData(
        icon: Iconsax.call,
        title: 'Call Us',
        subtitle: '+92 300 1234567',
        color: const Color(0xFF2E7D32),
        uri: Uri.parse('tel:+923001234567'),
      ),
    ];

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: contacts.asMap().entries.map((entry) {
            final isLast = entry.key == contacts.length - 1;
            final c = entry.value;
            return Column(
              children: [
                _ContactTile(
                  data: c,
                  onTap: () => onLaunch(c.uri),
                  theme: theme,
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
          }).toList(),
        ),
      ),
    );
  }
}

class _ContactData {
  final IconData icon;
  final bool isFaIcon;
  final String title;
  final String subtitle;
  final Color color;
  final Uri uri;

  const _ContactData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.uri,
    this.isFaIcon = false,
  });
}

class _ContactTile extends StatelessWidget {
  final _ContactData data;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ContactTile({
    required this.data,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: data.isFaIcon
              ? FaIcon(data.icon, size: 18, color: data.color)
              : Icon(data.icon, size: 20, color: data.color),
        ),
      ),
      title: Text(
        data.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        data.subtitle,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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