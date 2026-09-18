import 'dart:typed_data';

import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../sync/webdav_config_repository.dart';

const kVaultReadyKey = 'kinetic_vault_ready';

/// Session for the personal vault: derived AES key in secure storage.
///
/// The 12-word phrase is not stored. Paper (or another copy the user made
/// during onboarding) is the only way to recover the vault. Settings can
/// still *verify* a typed phrase against the derived key.
class VaultRepository {
  VaultRepository(this._store, this._configRepo);

  final SecureKeyValueStore _store;
  final WebDavConfigRepository _configRepo;

  Future<bool> isReady() async {
    final flag = await _store.read(key: kVaultReadyKey);
    if (flag != '1') return false;
    // Drop leftover entropy from older builds that could re-show the phrase.
    await _configRepo.clearPersonalEntropy();
    return true;
  }

  /// True when a 0.2.x (or `.kbak2`) personal key exists but no vault phrase.
  Future<bool> needsMigration() async {
    if (await isReady()) return false;
    return await loadKey() != null;
  }

  Future<void> markReady() async {
    await _store.write(key: kVaultReadyKey, value: '1');
  }

  Future<Uint8List> unlockWithKey(Uint8List key) async {
    await _configRepo.savePersonalKey(key);
    await _configRepo.clearPersonalEntropy();
    await markReady();
    return key;
  }

  Future<Uint8List> unlockWithPhrase(String phrase) async {
    final words = KineticVault.parseMnemonic(phrase);
    final joined = words.join(' ');
    final key = await KineticVault.deriveAesKey(joined);
    return unlockWithKey(key);
  }

  Future<Uint8List?> loadKey() => _configRepo.loadPersonalKeyBytes();

  Future<Uint8List> requireKey() async {
    final key = await loadKey();
    if (key == null) {
      throw StateError('Vault is not unlocked');
    }
    return key;
  }

  /// Always null after unlock: personal entropy is not persisted.
  /// Leftover entropy from older builds is cleared in [isReady].
  Future<List<String>?> loadPersonalMnemonic() async {
    final entropy = await _configRepo.loadPersonalEntropy();
    if (entropy == null) return null;
    return KineticVault.mnemonicFromEntropy(entropy);
  }

  /// Constant-time compare of [phrase] against the stored derived key.
  Future<bool> verifyPhrase(String phrase) async {
    final stored = await loadKey();
    if (stored == null) return false;
    try {
      final derived = await KineticVault.deriveAesKey(phrase);
      return KineticVault.equalKeys(stored, derived);
    } on FormatException {
      return false;
    }
  }
}
