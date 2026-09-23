import 'dart:convert';
import 'dart:typed_data';

import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:uuid/uuid.dart';

import '../settings/models/enrolled_kid.dart';

/// Secure-storage keys for WebDAV configuration.
const _kServerUrl = 'kinetic_webdav_server_url';
const _kUsername = 'kinetic_webdav_username';
const _kPassword = 'kinetic_webdav_password';
const _kPersonalKey = 'kinetic_webdav_personal_key';
const _kPersonalEntropy = 'kinetic_webdav_personal_entropy';
const _kFamilyKey = 'kinetic_webdav_family_key';
const _kFamilyEntropy = 'kinetic_webdav_family_entropy';
const _kLinkId = 'kinetic_webdav_link_id';
const _kEnrolledKids = 'kinetic_enrolled_kids';
const _kHasOtherLinkMembers = 'kinetic_has_other_link_members';
const _kKidsParticipation = 'kinetic_kids_participation';
const _kCachedRoster = 'kinetic_family_roster';

/// Persists and loads [SyncConfig] from [SecureKeyValueStore].
///
/// Keys are stored individually so the password can be updated independently
/// of the encryption keys (e.g. after a WebDAV password change + re-derive).
class WebDavConfigRepository {
  final SecureKeyValueStore _store;

  WebDavConfigRepository(this._store);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns the stored [SyncConfig], or null if the user has not yet
  /// configured WebDAV.
  Future<SyncConfig?> load() async {
    final serverUrl = await _store.read(key: _kServerUrl);
    final username = await _store.read(key: _kUsername);
    final password = await _store.read(key: _kPassword);
    final personalKeyBase64 = await _store.read(key: _kPersonalKey);

    if (serverUrl == null ||
        username == null ||
        password == null ||
        personalKeyBase64 == null) {
      return null;
    }

    final personalKeyBytes = Uint8List.fromList(
      base64.decode(personalKeyBase64),
    );

    final familyKeyBase64 = await _store.read(key: _kFamilyKey);
    final familyKeyBytes = familyKeyBase64 != null
        ? Uint8List.fromList(base64.decode(familyKeyBase64))
        : null;

    // linkId may be absent for existing installs — treated as null here;
    // the setup screen generates and persists one on the next save.
    final linkId = await _store.read(key: _kLinkId) ?? '';

    try {
      return SyncConfig(
        serverUrl: WebDavUrl.coerceHttps(serverUrl),
        username: username,
        password: password,
        linkId: linkId,
        personalKeyBytes: personalKeyBytes,
        familyKeyBytes: familyKeyBytes,
      );
    } on FormatException {
      // Legacy non-HTTPS configs are rejected; user must reconfigure.
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Persists a full [SyncConfig] to secure storage.
  Future<void> save(SyncConfig config) async {
    await _store.write(key: _kServerUrl, value: config.serverUrl);
    await _store.write(key: _kUsername, value: config.username);
    await _store.write(key: _kPassword, value: config.password);
    await _store.write(key: _kLinkId, value: config.linkId);
    await _store.write(
      key: _kPersonalKey,
      value: base64.encode(config.personalKeyBytes),
    );
    if (config.familyKeyBytes != null) {
      await _store.write(
        key: _kFamilyKey,
        value: base64.encode(config.familyKeyBytes!),
      );
    }
  }

  /// Updates only the password in secure storage.
  ///
  /// The family key is intentionally left unchanged — it is independent of
  /// the WebDAV password and is shared explicitly between Link family members.
  Future<void> updatePassword(String newPassword) async {
    await _store.write(key: _kPassword, value: newPassword);
  }

  /// Stores the family AES key and optional 16-byte BIP-39 entropy.
  Future<void> saveFamilyKey(
    Uint8List familyKey, {
    Uint8List? entropy,
  }) async {
    await _store.write(key: _kFamilyKey, value: base64.encode(familyKey));
    if (entropy != null) {
      await _store.write(key: _kFamilyEntropy, value: base64.encode(entropy));
    }
  }

  Future<Uint8List?> loadFamilyEntropy() async {
    final value = await _store.read(key: _kFamilyEntropy);
    if (value == null) return null;
    return Uint8List.fromList(base64.decode(value));
  }

  /// Returns the stored family key, or null if this device has none yet.
  Future<Uint8List?> loadFamilyKey() async {
    final existing = await _store.read(key: _kFamilyKey);
    if (existing == null) return null;
    return Uint8List.fromList(base64.decode(existing));
  }

  /// Stores a new personal key without touching any other config fields.
  ///
  /// Use this when importing a personal key backup, independent of WebDAV.
  Future<void> savePersonalKey(Uint8List personalKey) async {
    await _store.write(key: _kPersonalKey, value: base64.encode(personalKey));
  }

  /// 16-byte BIP-39 entropy. Kept for tests and leftover cleanup; the
  /// personal vault no longer persists this (the phrase cannot be re-shown).
  Future<void> savePersonalEntropy(Uint8List entropy) async {
    await _store.write(key: _kPersonalEntropy, value: base64.encode(entropy));
  }

  Future<Uint8List?> loadPersonalEntropy() async {
    final value = await _store.read(key: _kPersonalEntropy);
    if (value == null) return null;
    return Uint8List.fromList(base64.decode(value));
  }

  Future<void> clearPersonalEntropy() async {
    await _store.delete(key: _kPersonalEntropy);
  }

  /// Returns just the personal key bytes from secure storage, or null if not yet configured.
  Future<Uint8List?> loadPersonalKeyBytes() async {
    final base64str = await _store.read(key: _kPersonalKey);
    if (base64str == null) return null;
    return Uint8List.fromList(base64.decode(base64str));
  }

  /// Returns the stored personal key, or throws if the vault is not unlocked.
  Future<Uint8List> requirePersonalKey() async {
    final existing = await loadPersonalKeyBytes();
    if (existing == null) {
      throw StateError('No vault on this device');
    }
    return existing;
  }

  /// Removes the family key without touching any other config fields.
  ///
  /// Call this when leaving the family pairing.
  Future<void> clearFamilyKey() async {
    await _store.delete(key: _kFamilyKey);
    await _store.delete(key: _kFamilyEntropy);
    await _store.delete(key: _kHasOtherLinkMembers);
    await _store.delete(key: _kCachedRoster);
  }

  /// Marks whether another Link member has been linked (offline hint).
  /// Prefer roster [hasOtherLinkMembers] for UI when a roster is available.
  Future<void> setHasOtherLinkMembers(bool linked) async {
    await _store.write(key: _kHasOtherLinkMembers, value: linked ? '1' : '0');
  }

  /// True when another Link member is linked: roster first, then local flag.
  Future<bool> hasOtherLinkMembers() async {
    final roster = await loadCachedRoster();
    final myId = await _store.read(key: _kLinkId) ?? '';
    if (roster != null && roster.otherLinkMembers(myId).isNotEmpty) {
      return true;
    }
    final val = await _store.read(key: _kHasOtherLinkMembers);
    return val == '1';
  }

  // ---------------------------------------------------------------------------
  // Kids participation (local + mirrored on roster)
  // ---------------------------------------------------------------------------

  /// Whether this link device participates in kids panels / verification.
  Future<bool> loadKidsParticipation() async {
    final val = await _store.read(key: _kKidsParticipation);
    if (val == null) return true;
    return val == '1';
  }

  Future<void> saveKidsParticipation(bool enabled) async {
    await _store.write(key: _kKidsParticipation, value: enabled ? '1' : '0');
  }

  // ---------------------------------------------------------------------------
  // Cached family roster
  // ---------------------------------------------------------------------------

  Future<FamilyRoster?> loadCachedRoster() async {
    final json = await _store.read(key: _kCachedRoster);
    if (json == null) return null;
    try {
      return FamilyRoster.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedRoster(FamilyRoster roster) async {
    await _store.write(
      key: _kCachedRoster,
      value: jsonEncode(roster.toJson()),
    );
    final myId = await _store.read(key: _kLinkId) ?? '';
    if (roster.otherLinkMembers(myId).isNotEmpty) {
      await setHasOtherLinkMembers(true);
    }
  }

  // ---------------------------------------------------------------------------
  // Enrolled Kids
  // ---------------------------------------------------------------------------

  /// Returns the list of kids enrolled on this link device / roster cache.
  Future<List<EnrolledKid>> loadEnrolledKids() async {
    final json = await _store.read(key: _kEnrolledKids);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => EnrolledKid.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Adds a new kid with [name] to the enrolled list and returns the
  /// [EnrolledKid] that was created (including its generated ID).
  Future<EnrolledKid> addEnrolledKid(String name) async {
    final now = DateTime.now().toUtc();
    final kid = EnrolledKid(
      id: const Uuid().v4(),
      name: name,
      enrolledAt: now,
      updatedAt: now,
    );
    final kids = await loadEnrolledKids();
    kids.add(kid);
    await _writeEnrolledKids(kids);
    return kid;
  }

  /// Updates an enrolled kid (e.g. name or XP preference).
  Future<void> updateEnrolledKid(EnrolledKid kid) async {
    final kids = await loadEnrolledKids();
    final index = kids.indexWhere((k) => k.id == kid.id);
    if (index < 0) return;
    kids[index] = kid.copyWith(updatedAt: DateTime.now().toUtc());
    await _writeEnrolledKids(kids);
  }

  /// Removes a kid by ID from the enrolled list.
  Future<void> removeEnrolledKid(String kidId) async {
    final kids = await loadEnrolledKids();
    kids.removeWhere((k) => k.id == kidId);
    await _writeEnrolledKids(kids);
  }

  /// Replaces the entire enrolled-kids list (used during backup restore).
  Future<void> restoreEnrolledKids(List<EnrolledKid> kids) =>
      _writeEnrolledKids(kids);

  Future<void> _writeEnrolledKids(List<EnrolledKid> kids) async {
    final json = jsonEncode(kids.map((k) => k.toJson()).toList());
    await _store.write(key: _kEnrolledKids, value: json);
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Clears all WebDAV configuration from secure storage.
  Future<void> clear() async {
    await _store.delete(key: _kServerUrl);
    await _store.delete(key: _kUsername);
    await _store.delete(key: _kPassword);
    await _store.delete(key: _kLinkId);
    await _store.delete(key: _kPersonalKey);
    await _store.delete(key: _kPersonalEntropy);
    await _store.delete(key: _kFamilyKey);
    await _store.delete(key: _kFamilyEntropy);
    await _store.delete(key: _kHasOtherLinkMembers);
    await _store.delete(key: _kKidsParticipation);
    await _store.delete(key: _kCachedRoster);
  }
}
