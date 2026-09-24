/// Pure BLE tap-to-link session protocol (no platform I/O).
///
/// Host waits for [hello], then [confirm] / [deny]. On confirm it emits an
/// offer with the same string payload used for QR. Guest receives offer and acks.
library;

enum BleTapRole { host, guest }

enum BleTapPhase {
  idle,
  advertising,
  scanning,
  awaitingConfirm,
  transferring,
  success,
  failed,
  denied,
}

class BleTapSession {
  BleTapRole? role;
  BleTapPhase phase = BleTapPhase.idle;
  String? peerName;
  String? pendingOfferPayload;
  String? receivedPayload;
  String? failureReason;

  void startHost() {
    role = BleTapRole.host;
    phase = BleTapPhase.advertising;
    peerName = null;
    pendingOfferPayload = null;
    receivedPayload = null;
    failureReason = null;
  }

  void startGuest() {
    role = BleTapRole.guest;
    phase = BleTapPhase.scanning;
    peerName = null;
    pendingOfferPayload = null;
    receivedPayload = null;
    failureReason = null;
  }

  /// Guest → host: announce presence.
  void onHello(String displayName) {
    if (role != BleTapRole.host || phase != BleTapPhase.advertising) return;
    peerName = displayName;
    phase = BleTapPhase.awaitingConfirm;
  }

  /// Host allows the guest; [qrPayload] is the family/kids QR string.
  String? confirm(String qrPayload) {
    if (role != BleTapRole.host || phase != BleTapPhase.awaitingConfirm) {
      return null;
    }
    pendingOfferPayload = qrPayload;
    phase = BleTapPhase.transferring;
    return qrPayload;
  }

  void deny() {
    if (role != BleTapRole.host || phase != BleTapPhase.awaitingConfirm) return;
    phase = BleTapPhase.denied;
  }

  /// Guest receives offer payload.
  void onOffer(String qrPayload) {
    if (role != BleTapRole.guest) return;
    if (phase != BleTapPhase.scanning && phase != BleTapPhase.transferring) {
      return;
    }
    receivedPayload = qrPayload;
    phase = BleTapPhase.success;
  }

  void onAck() {
    if (role != BleTapRole.host || phase != BleTapPhase.transferring) return;
    phase = BleTapPhase.success;
  }

  void fail(String reason) {
    phase = BleTapPhase.failed;
    failureReason = reason;
  }

  void reset() {
    role = null;
    phase = BleTapPhase.idle;
    peerName = null;
    pendingOfferPayload = null;
    receivedPayload = null;
    failureReason = null;
  }
}
