import 'package:kinetic_link_bridge/kinetic_link_bridge.dart';
import 'package:test/test.dart';

void main() {
  group('LinkWebQrPayload', () {
    test('round-trips encode/parse', () {
      final qr = LinkWebQrPayload.mint(lanHost: '192.168.1.10', port: 8787);
      final parsed = LinkWebQrPayload.tryParse(qr.encode());
      expect(parsed, isNotNull);
      expect(parsed!.sid, qr.sid);
      expect(parsed.sec, qr.sec);
      expect(parsed.wsUrl, 'ws://192.168.1.10:8787/bridge');
      expect(parsed.httpUrl, 'http://192.168.1.10:8787/');
    });

    test('rejects wrong type', () {
      expect(
        LinkWebQrPayload.tryParse('{"v":1,"type":"family","ws":"x"}'),
        isNull,
      );
    });
  });

  group('BridgeAuth', () {
    test('verifyHello accepts valid mac', () {
      const secret = 'abc';
      const sid = 'sid1';
      const nonce = 'n1';
      const ts = 1000;
      final mac = BridgeAuth.hmacHex(
        secret,
        BridgeAuth.helloMessage(sid: sid, nonce: nonce, timestampMs: ts),
      );
      expect(
        BridgeAuth.verifyHello(
          secret: secret,
          sid: sid,
          nonce: nonce,
          timestampMs: ts,
          mac: mac,
        ),
        isTrue,
      );
    });

    test('verifyHello rejects tampered mac', () {
      expect(
        BridgeAuth.verifyHello(
          secret: 'abc',
          sid: 'sid1',
          nonce: 'n1',
          timestampMs: 1000,
          mac: 'deadbeef',
        ),
        isFalse,
      );
    });
  });

  group('BridgeRpcHandler', () {
    late InMemoryTaskStore store;
    late BridgeRpcHandler host;
    late LinkWebQrPayload qr;
    final fixedNow = DateTime.utc(2026, 9, 25, 10);

    setUp(() {
      store = InMemoryTaskStore(clock: () => fixedNow);
      host = BridgeRpcHandler(store: store, clock: () => fixedNow);
      qr = LinkWebQrPayload(
        httpUrl: 'http://10.0.0.2:8787/',
        wsUrl: 'ws://10.0.0.2:8787/bridge',
        sid: 'sid-test',
        sec: 'sec-test-secret-value-32bytes!!',
        expMs: fixedNow.add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      host.armFromQr(qr);
    });

    BridgeMessage hello({String? secret}) {
      return BridgeClientHello.build(
        sid: qr.sid,
        secret: secret ?? qr.sec,
        nonce: 'nonce-1',
        timestampMs: fixedNow.millisecondsSinceEpoch,
      );
    }

    test('pair then listTasks', () async {
      final ok = await host.handle(hello());
      expect(ok.method, BridgeMethods.sessionOk);
      expect(ok.error, isNull);

      store.seed(
        BridgeTaskDto(
          id: 'a',
          title: 'Tidy',
          isCompleted: false,
          updatedAt: fixedNow,
        ),
      );
      final list = await host.handle(
        const BridgeMessage(method: BridgeMethods.tasksList, id: '1'),
      );
      expect(list.error, isNull);
      final tasks = list.params['tasks'] as List<dynamic>;
      expect(tasks, hasLength(1));
      expect((tasks.first as Map)['title'], 'Tidy');
    });

    test('rejects bad secret', () async {
      final bad = await host.handle(hello(secret: 'wrong-secret'));
      expect(bad.error?['code'], 'bad_mac');
    });

    test('complete task', () async {
      await host.handle(hello());
      final created = await host.handle(
        const BridgeMessage(
          method: BridgeMethods.tasksCreate,
          id: 'c',
          params: {'title': 'Walk dog'},
        ),
      );
      final id =
          (created.params['task'] as Map<String, dynamic>)['id'] as String;
      final done = await host.handle(
        BridgeMessage(
          method: BridgeMethods.tasksComplete,
          id: 'd',
          params: {'id': id},
        ),
      );
      expect((done.params['task'] as Map)['isCompleted'], isTrue);
    });

    test('unauthorized before hello', () async {
      final list = await host.handle(
        const BridgeMessage(method: BridgeMethods.tasksList, id: '1'),
      );
      expect(list.error?['code'], 'unauthorized');
    });

    test('TTL expiry rejects hello', () async {
      final expired = LinkWebQrPayload(
        httpUrl: qr.httpUrl,
        wsUrl: qr.wsUrl,
        sid: 'sid-exp',
        sec: qr.sec,
        expMs: fixedNow
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch,
      );
      host.armFromQr(expired);
      final reply = await host.handle(
        BridgeClientHello.build(
          sid: expired.sid,
          secret: expired.sec,
          nonce: 'n',
          timestampMs: fixedNow.millisecondsSinceEpoch,
        ),
      );
      expect(reply.error?['code'], 'expired');
    });

    test('idle TTL kills session', () async {
      var t = fixedNow;
      store = InMemoryTaskStore(clock: () => t);
      host = BridgeRpcHandler(store: store, clock: () => t);
      host.armFromQr(qr);
      await host.handle(hello());
      t = fixedNow.add(const Duration(minutes: 25));
      final list = await host.handle(
        const BridgeMessage(method: BridgeMethods.tasksList, id: '1'),
      );
      expect(list.error?['code'], 'unauthorized');
    });

    test('message encode round-trip', () {
      final msg = BridgeMessage(
        method: BridgeMethods.tasksCreate,
        id: 'x',
        params: {'title': 'Hi'},
      );
      final parsed = BridgeMessage.tryParse(msg.encode());
      expect(parsed!.method, BridgeMethods.tasksCreate);
      expect(parsed.params['title'], 'Hi');
    });
  });
}
