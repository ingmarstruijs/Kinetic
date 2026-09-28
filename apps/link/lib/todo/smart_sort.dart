import '../theme/app_themes.dart';
import 'models/enums.dart';
import 'models/personal_task.dart';
import 'models/personal_note.dart';

/// Urgency rank for smart task sort (lower = more urgent).
int taskSmartRank(PersonalTask task) {
  final due = task.dueDate;
  if (due != null && isOverdue(due, isAllDay: task.isAllDay)) return 0;

  if (due != null && _isSameLocalDay(due, DateTime.now())) return 1;

  switch (task.priority) {
    case TaskPriority.high:
      return 2;
    case TaskPriority.medium:
      return 3;
    case TaskPriority.low:
      return 5;
    case TaskPriority.none:
      break;
  }

  if (due != null) return 4;
  return 6;
}

int compareTasksSmart(PersonalTask a, PersonalTask b) {
  final rank = taskSmartRank(a).compareTo(taskSmartRank(b));
  if (rank != 0) return rank;

  final aDue = a.dueDate;
  final bDue = b.dueDate;
  if (aDue != null && bDue != null) {
    final byDue = aDue.compareTo(bDue);
    if (byDue != 0) return byDue;
  } else if (aDue != null) {
    return -1;
  } else if (bDue != null) {
    return 1;
  }

  final byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;
  return a.createdAt.compareTo(b.createdAt);
}

/// Category order: most urgent task in the group first.
int compareTaskCategoriesSmart(
  String? a,
  String? b,
  Map<String?, List<PersonalTask>> groups,
) {
  final aRank = _bestTaskRank(groups[a] ?? const []);
  final bRank = _bestTaskRank(groups[b] ?? const []);
  final byRank = aRank.compareTo(bRank);
  if (byRank != 0) return byRank;
  return (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());
}

int _bestTaskRank(List<PersonalTask> tasks) {
  if (tasks.isEmpty) return 99;
  var best = 99;
  for (final t in tasks) {
    final r = taskSmartRank(t);
    if (r < best) best = r;
  }
  return best;
}

int compareNotesSmart(PersonalNote a, PersonalNote b) {
  final byUpdated = b.updatedAt.compareTo(a.updatedAt);
  if (byUpdated != 0) return byUpdated;
  final byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;
  return b.createdAt.compareTo(a.createdAt);
}

/// Category order: most recently updated note first.
int compareNoteCategoriesSmart(
  String? a,
  String? b,
  Map<String?, List<PersonalNote>> groups,
) {
  final aAt = _newestNoteAt(groups[a] ?? const []);
  final bAt = _newestNoteAt(groups[b] ?? const []);
  final byTime = bAt.compareTo(aAt);
  if (byTime != 0) return byTime;
  return (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());
}

DateTime _newestNoteAt(List<PersonalNote> notes) {
  if (notes.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  var newest = notes.first.updatedAt;
  for (final n in notes.skip(1)) {
    if (n.updatedAt.isAfter(newest)) newest = n.updatedAt;
  }
  return newest;
}

bool _isSameLocalDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}
