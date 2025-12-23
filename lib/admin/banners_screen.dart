import 'package:flutter/material.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/models/banner.dart' as app_banner; // Alias added
import '../services/api_service.dart';
import 'add_edit_banner_screen.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final _api = ApiService();
  Future<List<app_banner.Banner>>? _bannersFuture; // Use alias

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _bannersFuture = _api.fetchBanners();
    });
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String bannerId,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this banner?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                const String authToken = "YOUR_AUTH_TOKEN_HERE";
                await _api.deleteBanner(id: bannerId, token: authToken);
                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Banner deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _refresh();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Banners'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddEditBannerScreen(),
              ),
            );
            _refresh();
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<app_banner.Banner>>( // Use alias
          future: _bannersFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No banners found. Tap the "+" button to add one.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            final banners = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        width: 72,
                        child:
                            (banner.imageUrl?.isNotEmpty ?? false)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  ApiService.toAbsoluteUrl(banner.imageUrl)!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                      title: Text("Banner #${banner.id}"),
                      subtitle: Text('Target: ${banner.targetScreen ?? ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditBannerScreen(banner: banner),
                                ),
                              );
                              _refresh();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(context, banner.id.toString()),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}