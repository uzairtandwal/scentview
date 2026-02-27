import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../image_storage.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────
class AdminPanelScreen extends StatefulWidget {
  static const routeName = '/admin';
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final _imageStorage = ImageStorage();
  late final TabController _tabController;

  List<dynamic> _bannerImages = [];
  bool _isLoading = false;
  bool _isUploading = false;

  // ── Mock stats (replace with real service calls) ─────────────────────────
  final Map<String, String> _stats = {
    'Total Orders': '128',
    'Total Products': '64',
    'Total Users': '312',
    'Revenue': 'PKR 4.2M',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBannerImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Load banners ─────────────────────────────────────────────────────────
  Future<void> _loadBannerImages() async {
    setState(() => _isLoading = true);
    try {
      final images = await _imageStorage.getBannerImages();
      if (mounted) setState(() => _bannerImages = images);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Pick + upload banner ─────────────────────────────────────────────────
  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await _imageStorage.saveBannerImage(bytes);
      await _loadBannerImages();
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Delete with confirmation ─────────────────────────────────────────────
  Future<void> _confirmDelete(dynamic imageFile, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Banner?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('This banner will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _imageStorage.deleteBannerImage(imageFile);
      await _loadBannerImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Iconsax.chart, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Iconsax.image, size: 18), text: 'Banners'),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (_, __) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _isUploading ? null : _pickBannerImage,
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Iconsax.add),
            label: Text(
              _isUploading ? 'Uploading...' : 'Add Banner',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Dashboard ──────────────────────────────
          _DashboardTab(stats: _stats),

          // ── Tab 2: Banners ────────────────────────────────
          _BannersTab(
            bannerImages: _bannerImages,
            isLoading: _isLoading,
            onDelete: _confirmDelete,
            onRefresh: _loadBannerImages,
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final Map<String, String> stats;

  const _DashboardTab({required this.stats});

  static const _statIcons = {
    'Total Orders': Iconsax.bag,
    'Total Products': Iconsax.box,
    'Total Users': Iconsax.people,
    'Revenue': Iconsax.money,
  };

  static const _statColors = {
    'Total Orders': Color(0xFF1565C0),
    'Total Products': Color(0xFF2E7D32),
    'Total Users': Color(0xFF6A1B9A),
    'Revenue': Color(0xFFE65100),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = stats.entries.toList();

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // Stats grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: entries.length,
              itemBuilder: (_, i) => _StatCard(
                label: entries[i].key,
                value: entries[i].value,
                icon: _statIcons[entries[i].key] ?? Iconsax.chart,
                color: _statColors[entries[i].key] ?? theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 28),

            // Quick actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            _QuickActions(),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final _actions = const [
    (label: 'Add Product', icon: Iconsax.box_add, color: Color(0xFF2E7D32)),
    (label: 'View Orders', icon: Iconsax.bag_tick, color: Color(0xFF1565C0)),
    (label: 'Manage Users', icon: Iconsax.people, color: Color(0xFF6A1B9A)),
    (label: 'Settings', icon: Iconsax.setting, color: Color(0xFFE65100)),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: _actions.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: ListTile(
            onTap: () {}, // Connect to routes
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(a.icon, size: 18, color: a.color),
            ),
            title: Text(
              a.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Banners Tab ──────────────────────────────────────────────────────────────
class _BannersTab extends StatelessWidget {
  final List<dynamic> bannerImages;
  final bool isLoading;
  final Future<void> Function(dynamic, int) onDelete;
  final Future<void> Function() onRefresh;

  const _BannersTab({
    required this.bannerImages,
    required this.isLoading,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bannerImages.isEmpty) {
      return _EmptyBanners();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: bannerImages.length,
        itemBuilder: (_, i) => _BannerTile(
          imageFile: bannerImages[i],
          index: i,
          onDelete: () => onDelete(bannerImages[i], i),
        ),
      ),
    );
  }
}

// ─── Banner Tile ──────────────────────────────────────────────────────────────
class _BannerTile extends StatelessWidget {
  final dynamic imageFile;
  final int index;
  final VoidCallback onDelete;

  const _BannerTile({
    required this.imageFile,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          kIsWeb
              ? Image.memory(
                  base64Decode(imageFile.path),
                  fit: BoxFit.cover,
                )
              : Image.file(imageFile, fit: BoxFit.cover),

          // Gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),

          // Index label
          Positioned(
            top: 8,
            left: 10,
            child: Text(
              'Banner ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ],
              ),
            ),
          ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: theme.colorScheme.error,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onDelete,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Iconsax.trash, color: Colors.white, size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Banners ────────────────────────────────────────────────────────────
class _EmptyBanners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.image, size: 36, color: primary),
          ),
          const SizedBox(height: 16),
          Text(
            'No banners yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add\nyour first banner image.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}