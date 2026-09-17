import 'package:flutter_test/flutter_test.dart';
import 'package:parent/todo/models/personal_note.dart';

void main() {
  test('bodyPreview strips markdown and collapses whitespace', () {
    final note = PersonalNote.create(
      title: 'Menu',
      body: '# Week\n\n**Ma:** pasta\n\n[link](https://example.com)',
    );
    expect(note.bodyPreview, 'Week Ma: pasta link');
  });

  test('bodyPreview is empty when the body has no text', () {
    final note = PersonalNote.create(title: 'Empty', body: '   \n#  ');
    expect(note.bodyPreview, isEmpty);
  });

  test('bodyPreview is empty when content is hidden', () {
    final note = PersonalNote.create(
      title: 'Secret',
      body: 'Do not show this in the list',
      isContentHidden: true,
    );
    expect(note.bodyPreview, isEmpty);
    expect(note.isContentHidden, isTrue);
  });
}
