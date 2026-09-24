import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_tap_session.dart';

/// Kinetic BLE service / characteristic UUIDs for tap-to-link.
final Guid kKineticBleServiceUuid =
    Guid('A1C00000-0000-1000-8000-00805F9B34FB');
final Guid kKineticBleCharUuid = Guid('A1C00001-0000-1000-8000-00805F9B34FB');

/// Host/guest BLE orchestration around [BleTapSession].
///
/// Guest scans and connects with [flutter_blue_plus]. Host waits for a guest
/// connection on the Kinetic service (guest-driven). Full GATT peripheral
/// advertising is best-effort — if BLE is off or unsupported, [isAvailable]
/// is false and UI should fall back to QR.
class BleTapLinkController extends ChangeNotifier {
  final BleTapSession session = BleTapSession();
  final String displayName;

  StreamSubscription<List<ScanResult>>? _scanSub;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _char;
  Timer? _ttl;
  bool _busy = false;

  BleTapLinkController({required this.displayName});

  BleTapPhase get phase => session.phase;
  String? get peerName => session.peerName;
  String? get receivedPayload => session.receivedPayload;
  String? get failureReason => session.failureReason;

  Future<bool> get isAvailable async {
    try {
      final supported = await FlutterBluePlus.isSupported;
      if (!supported) return false;
      final adapter = await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 2));
      return adapter == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  Future<void> startGuest({Duration ttl = const Duration(minutes: 2)}) async {
    await stop();
    session.startGuest();
    _armTtl(ttl);
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(
        withServices: [kKineticBleServiceUuid],
        timeout: ttl,
      );
      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        if (session.phase != BleTapPhase.scanning || _busy) return;
        if (results.isEmpty) return;
        // Prefer strongest RSSI (closest phone).
        results.sort((a, b) => b.rssi.compareTo(a.rssi));
        final best = results.first;
        if (best.rssi < -70) return; // not close enough
        _busy = true;
        try {
          await FlutterBluePlus.stopScan();
          await _connectAsGuest(best.device);
        } catch (e) {
          session.fail('$e');
          notifyListeners();
        } finally {
          _busy = false;
        }
      });
    } catch (e) {
      session.fail('$e');
      notifyListeners();
    }
  }

  Future<void> _connectAsGuest(BluetoothDevice device) async {
    _device = device;
    session.phase = BleTapPhase.transferring;
    notifyListeners();
    await device.connect(timeout: const Duration(seconds: 15));
    final services = await device.discoverServices();
    final service = services.cast<BluetoothService?>().firstWhere(
      (s) => s!.uuid == kKineticBleServiceUuid,
      orElse: () => null,
    );
    if (service == null) {
      session.fail('service');
      notifyListeners();
      return;
    }
    final char = service.characteristics.cast<BluetoothCharacteristic?>().firstWhere(
      (c) => c!.uuid == kKineticBleCharUuid,
      orElse: () => null,
    );
    if (char == null) {
      session.fail('characteristic');
      notifyListeners();
      return;
    }
    _char = char;
    await char.setNotifyValue(true);
    char.onValueReceived.listen((bytes) {
      _onBytes(bytes);
    });
    await _write({'t': 'hello', 'n': displayName});
  }

  /// Host mode: listen for connections by scanning is inverted —
  /// for Phase 1 the "host" prepares an offer payload; when a guest connects
  /// via the platform GATT server path this is stubbed to awaitingConfirm
  /// through [simulateGuestHello] in tests, and [confirmGuest] sends offer
  /// once a writable path exists.
  ///
  /// Production host uses [startHostAwaitingGuest] which advertises via
  /// FlutterBluePlus when the platform allows, else fails → QR fallback.
  Future<void> startHostAwaitingGuest({
    required String Function() payloadProvider,
    Duration ttl = const Duration(minutes: 2),
  }) async {
    await stop();
    session.startHost();
    _payloadProvider = payloadProvider;
    _armTtl(ttl);
    notifyListeners();

    try {
      // Prefer guest-driven: host starts a short advertisement if supported.
      // flutter_blue_plus does not expose a portable peripheral API on all
      // platforms — mark unavailable so UI falls back to QR when needed.
      final available = await isAvailable;
      if (!available) {
        session.fail('unavailable');
        notifyListeners();
        return;
      }
      // Keep advertising phase; guest hello arrives via [_onBytes] when a
      // platform channel injects it, or via [injectHelloForTesting].
      // Real GATT peripheral will be wired in a follow-up; for now we still
      // expose confirm/deny UI when hello is injected from a connected guest
      // path. Until peripheral advertising ships, [startHostAwaitingGuest]
      // surfaces [failureReason] = peripheral after a brief wait if no hello.
      _hostWatchdog = Timer(const Duration(seconds: 45), () {
        if (session.phase == BleTapPhase.advertising) {
          session.fail('peripheral');
          notifyListeners();
        }
      });
    } catch (e) {
      session.fail('$e');
      notifyListeners();
    }
  }

  String Function()? _payloadProvider;
  Timer? _hostWatchdog;

  void markUnavailable() {
    session.fail('unavailable');
    notifyListeners();
  }

  /// Test / future peripheral hook: guest said hello.
  void injectHelloForTesting(String name) {
    session.onHello(name);
    notifyListeners();
  }

  Future<void> confirmGuest() async {
    final provider = _payloadProvider;
    if (provider == null) return;
    final payload = session.confirm(provider());
    if (payload == null) return;
    notifyListeners();
    await _write({'t': 'offer', 'p': payload});
  }

  Future<void> denyGuest() async {
    session.deny();
    notifyListeners();
    await _write({'t': 'deny'});
    await stop();
  }

  void _onBytes(List<int> bytes) {
    try {
      final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final t = map['t'] as String?;
      switch (t) {
        case 'hello':
          session.onHello(map['n'] as String? ?? 'Family member');
          notifyListeners();
        case 'offer':
          final p = map['p'] as String?;
          if (p != null) {
            session.onOffer(p);
            unawaited(_write({'t': 'ack'}));
            notifyListeners();
          }
        case 'ack':
          session.onAck();
          notifyListeners();
        case 'deny':
          session.phase = BleTapPhase.denied;
          notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('BLE tap decode: $e');
    }
  }

  Future<void> _write(Map<String, dynamic> map) async {
    final char = _char;
    if (char == null) return;
    final data = utf8.encode(jsonEncode(map));
    await char.write(data, withoutResponse: false);
  }

  void _armTtl(Duration ttl) {
    _ttl?.cancel();
    _ttl = Timer(ttl, () {
      if (session.phase != BleTapPhase.success &&
          session.phase != BleTapPhase.denied) {
        session.fail('timeout');
        notifyListeners();
        unawaited(stop());
      }
    });
  }

  Future<void> stop() async {
    _ttl?.cancel();
    _ttl = null;
    _hostWatchdog?.cancel();
    _hostWatchdog = null;
    await _scanSub?.cancel();
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    try {
      await _device?.disconnect();
    } catch (_) {}
    _device = null;
    _char = null;
    _busy = false;
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
