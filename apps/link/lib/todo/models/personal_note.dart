import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../db/app_database.dart';

/// A note — plaintext or markdown, optionally shared via family key/WebDAV.
class PersonalNote {
  final String id;
  final String title;
  final String body;
  final bool isShared;

  /// Link member ids this note is shared with; null or empty together with
  /// [isShared] means every link member in the family roster.
  final List<String>? sharedMemberIds;

  final bool isContentHidden;

  /// Body and links stay on this device only; never pushed to WebDAV.
  final bool isLocalOnly;

  /// Personal task ids cross-linked from this note.
  final List<String>? linkedTaskIds;

  final DateTime? remindAt;
  final String? category;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Link member id of the last editor (synced for shared notes).
  final String? updatedByLinkId;

  final DateTime? deletedAt;

  const PersonalNote({
    required this.id,
    required this.title,
    required this.body,
    required this.isShared,
    this.sharedMemberIds,
    this.isContentHidden = false,
    this.isLocalOnly = false,
    this.linkedTaskIds,
    this.remindAt,
    this.category,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.updatedByLinkId,
    this.deletedAt,
  });

  static PersonalNote create({
    required String title,
    String body = '',
    bool isShared = false,
    List<String>? sharedMemberIds,
    bool isContentHidden = false,
    bool isLocalOnly = false,
    List<String>? linkedTaskIds,
    DateTime? remindAt,
    String? category,
    int sortOrder = 0,
    String? updatedByLinkId,
  }) {
    final now = DateTime.now().toUtc();
    return PersonalNote(
      id: const Uuid().v4(),
      title: title,
      body: body,
      isShared: isShared,
      sharedMemberIds: sharedMemberIds,
      isContentHidden: isContentHidden,
      isLocalOnly: isLocalOnly,
      linkedTaskIds: linkedTaskIds,
      remindAt: remindAt,
      category: category,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
      updatedByLinkId: updatedByLinkId,
    );
  }

  static PersonalNote fromRow(PersonalNoteRow row) {
    return PersonalNote(
      id: row.id,
      title: row.title,
      body: row.body,
      isShared: row.isShared,
      sharedMemberIds: decodeSharedMemberIds(row.sharedMemberIds),
      isContentHidden: row.isContentHidden,
      isLocalOnly: row.isLocalOnly,
      linkedTaskIds: decodeLinkedTaskIds(row.linkedTaskIds),
      remindAt: row.remindAt,
      category: row.category,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      updatedByLinkId: row.updatedByLinkId,
      deletedAt: row.deletedAt,
    );
  }

  /// Decodes the JSON list stored in `personal_notes.linked_task_ids`.
  static List<String>? decodeLinkedTaskIds(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final ids = decoded.whereType<String>().where((s) => s.isNotEmpty).toList();
      return ids.isEmpty ? null : ids;
    } catch (_) {
      return null;
    }
  }

  /// Decodes the JSON list stored in `personal_notes.shared_member_ids`.
  static List<String>? decodeSharedMemberIds(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final ids = decoded.whereType<String>().where((s) => s.isNotEmpty).toList();
      return ids.isEmpty ? null : ids;
    } catch (_) {
      return null;
    }
  }

  /// JSON for the row column; null when the note is shared with all link members.
  String? get sharedMemberIdsJson {
    final ids = sharedMemberIds;
    if (ids == null || ids.isEmpty) return null;
    return jsonEncode(ids);
  }

  String? get linkedTaskIdsJson {
    final ids = linkedTaskIds;
    if (ids == null || ids.isEmpty) return null;
    return jsonEncode(ids);
  }

  bool isLinkedToTask(String taskId) {
    final ids = linkedTaskIds;
    if (ids == null || ids.isEmpty) return false;
    return ids.contains(taskId);
  }

  /// True when this note reaches [linkMemberId] (all-members notes included).
  bool isSharedWith(String linkMemberId) {
    if (!isShared) return false;
    final ids = sharedMemberIds;
    if (ids == null || ids.isEmpty) return true;
    return ids.contains(linkMemberId);
  }

  PersonalNote copyWith({
    String? title,
    String? body,
    bool? isShared,
    List<String>? sharedMemberIds,
    bool clearSharedMemberIds = false,
    bool? isContentHidden,
    bool? isLocalOnly,
    List<String>? linkedTaskIds,
    bool clearLinkedTaskIds = false,
    DateTime? remindAt,
    bool clearRemindAt = false,
    String? category,
    bool clearCategory = false,
    int? sortOrder,
    String? updatedByLinkId,
    bool clearUpdatedByLinkId = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return PersonalNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      isShared: isShared ?? this.isShared,
      sharedMemberIds: clearSharedMemberIds
          ? null
          : (sharedMemberIds ?? this.sharedMemberIds),
      isContentHidden: isContentHidden ?? this.isContentHidden,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      linkedTaskIds: clearLinkedTaskIds
          ? null
          : (linkedTaskIds ?? this.linkedTaskIds),
      remindAt: clearRemindAt ? null : (remindAt ?? this.remindAt),
      category: clearCategory ? null : (category ?? this.category),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      updatedByLinkId: clearUpdatedByLinkId
          ? null
          : (updatedByLinkId ?? this.updatedByLinkId),
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
