import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adult/l10n/generated/app_localizations.dart';
import 'package:adult/todo/widgets/hour_first_time_picker.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  testWidgets('hour field is focused when the dialog opens', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showHourFirstTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 30),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final hourField = tester.widget<TextField>(
      find.byKey(const ValueKey('hour-field')),
    );
    expect(hourField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('OK returns the typed time', (tester) async {
    TimeOfDay? picked;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showHourFirstTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('hour-field')), '14');
    await tester.enterText(find.byKey(const ValueKey('minute-field')), '45');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(picked, const TimeOfDay(hour: 14, minute: 45));
  });
}
