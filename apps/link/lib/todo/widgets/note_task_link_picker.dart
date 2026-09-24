import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/personal_task.dart';
import '../services/todo_repository.dart';

/// Bottom sheet to pick open tasks to link from a note.
Future<List<String>?> showNoteTaskLinkPicker({
  required BuildContext context,
  required TodoRepository todoRepo,
  required Set<String> alreadyLinked,
}) async {
  final tasks = await todoRepo.watchOpenTasks().first;
  if (!context.mounted) return null;
  if (tasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).notesLinkTaskEmpty)),
    );
    return null;
  }

  final selected = <String>{...alreadyLinked};
  return showModalBottomSheet<List<String>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModal) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text(AppLocalizations.of(ctx).notesLinkTask)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return CheckboxListTile(
                        value: selected.contains(task.id),
                        onChanged: (v) {
                          setModal(() {
                            if (v == true) {
                              selected.add(task.id);
                            } else {
                              selected.remove(task.id);
                            }
                          });
                        },
                        title: Text(task.title),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      ctx,
                      selected.isEmpty ? <String>[] : selected.toList(),
                    ),
                    child: Text(AppLocalizations.of(ctx).commonSave),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Resolves task titles for linked ids (best-effort).
Future<Map<String, String>> linkedTaskTitles(
  TodoRepository todoRepo,
  List<String> taskIds,
) async {
  final open = await todoRepo.watchOpenTasks().first;
  final completed = await todoRepo.watchCompletedTasks().first;
  final all = <PersonalTask>[...open, ...completed];
  final map = <String, String>{};
  for (final id in taskIds) {
    final task = all.where((t) => t.id == id).firstOrNull;
    if (task != null) map[id] = task.title;
  }
  return map;
}
