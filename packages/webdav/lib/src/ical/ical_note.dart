/// A note in the iCal wire format (VJOURNAL component).
class ICalNote {
  final String uid;

  /// SUMMARY — the note title.
  final String summary;

  /// DESCRIPTION — the note body (may contain Markdown).
  final String? description;

  /// If true, this note is stored in the shared WebDAV folder with the
  /// family key.  False = personal note, personal key.
  final bool isShared;

  /// Link member ids this note is shared with. Null/empty = all link members.
  final List<String>? sharedMemberIds;

  /// Link member id of the last editor.
  final String? updatedByLinkId;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optional reminder timestamp → maps to VALARM + TRIGGER.
  final DateTime? remindAt;

  /// Linked [PersonalTasks] ids (Kinetic Link); synced via X-KINETIC-LINK-TASK-IDS.
  final List<String>? linkedTaskIds;

  const ICalNote({
    required this.uid,
    required this.summary,
    this.description,
    this.isShared = false,
    this.sharedMemberIds,
    this.updatedByLinkId,
    required this.createdAt,
    required this.updatedAt,
    this.remindAt,
    this.linkedTaskIds,
  });

  ICalNote copyWith({
    String? uid,
    String? summary,
    String? description,
    bool? isShared,
    List<String>? sharedMemberIds,
    bool clearSharedMemberIds = false,
    String? updatedByLinkId,
    bool clearUpdatedByLinkId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? remindAt,
    List<String>? linkedTaskIds,
    bool clearLinkedTaskIds = false,
  }) {
    return ICalNote(
      uid: uid ?? this.uid,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      isShared: isShared ?? this.isShared,
      sharedMemberIds: clearSharedMemberIds
          ? null
          : (sharedMemberIds ?? this.sharedMemberIds),
      updatedByLinkId: clearUpdatedByLinkId
          ? null
          : (updatedByLinkId ?? this.updatedByLinkId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remindAt: remindAt ?? this.remindAt,
      linkedTaskIds: clearLinkedTaskIds
          ? null
          : (linkedTaskIds ?? this.linkedTaskIds),
    );
  }

  @override
  String toString() =>
      'ICalNote(uid: $uid, summary: $summary, isShared: $isShared)';
}
