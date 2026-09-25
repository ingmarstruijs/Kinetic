import 'package:kinetic_link_bridge/kinetic_link_bridge.dart';

import '../todo/models/personal_task.dart';
import '../todo/services/todo_repository.dart';

/// Adapts [TodoRepository] to bridge task RPCs.
class TodoBridgeTaskStore implements BridgeTaskStore {
  final TodoRepository repo;

  TodoBridgeTaskStore(this.repo);

  @override
  Future<List<BridgeTaskDto>> listTasks() async {
    final tasks = await repo.watchAllTasks().first;
    return tasks.map(_toDto).toList();
  }

  @override
  Future<BridgeTaskDto> createTask({
    required String title,
    String? notes,
  }) async {
    final created = await repo.createTask(title: title, notes: notes);
    return _toDto(created);
  }

  @override
  Future<BridgeTaskDto?> completeTask(String id) async {
    await repo.completeTask(id);
    final task = await repo.getTask(id);
    return task == null ? null : _toDto(task);
  }

  @override
  Future<BridgeTaskDto?> updateTask(
    String id, {
    String? title,
    String? notes,
  }) async {
    final existing = await repo.getTask(id);
    if (existing == null) return null;
    final updated = existing.copyWith(
      title: title ?? existing.title,
      notes: notes ?? existing.notes,
    );
    await repo.updateTask(updated);
    return _toDto(updated);
  }

  BridgeTaskDto _toDto(PersonalTask t) => BridgeTaskDto(
        id: t.id,
        title: t.title,
        isCompleted: t.isCompleted,
        notes: t.notes,
        dueAt: t.dueDate,
        updatedAt: t.updatedAt,
      );
}
