import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

/// Converts between stored note markdown and Quill [Document] for editing.
class NoteMarkdownCodec {
  NoteMarkdownCodec._();

  static final md.Document _mdDocument = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  static final MarkdownToDelta _mdToDelta = MarkdownToDelta(
    markdownDocument: _mdDocument,
  );

  static final DeltaToMarkdown _deltaToMd = DeltaToMarkdown();

  /// Opens a Quill document from a markdown body string.
  ///
  /// Empty or whitespace-only input yields an empty document. On conversion
  /// failure the raw text is inserted as plain content so notes still open.
  static Document documentFromMarkdown(String markdown) {
    final trimmed = markdown.trim();
    if (trimmed.isEmpty) return Document();
    try {
      final delta = _mdToDelta.convert(markdown);
      if (delta.isEmpty) {
        return Document()..insert(0, markdown);
      }
      return Document.fromDelta(delta);
    } catch (_) {
      return Document()..insert(0, markdown);
    }
  }

  /// Serializes the Quill document back to markdown for storage/sync.
  static String markdownFromDocument(Document document) {
    try {
      final markdown = _deltaToMd.convert(document.toDelta());
      return markdown.trimRight();
    } catch (_) {
      return document.toPlainText().trimRight();
    }
  }
}
