import 'package:flutter/foundation.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../settings/models/enrolled_kid.dart';

/// In-memory overlay for debug UI scenarios. Never persisted; release builds
/// keep [active] false because the settings entry is compiled out.
class DemoSession extends ChangeNotifier {
  DemoSession._();
  static final DemoSession instance = DemoSession._();

  static const linkId = 'demo-link';
  static const linkMemberId = 'demo-link-member';
  static const secondLinkMemberId = 'demo-link-member-2';
  static const selfDisplayName = 'You';
  static const linkMemberDisplayName = 'Alex';
  static const secondLinkMemberDisplayName = 'Sam';

  /// Other Kinetic Link members seeded when a family overlay is active.
  static const otherDemoMembers = <({String id, String name})>[
    (id: linkMemberId, name: linkMemberDisplayName),
    (id: secondLinkMemberId, name: secondLinkMemberDisplayName),
  ];

  bool active = false;
  bool hasOtherLinkMembers = false;
  List<EnrolledKid> kids = const [];
  List<ICalTask> kidTasks = const [];
  FamilyRoster? roster;
  List<PresenceInfo> presence = const [];
  List<LoadMetrics> loadMetrics = const [];

  /// Other link members for notes / assign UI (excludes this device).
  List<({String id, String name})> get otherLinkMembers {
    final r = roster;
    if (r == null) return const [];
    return [
      for (final m in r.otherLinkMembers(linkId))
        (id: m.id, name: m.displayName),
    ];
  }

  SyncConfig dummyConfig() => SyncConfig(
    serverUrl: 'https://demo.invalid',
    username: 'demo',
    password: 'demo',
    linkId: linkId,
    personalKeyBytes: Uint8List(32),
    familyKeyBytes: Uint8List(32),
  );

  void apply({
    required bool hasOtherLinkMembers,
    required List<EnrolledKid> kids,
    required List<ICalTask> kidTasks,
    FamilyRoster? roster,
    List<PresenceInfo> presence = const [],
    List<LoadMetrics> loadMetrics = const [],
  }) {
    active = true;
    this.hasOtherLinkMembers = hasOtherLinkMembers;
    this.kids = kids;
    this.kidTasks = kidTasks;
    this.roster = roster;
    this.presence = presence;
    this.loadMetrics = loadMetrics;
    notifyListeners();
  }

  void removeKidTask(String uid) {
    kidTasks = [
      for (final task in kidTasks)
        if (task.uid != uid) task,
    ];
    notifyListeners();
  }

  /// Demo accept: mark pending chore completed.
  void acceptKidTask(String uid) {
    kidTasks = [
      for (final task in kidTasks)
        if (task.uid == uid)
          task.copyWith(
            status: ICalTaskStatus.completed,
            updatedAt: DateTime.now().toUtc(),
          )
        else
          task,
    ];
    notifyListeners();
  }

  /// Demo reject: send pending chore back to open.
  void rejectKidTask(String uid) {
    kidTasks = [
      for (final task in kidTasks)
        if (task.uid == uid)
          task.copyWith(
            status: ICalTaskStatus.needsAction,
            updatedAt: DateTime.now().toUtc(),
          )
        else
          task,
    ];
    notifyListeners();
  }

  void updateKid(EnrolledKid kid) {
    kids = [
      for (final existing in kids)
        if (existing.id == kid.id) kid else existing,
    ];
    notifyListeners();
  }

  void clear() {
    active = false;
    hasOtherLinkMembers = false;
    kids = const [];
    kidTasks = const [];
    roster = null;
    presence = const [];
    loadMetrics = const [];
    notifyListeners();
  }
}
