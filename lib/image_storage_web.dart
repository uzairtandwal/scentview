import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

// This is a placeholder for a File class on web.
class File {
  final String path;
  File(this.path);

  Future<Uint8List> readAsBytes() async {
    return base64Decode(path);
  }
}

class ImageStorage {
  static const _bannerImagesKey = 'banner_images';

  Future<List<File>> getBannerImages() async {
    final prefs = await SharedPreferences.getInstance();
    final imageStrings = prefs.getStringList(_bannerImagesKey) ?? [];
    return imageStrings.map((s) => File(s)).toList();
  }

  Future<File> saveBannerImage(List<int> bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final imageStrings = prefs.getStringList(_bannerImagesKey) ?? [];
    final newImageString = base64Encode(bytes);
    imageStrings.add(newImageString);
    await prefs.setStringList(_bannerImagesKey, imageStrings);
    return File(newImageString);
  }

  Future<void> deleteBannerImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final imageStrings = prefs.getStringList(_bannerImagesKey) ?? [];
    imageStrings.remove(imageFile.path);
    await prefs.setStringList(_bannerImagesKey, imageStrings);
  }
}
