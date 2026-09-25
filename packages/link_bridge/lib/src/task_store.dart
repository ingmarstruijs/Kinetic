import 'task_dto.dart';

/// Persistence behind bridge task RPCs (in-memory for tests, Drift on phone).
abstract class BridgeTaskStore {
  Future<List<BridgeTaskDto>> listTasks();

  Future<BridgeTaskDto> createTask({required String title, String? notes});

  Future<BridgeTaskDto?> completeTask(String id);

  Future<BridgeTaskDto?> updateTask(
    String id, {
    String? title,
    String? notes,
  });
}

/// Simple map-backed store for protocol unit tests.
class InMemoryTaskStore implements BridgeTaskStore {
  final Map<String, BridgeTaskDto> _tasks = {};
  var _seq = 0;
  DateTime Function() clock;

  InMemoryTaskStore({DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());

  void seed(BridgeTaskDto task) => _tasks[task.id] = task;

  @override
  Future<List<BridgeTaskDto>> listTasks() async {
    final list = _tasks.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return list;
  }

  @override
  Future<BridgeTaskDto> createTask({
    required String title,
    String? notes,
  }) async {
    final id = 't-${++_seq}';
    final task = BridgeTaskDto(
      id: id,
      title: title,
      isCompleted: false,
      notes: notes,
      updatedAt: clock(),
    );
    _tasks[id] = task;
    return task;
  }

  @override
  Future<BridgeTaskDto?> completeTask(String id) async {
    final task = _tasks[id];
    if (task == null) return null;
    final updated = BridgeTaskDto(
      id: task.id,
      title: task.title,
      isCompleted: true,
      notes: task.notes,
      dueAt: task.dueAt,
      updatedAt: clock(),
    );
    _tasks[id] = updated;
    return updated;
  }

  @override
  Future<BridgeTaskDto?> updateTask(
    String id, {
    String? title,
    String? notes,
  }) async {
    final task = _tasks[id];
    if (task == null) return null;
    final updated = BridgeTaskDto(
      id: task.id,
      title: title ?? task.title,
      isCompleted: task.isCompleted,
      notes: notes ?? task.notes,
      dueAt: task.dueAt,
      updatedAt: clock(),
    );
    _tasks[id] = updated;
    return updated;
  }
}
