import 'package:flutter_test/flutter_test.dart';
import 'package:link/sync/ble_tap_session.dart';

void main() {
  group('BleTapSession', () {
    test('host confirm emits offer and guest receives payload', () {
      final host = BleTapSession()..startHost();
      final guest = BleTapSession()..startGuest();

      host.onHello('Bob');
      expect(host.phase, BleTapPhase.awaitingConfirm);
      expect(host.peerName, 'Bob');

      final offer = host.confirm('qr-payload-xyz');
      expect(offer, 'qr-payload-xyz');
      expect(host.phase, BleTapPhase.transferring);

      guest.onOffer(offer!);
      expect(guest.phase, BleTapPhase.success);
      expect(guest.receivedPayload, 'qr-payload-xyz');

      host.onAck();
      expect(host.phase, BleTapPhase.success);
    });

    test('host deny ends session', () {
      final host = BleTapSession()..startHost();
      host.onHello('Bob');
      host.deny();
      expect(host.phase, BleTapPhase.denied);
    });

    test('fail records reason', () {
      final s = BleTapSession()..startGuest();
      s.fail('timeout');
      expect(s.phase, BleTapPhase.failed);
      expect(s.failureReason, 'timeout');
    });
  });
}
