import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/family/family_connection_service.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/todo/widgets/family_adults_section.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: home),
  );
}

void main() {
  testWidgets('shows adults with enabled Nudge when connected', (tester) async {
    FamilyMemberStatus? nudged;
    final now = DateTime.now().toUtc();

    await tester.pumpWidget(
      _app(
        FamilyAdultsSection(
          otherLinkMembers: const [(id: 'link-sam', name: 'Sam')],
          presence: [
            PresenceInfo(
              deviceId: 'link-sam',
              deviceType: 'link',
              displayName: 'Sam',
              lastSeen: now,
            ),
          ],
          onNudge: (member) async {
            nudged = member;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADULTS'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Nudge'), findsOneWidget);

    await tester.tap(find.text('Nudge'));
    await tester.pumpAndSettle();

    expect(nudged?.id, 'link-sam');
    expect(nudged?.name, 'Sam');
  });

  testWidgets('disables Nudge when adult is offline', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _app(
        FamilyAdultsSection(
          otherLinkMembers: const [(id: 'link-sam', name: 'Sam')],
          presence: const [],
          onNudge: (_) async {
            tapped = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nudge'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text('Nudge'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('hides section when there are no other adults', (tester) async {
    await tester.pumpWidget(
      _app(const FamilyAdultsSection(otherLinkMembers: [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADULTS'), findsNothing);
    expect(find.text('Nudge'), findsNothing);
  });
}
