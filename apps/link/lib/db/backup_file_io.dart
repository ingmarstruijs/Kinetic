import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Reads bytes from a [PlatformFile], falling back to [path] when needed.
Future<Uint8List?> readPlatformFileBytes(PlatformFile file) async {
  try {
    final inline = await file.readAsBytes();
    if (inline.isNotEmpty) return inline;
  } catch (_) {}
  final path = file.path;
  if (path == null || path.isEmpty) return null;
  try {
    return await File(path).readAsBytes();
  } catch (_) {
    return null;
  }
}
