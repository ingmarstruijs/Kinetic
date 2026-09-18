import 'package:kinetic_webdav/kinetic_webdav.dart';

/// In-memory overlay for debug UI scenarios. Never persisted; release builds
/// keep [active] false because the entry points are compiled out.
class KidsDemoSession {
  KidsDemoSession._();
  static final KidsDemoSession instance = KidsDemoSession._();

  static const kidId = 'demo-kid';
  static const linkTaskId = 'demo-link-task';

  bool active = false;
  KidGoal? goal;

  void apply({KidGoal? goal}) {
    active = true;
    this.goal = goal;
  }

  void clear() {
    active = false;
    goal = null;
  }
}
