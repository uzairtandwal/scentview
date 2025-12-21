import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../image_storage.dart';

class AdminPanelScreen extends StatefulWidget {
  static const routeName = '/admin';
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _imageStorage = ImageStorage();
  List<dynamic> _bannerImages = [];

  @override
  void initState() {
    super.initState();
    _loadBannerImages();
  }

  Future<void> _loadBannerImages() async {
    final images = await _imageStorage.getBannerImages();
    setState(() {
      _bannerImages = images;
    });
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      await _imageStorage.saveBannerImage(bytes);
      _loadBannerImages();
    }
  }

  Future<void> _deleteBannerImage(dynamic imageFile) async {
    await _imageStorage.deleteBannerImage(imageFile);
    _loadBannerImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _bannerImages.length,
        itemBuilder: (context, index) {
          final imageFile = _bannerImages[index];
          return GridTile(
            header: GridTileBar(
              backgroundColor: Colors.black45,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _deleteBannerImage(imageFile),
              ),
            ),
            child: kIsWeb
                ? Image.memory(base64Decode(imageFile.path), fit: BoxFit.cover)
                : Image.file(imageFile, fit: BoxFit.cover),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickBannerImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
