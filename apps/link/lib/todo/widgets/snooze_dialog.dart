import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'hour_first_time_picker.dart';

enum SnoozeChoice { tenMinutes, oneHour, threeHours, tomorrowMorning, custom }

/// Resolves a snooze preset to an absolute local [DateTime].
DateTime resolveSnoozeUntil(
  SnoozeChoice choice, {
  required DateTime now,
  TimeOfDay? custom,
}) {
  switch (choice) {
    case SnoozeChoice.tenMinutes:
      return now.add(const Duration(minutes: 10));
    case SnoozeChoice.oneHour:
      return now.add(const Duration(hours: 1));
    case SnoozeChoice.threeHours:
      return now.add(const Duration(hours: 3));
    case SnoozeChoice.tomorrowMorning:
      return DateTime(now.year, now.month, now.day + 1, 9);
    case SnoozeChoice.custom:
      final t = custom ?? TimeOfDay(hour: now.hour, minute: now.minute);
      var at = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
      return at;
  }
}

/// Asks how long to snooze a reminder. Returns `null` if cancelled.
Future<DateTime?> showSnoozeDialog(BuildContext context) async {
  final choice = await showModalBottomSheet<SnoozeChoice>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final sheetL10n = AppLocalizations.of(ctx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sheetL10n.snoozeTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(sheetL10n.snooze10min),
              onTap: () => Navigator.pop(ctx, SnoozeChoice.tenMinutes),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: Text(sheetL10n.snooze1hour),
              onTap: () => Navigator.pop(ctx, SnoozeChoice.oneHour),
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_bottom_outlined),
              title: Text(sheetL10n.snooze3hours),
              onTap: () => Navigator.pop(ctx, SnoozeChoice.threeHours),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(sheetL10n.snoozeTomorrowMorning),
              onTap: () => Navigator.pop(ctx, SnoozeChoice.tomorrowMorning),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(sheetL10n.snoozeCustom),
              onTap: () => Navigator.pop(ctx, SnoozeChoice.custom),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (choice == null) return null;

  TimeOfDay? custom;
  if (choice == SnoozeChoice.custom) {
    if (!context.mounted) return null;
    custom = await showHourFirstTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (custom == null) return null;
  }

  return resolveSnoozeUntil(choice, now: DateTime.now(), custom: custom);
}
