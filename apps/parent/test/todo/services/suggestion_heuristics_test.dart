import 'package:flutter_test/flutter_test.dart';
import 'package:parent/todo/services/suggestion_heuristics.dart';

void main() {
  group('matchPartnerHint', () {
    test('maps school keywords to a generic title', () {
      final hint = matchPartnerHint(title: 'Afspraak GZA schoolarts');
      expect(hint, isNotNull);
      expect(hint!.familyId, 'school');
      expect(hint.partnerTitle, isNot(contains('GZA')));
    });

    test('does not match a title without keywords', () {
      expect(matchPartnerHint(title: 'Ramen lappen'), isNull);
    });
  });

  group('calendarPromptsForMonth', () {
    test('March has tax return', () {
      final prompts = calendarPromptsForMonth(3);
      expect(prompts.any((p) => p.title.contains('tax')), isTrue);
    });

    test('June has none', () {
      expect(calendarPromptsForMonth(6), isEmpty);
    });
  });

  group('isStrongHabitTitle', () {
    test('boodschappen is strong', () {
      expect(isStrongHabitTitle('Boodschappen doen'), isTrue);
    });

    test('random title is not', () {
      expect(isStrongHabitTitle('Vergadering voorbereiden'), isFalse);
    });
  });

  test('loadBalanceTitle never uses a source task name', () {
    expect(loadBalanceTitle('household'), contains('house'));
    expect(loadBalanceTitle('household'), isNot(contains('Afwas')));
  });

  test('resolveCategoryLabel reuses an existing Dutch name', () {
    expect(
      resolveCategoryLabel('household', ['Huishouden', 'School']),
      'Huishouden',
    );
  });
}
