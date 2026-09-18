import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/todo/models/ai_suggestion.dart';
import 'package:link/todo/services/suggestion_actions.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final nl = lookupAppLocalizations(const Locale('nl'));

  test('load-balance copy follows the UI locale', () {
    final suggestion = AiSuggestion.create(
      title: 'Can you pick something up this week?',
      reason: SuggestionReason.loadBalance,
      category: 'other',
      relatedTaskIds: const ['a', 'b', 'c', 'd', 'e'],
      explanation:
          'You have 5 open tasks in Other. The suggestion is intentionally generic.',
    );

    expect(suggestionDisplayTitle(suggestion, en), contains('this week'));
    expect(
      suggestionDisplayTitle(suggestion, nl),
      'Kun jij deze week iets oppakken?',
    );
    expect(
      suggestionDisplayExplanation(suggestion, nl),
      contains('5 open taken'),
    );
    expect(suggestionDisplayExplanation(suggestion, nl), contains('Overig'));
    expect(
      suggestionDisplayExplanation(suggestion, nl),
      isNot(contains('Other')),
    );
  });

  test('calendar and partner templates localize from dedupe keys', () {
    final calendar = AiSuggestion.create(
      title: 'Check tax return',
      reason: SuggestionReason.calendar,
      dedupeKey: 'calendar:tax-return',
      explanation: 'March — time to check the tax return.',
    );
    expect(
      suggestionDisplayTitle(calendar, nl),
      'Belastingaangifte controleren',
    );

    final partner = AiSuggestion.create(
      title: 'School run or childcare this week?',
      reason: SuggestionReason.partnerComplement,
      dedupeKey: 'partnerComplement:school',
    );
    expect(
      suggestionDisplayTitle(partner, nl),
      'Schoolrondje of opvang deze week?',
    );
  });

  test('habit titles stay as the user wrote them', () {
    final suggestion = AiSuggestion.create(
      title: 'Boodschappen',
      reason: SuggestionReason.habit,
      explanation: 'You did "Boodschappen" 8 days ago. Schedule again?',
    );
    expect(suggestionDisplayTitle(suggestion, nl), 'Boodschappen');
  });
}
