import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaService {
  MediaService({Directory? documents}) : _documents = documents;

  final ImagePicker _picker = ImagePicker();
  Directory? _documents;

  Future<Directory> get documents async =>
      _documents ??= await getApplicationDocumentsDirectory();

  Future<String?> pickAndStore(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;
    final root = await documents;
    final mediaDirectory = Directory(p.join(root.path, 'media'));
    await mediaDirectory.create(recursive: true);
    final relative =
        p.join('media', 'shot_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final destination = p.join(root.path, relative);
    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      destination,
      minWidth: 1280,
      minHeight: 1280,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) return null;
    return relative;
  }

  Future<File?> resolve(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final root = await documents;
    final file = File(p.join(root.path, relativePath));
    return await file.exists() ? file : null;
  }

  Future<void> delete(String? relativePath) async {
    final file = await resolve(relativePath);
    if (file != null) await file.delete();
  }

  Future<Uint8List?> pdfThumbnail(String? relativePath) async {
    final file = await resolve(relativePath);
    if (file == null) return null;
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 480,
        minHeight: 270,
        quality: 62,
        format: CompressFormat.jpeg,
      );
      return compressed ?? await file.readAsBytes();
    } catch (_) {
      return file.readAsBytes();
    }
  }
}
