import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('sendEncryptedToDevice follows SPEC-052 vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-to-device-send-basic.json',
    );
    final requestBody = objectFrom(vector.request, 'body');
    final messages = objectFrom(requestBody, 'messages');
    final bobDevices = objectFrom(messages, '@bob:example.test');

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(jsonEncode(vector.bodyContains), 200);
      }),
    );

    await client.messaging.sendEncryptedToDevice(
      accessToken: vector.request['access_token'] as String,
      clientTransactionId: 'txn-to-device-1',
      messages: {
        '@bob:example.test': {
          'BOB1': HouraEncryptedPayload.fromJson(
            objectFrom(bobDevices, 'BOB1'),
          ),
          'BOB2': HouraEncryptedPayload.fromJson(
            objectFrom(bobDevices, 'BOB2'),
          ),
        },
      },
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-alice-device1');
    expect(jsonDecode(observed.body), requestBody);
  });

  test('encrypted room setup and send follow SPEC-052 vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-encrypted-room-send-receive-basic.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;
    final setEncryption = (steps[0] as Map).cast<String, Object?>();
    final sendEncrypted = (steps[1] as Map).cast<String, Object?>();
    final syncEncrypted = (steps[2] as Map).cast<String, Object?>();

    final observed = <http.Request>[];
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed.add(request);
        if (request.url.path == setEncryption['path']) {
          return http.Response(
            jsonEncode(objectFrom(setEncryption, 'expected_body_contains')),
            setEncryption['expected_status'] as int,
          );
        }
        return http.Response(
          jsonEncode(objectFrom(sendEncrypted, 'expected_body_contains')),
          sendEncrypted['expected_status'] as int,
        );
      }),
    );

    final encryptionEventId = await client.messaging.setRoomEncryption(
      accessToken: setEncryption['access_token'] as String,
      roomId: event['room_id'] as String,
      rotationPeriodMs:
          objectFrom(setEncryption, 'body')['rotation_period_ms'] as int,
      rotationPeriodMsgs:
          objectFrom(setEncryption, 'body')['rotation_period_msgs'] as int,
    );
    final encryptedEventId = await client.messaging.sendEncryptedRoomEvent(
      accessToken: sendEncrypted['access_token'] as String,
      roomId: event['room_id'] as String,
      clientTransactionId: 'txn-encrypted-1',
      payload: HouraEncryptedPayload.fromJson(
        objectFrom(sendEncrypted, 'body'),
      ),
    );

    expect(observed[0].method, setEncryption['method']);
    expect(observed[0].url.path, setEncryption['path']);
    expect(jsonDecode(observed[0].body), objectFrom(setEncryption, 'body'));
    expect(encryptionEventId, r'$encryption:example.test');

    expect(observed[1].method, sendEncrypted['method']);
    expect(observed[1].url.path, sendEncrypted['path']);
    expect(jsonDecode(observed[1].body), objectFrom(sendEncrypted, 'body'));
    expect(encryptedEventId, r'$encrypted1:example.test');

    final timelineEvent = HouraEvent.fromJson({
      ...objectFrom(syncEncrypted, 'expected_timeline_event'),
      'room_id': event['room_id'],
    });
    final payload = timelineEvent.encryptedPayload!;
    expect(payload.algorithm, 'm.megolm.v1.aes-sha2');
    expect(payload.senderKey, 'alice-curve25519-device1');
    expect(payload.megolmCiphertext, 'megolm-ciphertext');
    expect(payload.sessionId, 'megolm-session-1');
    expect(payload.deviceId, 'DEVICE1');
  });

  test('sendTextMessage follows SPEC-008 vector', () async {
    final vector = readVector('test-vectors/messaging/send-text-basic.json');
    final requestBody = objectFrom(vector.request, 'body');

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(jsonEncode(vector.bodyContains), 200);
      }),
    );

    final eventId = await client.messaging.sendTextMessage(
      accessToken: vector.request['access_token'] as String,
      roomId: '!room:example.test',
      clientTransactionId: requestBody['client_transaction_id'] as String,
      body: requestBody['body'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-1');
    expect(jsonDecode(observed.body), requestBody);
    expect(eventId, vector.bodyContains['event_id']);
  });

  test('send response parser rejects malformed responses', () {
    expect(
      () => HouraSendMessageResponse.fromJson({'event_id': ''}),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('sendTextMessage rejects empty client transaction IDs', () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        fail('empty client transaction IDs must not be sent');
      }),
    );

    await expectLater(
      client.messaging.sendTextMessage(
        accessToken: 'token-1',
        roomId: '!room:example.test',
        clientTransactionId: '',
        body: 'hello',
      ),
      throwsA(isA<HouraTransportException>()),
    );
  });

  test('encrypted Matrix request descriptors reject invalid inputs', () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        fail('invalid encrypted descriptors must not be sent');
      }),
    );
    final payload = HouraEncryptedPayload(
      algorithm: 'm.megolm.v1.aes-sha2',
      senderKey: 'alice-curve25519-device1',
      megolmCiphertext: 'ciphertext',
      sessionId: 'megolm-session-1',
      deviceId: 'DEVICE1',
      raw: const {},
    );

    await expectLater(
      client.messaging.sendEncryptedToDevice(
        accessToken: 'token-alice-device1',
        clientTransactionId: '',
        messages: {
          '@bob:example.test': {'BOB1': payload},
        },
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.messaging.sendEncryptedToDevice(
        accessToken: 'token-alice-device1',
        clientTransactionId: 'txn-to-device-1',
        messages: {
          '@bob:example.test': {'': payload},
        },
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.messaging.setRoomEncryption(
        accessToken: 'token-alice-device1',
        roomId: '',
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.messaging.setRoomEncryption(
        accessToken: 'token-alice-device1',
        roomId: '!encrypted:example.test',
        rotationPeriodMs: -1,
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.messaging.sendEncryptedRoomEvent(
        accessToken: 'token-alice-device1',
        roomId: '',
        clientTransactionId: 'txn-encrypted-1',
        payload: payload,
      ),
      throwsA(isA<HouraTransportException>()),
    );
  });

  test('encrypted payload parsers reject malformed envelopes', () {
    final vector = readVector(
      'test-vectors/messaging/matrix-encrypted-room-malformed-payload.json',
    );

    expect(
      () => HouraEncryptedPayload.fromJson(objectFrom(vector.request, 'body')),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraEncryptedPayload.fromJson({'algorithm': 'm.unknown'}),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('encrypted payload request bodies derive JSON from typed fields', () {
    final payload = HouraEncryptedPayload(
      algorithm: 'm.megolm.v1.aes-sha2',
      senderKey: 'alice-curve25519-device1',
      megolmCiphertext: 'fresh-ciphertext',
      sessionId: 'megolm-session-1',
      deviceId: 'DEVICE1',
      raw: const {'ciphertext': 'stale-ciphertext'},
    );

    expect(payload.toJson()['ciphertext'], 'fresh-ciphertext');
  });
}
