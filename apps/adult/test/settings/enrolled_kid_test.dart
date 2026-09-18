import 'package:flutter_test/flutter_test.dart';
import 'package:adult/settings/models/enrolled_kid.dart';

void main() {
  test('xpEnabled defaults to true and round-trips JSON', () {
    final kid = EnrolledKid(
      id: 'a',
      name: 'Ada',
      enrolledAt: DateTime.utc(2026, 1, 1),
    );
    expect(kid.xpEnabled, isTrue);

    final encoded = kid.toJson();
    expect(encoded['xpEnabled'], isTrue);

    final legacy = EnrolledKid.fromJson({
      'id': 'b',
      'name': 'Bea',
      'enrolledAt': '2026-01-01T00:00:00.000Z',
    });
    expect(legacy.xpEnabled, isTrue);

    final off = kid.copyWith(xpEnabled: false);
    expect(EnrolledKid.fromJson(off.toJson()).xpEnabled, isFalse);
  });
}
