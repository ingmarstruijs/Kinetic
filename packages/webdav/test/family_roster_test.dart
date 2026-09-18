import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1);
  final t1 = DateTime.utc(2026, 1, 2);
  final t2 = DateTime.utc(2026, 1, 3);

  FamilyLinkMember member(
    String id, {
    String name = 'A',
    bool kids = true,
    required DateTime updatedAt,
  }) =>
      FamilyLinkMember(
        id: id,
        displayName: name,
        kidsParticipation: kids,
        joinedAt: t0,
        updatedAt: updatedAt,
      );

  FamilyKidMember kid(
    String id, {
    String name = 'K',
    required DateTime updatedAt,
  }) =>
      FamilyKidMember(
        id: id,
        name: name,
        enrolledAt: t0,
        updatedAt: updatedAt,
      );

  test('merge unions link members and kids with per-member LWW', () {
    final a = FamilyRoster(
      linkMembers: [member('1', name: 'Alice', updatedAt: t1)],
      kids: [kid('k1', name: 'Mees', updatedAt: t1)],
      updatedAt: t1,
    );
    final b = FamilyRoster(
      linkMembers: [
        member('1', name: 'Alice Updated', kids: false, updatedAt: t2),
        member('2', name: 'Bob', updatedAt: t2),
      ],
      kids: [kid('k2', name: 'Fien', updatedAt: t2)],
      updatedAt: t2,
    );

    final merged = FamilyRoster.merge(a, b);
    expect(merged.linkMembers.map((e) => e.id).toSet(), {'1', '2'});
    expect(merged.linkMembers.firstWhere((e) => e.id == '1').displayName,
        'Alice Updated');
    expect(merged.linkMembers.firstWhere((e) => e.id == '1').kidsParticipation, false);
    expect(merged.kids.map((e) => e.id).toSet(), {'k1', 'k2'});
  });

  test('withLocalLinkMember upserts self and local kids', () {
    final roster = FamilyRoster(
      linkMembers: [member('other', name: 'Bob', updatedAt: t1)],
      kids: const [],
      updatedAt: t1,
    );
    final next = roster.withLocalLinkMember(
      self: member('me', name: 'Me', updatedAt: t2),
      localKids: [kid('k1', name: 'Mees', updatedAt: t2)],
    );
    expect(next.linkMembers.map((e) => e.id).toSet(), {'me', 'other'});
    expect(next.kids.single.id, 'k1');
  });

  test('participatingLinkMembers filters kidsParticipation', () {
    final roster = FamilyRoster(
      linkMembers: [
        member('1', kids: true, updatedAt: t1),
        member('2', kids: false, updatedAt: t1),
      ],
      kids: const [],
      updatedAt: t1,
    );
    expect(roster.participatingLinkMembers().map((e) => e.id), ['1']);
  });

  test('json roundtrip', () {
    final roster = FamilyRoster(
      linkMembers: [member('1', name: 'Alice', updatedAt: t1)],
      kids: [kid('k1', name: 'Mees', updatedAt: t1)],
      updatedAt: t1,
    );
    final copy = FamilyRoster.fromJson(roster.toJson());
    expect(copy.linkMembers.single.id, '1');
    expect(copy.kids.single.name, 'Mees');
    expect(copy.updatedAt, t1);
  });
}
