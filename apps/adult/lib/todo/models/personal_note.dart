import 'package:uuid/uuid.dart';

import '../../db/app_database.dart';

/// A note — plaintext or markdown, optionally shared via family key/WebDAV.
class PersonalNote {
  final String id;
  final String title;
  final String body;
  final bool isShared;
  final bool isContentHidden;
  final DateTime? remindAt;
  final String? category;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PersonalNote({
    required this.id,
    required this.title,
    required this.body,
    required this.isShared,
    this.isContentHidden = false,
    this.remindAt,
    this.category,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static PersonalNote create({
    required String title,
    String body = '',
    bool isShared = false,
    bool isContentHidden = false,
    DateTime? remindAt,
    String? category,
    int sortOrder = 0,
  }) {
    final now = DateTime.now().toUtc();
    return PersonalNote(
      id: const Uuid().v4(),
      title: title,
      body: body,
      isShared: isShared,
      isContentHidden: isContentHidden,
      remindAt: remindAt,
      category: category,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  static PersonalNote fromRow(PersonalNoteRow row) {
    return PersonalNote(
      id: row.id,
      title: row.title,
      body: row.body,
      isShared: row.isShared,
      isContentHidden: row.isContentHidden,
      remindAt: row.remindAt,
      category: row.category,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  PersonalNote copyWith({
    String? title,
    String? body,
    bool? isShared,
    bool? isContentHidden,
    DateTime? remindAt,
    bool clearRemindAt = false,
    String? category,
    bool clearCategory = false,
    int? sortOrder,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return PersonalNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      isShared: isShared ?? this.isShared,
      isContentHidden: isContentHidden ?? this.isContentHidden,
      remindAt: clearRemindAt ? null : (remindAt ?? this.remindAt),
      category: clearCategory ? null : (category ?? this.category),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  /// Preview for the notes list. Empty when content is hidden.
  String get bodyPreview {
    if (isContentHidden) return '';
    final plain = body
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'`+'), '')
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), ' ')
        .replaceAllMapped(RegExp(r'\[(.*?)\]\(.*?\)'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'[#*_>~|-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.isEmpty) return '';
    if (plain.length <= 160) return plain;
    return '${plain.substring(0, 160).trimRight()}…';
  }

  @override
  String toString() =>
      'PersonalNote(id: $id, title: $title, isShared: $isShared, '
      'isContentHidden: $isContentHidden)';
}
