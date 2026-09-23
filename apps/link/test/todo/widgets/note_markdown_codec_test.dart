import 'package:flutter_test/flutter_test.dart';
import 'package:link/todo/widgets/note_markdown_codec.dart';

void main() {
  group('NoteMarkdownCodec', () {
    test('empty markdown yields empty plain text', () {
      final doc = NoteMarkdownCodec.documentFromMarkdown('');
      expect(NoteMarkdownCodec.markdownFromDocument(doc).trim(), isEmpty);
    });

    test('whitespace-only markdown yields empty document', () {
      final doc = NoteMarkdownCodec.documentFromMarkdown('   \n  ');
      expect(NoteMarkdownCodec.markdownFromDocument(doc).trim(), isEmpty);
    });

    test('bold round-trips', () {
      const input = 'Hello **world**';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out, contains('**world**'));
      expect(out, contains('Hello'));
    });

    test('italic round-trips', () {
      const input = 'Say *hello*';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(
        out.contains('*hello*') || out.contains('_hello_'),
        isTrue,
        reason: 'got: $out',
      );
    });

    test('heading round-trips', () {
      const input = '## Title';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out, contains('##'));
      expect(out, contains('Title'));
    });

    test('bullet list round-trips', () {
      const input = '- One\n- Two';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out, contains('One'));
      expect(out, contains('Two'));
      expect(out.contains('-') || out.contains('*'), isTrue);
    });

    test('checkbox round-trips', () {
      const input = '- [ ] Todo\n- [x] Done';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out.toLowerCase(), contains('todo'));
      expect(out.toLowerCase(), contains('done'));
    });

    test('link round-trips', () {
      const input = '[Kinetic](https://example.com)';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out, contains('Kinetic'));
      expect(out, contains('https://example.com'));
    });

    test('plain text never fails to open', () {
      const input = 'Just a plain note without markup.';
      final doc = NoteMarkdownCodec.documentFromMarkdown(input);
      final out = NoteMarkdownCodec.markdownFromDocument(doc);
      expect(out, contains('Just a plain note'));
    });
  });
}
