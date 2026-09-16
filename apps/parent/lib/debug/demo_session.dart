import 'package:flutter/foundation.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../settings/models/enrolled_kid.dart';

/// In-memory overlay for debug UI scenarios. Never persisted; release builds
/// keep [active] false because the settings entry is compiled out.
class DemoSession extends ChangeNotifier {
  DemoSession._();
  static final DemoSession instance = DemoSession._();

  static const parentId = 'demo-parent';
  static const partnerId = 'demo-partner';

  bool active = false;
  bool partnerPaired = false;
  List<EnrolledKid> kids = const [];
  List<ICalTask> kidTasks = const [];

  SyncConfig dummyConfig() => SyncConfig(
    serverUrl: 'https://demo.invalid',
    username: 'demo',
    password: 'demo',
    parentId: parentId,
    personalKeyBytes: Uint8List(32),
    familyKeyBytes: Uint8List(32),
  );

  void apply({
    required bool partnerPaired,
    required List<EnrolledKid> kids,
    required List<ICalTask> kidTasks,
  }) {
    active = true;
    this.partnerPaired = partnerPaired;
    this.kids = kids;
    this.kidTasks = kidTasks;
    notifyListeners();
  }

  void removeKidTask(String uid) {
    kidTasks = [
      for (final task in kidTasks)
        if (task.uid != uid) task,
    ];
    notifyListeners();
  }

  void clear() {
    active = false;
    partnerPaired = false;
    kids = const [];
    kidTasks = const [];
    notifyListeners();
  }
}
