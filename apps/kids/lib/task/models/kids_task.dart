/// Task category — matches link app TaskCategory
enum TaskCategory { household, school, health, shopping, entertainment, other }

/// Task priority — matches link app TaskPriority
enum TaskPriority { low, normal, high, urgent }

/// KidsTask — a task assigned by Link to this child
///
/// Mirrors PersonalTask from link app but: read-only for most fields
/// (assigned from the link app), editable only for completion / verification status.
class KidsTask {
  final String id;
  final String linkTaskId;
  final String title;
  final String? notes;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;

  /// True only after the link app accepted completion (XP counts).
  final bool isCompleted;

  /// True while waiting for link-app accept/reject.
  final bool awaitingVerification;

  final DateTime? completedAt;
  final int xpReward;

  /// Local-only: hidden from the completed list after cleanup (XP still counts).
  final bool clearedFromHome;

  final String syncState;
  final String? webdavEtag;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KidsTask({
    required this.id,
    required this.linkTaskId,
    required this.title,
    this.notes,
    required this.category,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
    this.awaitingVerification = false,
    this.completedAt,
    this.xpReward = 10,
    this.clearedFromHome = false,
    required this.syncState,
    this.webdavEtag,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => !isCompleted && !awaitingVerification;

  /// Request completion — pending link-app verification (does not award XP yet).
  KidsTask requestComplete() => copyWith(
        isCompleted: false,
        awaitingVerification: true,
        completedAt: null,
        clearedFromHome: false,
        syncState: 'dirty',
        updatedAt: DateTime.now().toUtc(),
      );

  /// Link accepted — XP-eligible.
  KidsTask markAccepted() => copyWith(
        isCompleted: true,
        awaitingVerification: false,
        completedAt: DateTime.now().toUtc(),
        clearedFromHome: false,
        syncState: 'clean',
        updatedAt: DateTime.now().toUtc(),
      );

  /// Link app rejected or reset to open.
  KidsTask markOpen() => copyWith(
        isCompleted: false,
        awaitingVerification: false,
        completedAt: null,
        clearedFromHome: false,
        syncState: 'dirty',
        updatedAt: DateTime.now().toUtc(),
      );

  KidsTask copyWith({
    String? id,
    String? linkTaskId,
    String? title,
    String? notes,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    bool? awaitingVerification,
    DateTime? completedAt,
    int? xpReward,
    bool? clearedFromHome,
    String? syncState,
    String? webdavEtag,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KidsTask(
      id: id ?? this.id,
      linkTaskId: linkTaskId ?? this.linkTaskId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      awaitingVerification:
          awaitingVerification ?? this.awaitingVerification,
      completedAt: completedAt ?? this.completedAt,
      xpReward: xpReward ?? this.xpReward,
      clearedFromHome: clearedFromHome ?? this.clearedFromHome,
      syncState: syncState ?? this.syncState,
      webdavEtag: webdavEtag ?? this.webdavEtag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDueToday {
    if (dueDate == null || isCompleted || awaitingVerification) return false;
    final today = DateTime.now();
    final d = dueDate!.toLocal();
    return d.year <= today.year && d.month <= today.month && d.day <= today.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted || awaitingVerification) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  String toString() =>
      'KidsTask(id: $id, title: $title, completed: $isCompleted, pending: $awaitingVerification)';
}
