import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../services/note_asset_store.dart';

/// Renders `kinetic-asset://` image embeds from [NoteAssetStore].
class KineticNoteImageEmbedBuilder extends EmbedBuilder {
  KineticNoteImageEmbedBuilder(this.store);

  final NoteAssetStore store;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final source = embedContext.node.value.data;
    final assetId = NoteAssetStore.parseId(source);
    if (assetId == null) {
      return Image.network(
        source,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: store.readBytes(assetId),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
        );
      },
    );
  }
}

/// Inserts a local image embed at the current selection.
void insertNoteImageEmbed(QuillController controller, String assetUri) {
  final index = controller.selection.baseOffset;
  final length = controller.selection.extentOffset - index;
  controller.replaceText(
    index,
    length,
    BlockEmbed.image(assetUri),
    TextSelection.collapsed(offset: index + 1),
  );
  // Keep a newline after the image for continued typing.
  controller.replaceText(
    index + 1,
    0,
    '\n',
    TextSelection.collapsed(offset: index + 2),
  );
}

/// Collects kinetic-asset ids referenced in markdown.
Set<String> noteAssetIdsInMarkdown(String markdown) {
  final ids = <String>{};
  final re = RegExp(r'!\[[^\]]*\]\((kinetic-asset://[^)]+)\)');
  for (final match in re.allMatches(markdown)) {
    final id = NoteAssetStore.parseId(match.group(1)!);
    if (id != null) ids.add(id);
  }
  // Also catch raw URIs without markdown wrapper.
  final re2 = RegExp(r'kinetic-asset://([a-zA-Z0-9\-]+)');
  for (final match in re2.allMatches(markdown)) {
    ids.add(match.group(1)!);
  }
  return ids;
}

String mimeFromMagic(Uint8List bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46) {
    return 'image/webp';
  }
  return 'image/jpeg';
}
