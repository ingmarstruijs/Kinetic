import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Reads bytes from a [PlatformFile], falling back to [path] when [bytes] is
/// null (common on Android when [FilePicker] is used with `withData: true`).
Future<Uint8List?> readPlatformFileBytes(PlatformFile file) async {
  final inline = file.bytes;
  if (inline != null && inline.isNotEmpty) {
    return inline;
  }
  final path = file.path;
  if (path == null || path.isEmpty) return null;
  try {
    return await File(path).readAsBytes();
  } catch (_) {
    return null;
  }
}
