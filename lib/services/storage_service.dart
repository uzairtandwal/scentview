import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image [XFile] to Firebase Storage and returns the download URL.
  /// This method is platform-agnostic and works on both mobile and web.
  Future<String?> uploadImage(XFile image) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}-${image.name}';
      final Reference ref = _storage.ref().child('images/$fileName');

      // Read the file's data into memory as a Uint8List.
      final Uint8List data = await image.readAsBytes();

      // Upload the data to Firebase Storage. `putData` is the universal method.
      final UploadTask uploadTask = ref.putData(data);

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Log the error to the debug console for better diagnostics.
      print('Error uploading image: $e');
      return null;
    }
  }
}
