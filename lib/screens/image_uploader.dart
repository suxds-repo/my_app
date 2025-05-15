import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

Future<String?> uploadImageFromPhone() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage == null) return null;

  final file = File(pickedImage.path);
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
  final fileBytes = await file.readAsBytes();
  final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';

  final storage = Supabase.instance.client.storage;

  try {
    await storage
        .from('event-images')
        .uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = storage.from('event-images').getPublicUrl(fileName);
    return publicUrl;
  } catch (e) {
    print('Image upload error: $e');
    return null;
  }
}
