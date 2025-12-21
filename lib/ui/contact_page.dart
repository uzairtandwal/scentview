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
