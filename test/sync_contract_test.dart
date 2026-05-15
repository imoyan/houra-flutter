import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('matrixSync parses SPEC-052 to-device delivery vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-to-device-sync-receive-basic.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;
    final syncStep = (steps[1] as Map).cast<String, Object?>();
    final responseBody = objectFrom(syncStep, 'expected_body_contains');

    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(
        jsonEncode(responseBody),
        syncStep['expected_status'] as int,
      );
    });

    final batch = await client.sync.matrixSync(
      accessToken: syncStep['access_token'] as String,
    );

    expect(observed.method, syncStep['method']);
    expect(observed.url.path, syncStep['path']);
    expect(observed.headers['authorization'], 'Bearer token-bob-device1');
    expect(batch.nextBatch, responseBody['next_batch']);
    expect(batch.toDeviceEvents, hasLength(1));
    final eventEnvelope = batch.toDeviceEvents.single;
    expect(eventEnvelope.sender, '@alice:example.test');
    expect(eventEnvelope.type, 'm.room.encrypted');
    final payload = eventEnvelope.encryptedPayload!;
    expect(payload.algorithm, 'm.olm.v1.curve25519-aes-sha2');
    expect(payload.senderKey, 'alice-curve25519-device1');
    expect(
      payload.olmCiphertext!['bob-curve25519-bob1']!.body,
      'olm-prekey-ciphertext',
    );
  });

  test('Matrix sync parsers follow SPEC-093 extension vector', () {
    final vector = readVector(
      'test-vectors/sync/matrix-sync-breadth-extensions.json',
    );
    expect(vector.raw['contract'], 'SPEC-093');
    final event = objectFrom(vector.raw, 'event');
    final descriptors = event['request_descriptors'] as List<Object?>;
    final firstDescriptor = HouraMatrixSyncRequestDescriptor.fromJson(
      (descriptors.first as Map).cast<String, Object?>(),
    );
    expect(firstDescriptor.responseParser, 'sync_extensions');
    expect(firstDescriptor.adoptedRuntimeBehavior, isFalse);
    expect(firstDescriptor.queryParams['use_state_after'], isTrue);

    final responses = objectFrom(event, 'sample_responses');
    final batch = HouraMatrixSyncBatch.fromJson(
      objectFrom(responses, 'sync_extensions'),
    );
    expect(batch.nextBatch, 's2');
    expect(batch.presenceEvents.single.sender, '@alice:example.test');
    expect(batch.toDeviceEvents.single.type, 'm.room.encrypted');
    expect(batch.deviceLists.changed, ['@alice:example.test']);
    expect(batch.deviceLists.left, ['@carol:example.test']);
    expect(batch.deviceOneTimeKeysCount['signed_curve25519'], 3);
    expect(batch.rooms.invite, contains('!invite:example.test'));
    expect(batch.rooms.leave, contains('!left:example.test'));
    expect(batch.rooms.knock, contains('!knock:example.test'));
    expect(
      const HouraMatrixSyncBatch(
        nextBatch: 's0',
        toDeviceEvents: [],
      ).deviceLists.changed,
      isEmpty,
    );
  });

  test('listRooms follows SPEC-009 vector', () async {
    final vector = readVector('test-vectors/sync/room-list-basic.json');
    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final rooms = await client.sync.listRooms(accessToken: 'token-1');

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(rooms.rooms.single.roomId, '!room:example.test');
  });

  test('getTimeline follows SPEC-010 vector', () async {
    final vector = readVector('test-vectors/sync/timeline-basic.json');
    final query = objectFrom(vector.request, 'query');
    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final page = await client.sync.getTimeline(
      accessToken: 'token-1',
      roomId: '!room:example.test',
      from: query['from'] as String,
      limit: int.parse(query['limit'] as String),
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.queryParameters, query);
    expect(page.start, vector.bodyContains['start']);
    expect(page.events.single.textMessage?.body, 'hello');
  });

  test('sync and token store follow SPEC-011 vector', () async {
    final vector = readVector('test-vectors/sync/basic-sync.json');
    final query = objectFrom(vector.request, 'query');
    late http.Request observed;
    final store = HouraMemorySyncTokenStore(query['since'] as String);
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final batch = await client.sync.pollOnce(
      accessToken: 'token-1',
      tokenStore: store,
      timeout: Duration(milliseconds: int.parse(query['timeout'] as String)),
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.queryParameters, query);
    expect(batch.nextBatch, 's1');
    expect(
      batch.rooms.single.timeline.events.single.textMessage?.body,
      'hello',
    );
    expect(await store.read(), 's1');
  });

  test('sync parsers reject malformed payloads', () {
    expect(
      () => HouraSyncBatch.fromJson({'next_batch': '', 'rooms': []}),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraTimelinePage.fromJson({'events': [], 'start': ''}),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixSyncBatch.fromJson({
        'next_batch': 's1',
        'to_device': {'events': 'bad'},
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixDeviceLists.fromJson({
        'changed': ['alice'],
        'left': [],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}

HouraClient _client(Future<http.Response> Function(http.Request) handler) {
  return HouraClient(
    serverBaseUri: Uri.parse('https://example.test'),
    httpClient: MockClient(handler),
  );
}
