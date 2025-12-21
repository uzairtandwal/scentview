import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ImageStorage {
  Future<Directory> get _bannersDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final bannersDir = Directory('${appDir.path}/banners');
    if (!bannersDir.existsSync()) {
      bannersDir.createSync();
    }
    return bannersDir;
  }

  Future<List<File>> getBannerImages() async {
    final dir = await _bannersDir;
    return dir.listSync().whereType<File>().toList();
  }

  Future<File> saveBannerImage(List<int> bytes) async {
    final dir = await _bannersDir;
    final newImage = File(
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await newImage.writeAsBytes(bytes);
    return newImage;
  }

  Future<void> deleteBannerImage(File imageFile) async {
    await imageFile.delete();
  }
}
