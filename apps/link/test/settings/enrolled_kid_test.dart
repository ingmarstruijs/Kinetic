import 'package:flutter_test/flutter_test.dart';
import 'package:link/settings/models/enrolled_kid.dart';

void main() {
  test('xpEnabled defaults to true and round-trips JSON', () {
    final kid = EnrolledKid(
      id: 'a',
      name: 'Ada',
      enrolledAt: DateTime.utc(2026, 1, 1),
    );
    expect(kid.xpEnabled, isTrue);
    expect(kid.isActive, isTrue);

    final encoded = kid.toJson();
    expect(encoded['xpEnabled'], isTrue);
    expect(encoded['isActive'], isTrue);

    final legacy = EnrolledKid.fromJson({
      'id': 'b',
      'name': 'Bea',
      'enrolledAt': '2026-01-01T00:00:00.000Z',
    });
    expect(legacy.xpEnabled, isTrue);
    expect(legacy.isActive, isTrue);

    final off = kid.copyWith(xpEnabled: false, isActive: false);
    expect(EnrolledKid.fromJson(off.toJson()).xpEnabled, isFalse);
    expect(EnrolledKid.fromJson(off.toJson()).isActive, isFalse);
  });

  test('stale draft detection', () {
    final old = EnrolledKid(
      id: 'd',
      name: 'Draft',
      enrolledAt: DateTime.utc(2026, 1, 1),
      isActive: false,
    );
    expect(old.isStaleDraft(DateTime.utc(2026, 1, 9)), isTrue);
    expect(old.isStaleDraft(DateTime.utc(2026, 1, 5)), isFalse);
    expect(
      old.copyWith(isActive: true).isStaleDraft(DateTime.utc(2026, 2, 1)),
      isFalse,
    );
  });
}
