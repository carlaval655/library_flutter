import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  Future<String> uploadProfileImage(File file, String userId) async {
    final storage = Supabase.instance.client.storage;

    final filePath = 'profile-pictures/$userId.jpg';

    await storage.from('profile-pictures').upload(
      filePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = storage.from('profile-pictures').getPublicUrl(filePath);

    return publicUrl;
  }
}