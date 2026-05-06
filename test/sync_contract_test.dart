import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:okaka/okaka.dart';

import 'vector_test_support.dart';

void main() {
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
    final store = OkakaMemorySyncTokenStore(query['since'] as String);
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final batch = await client.sync.pollOnce(
      accessToken: 'token-1',
      tokenStore: store,
      timeout: Duration(
        milliseconds: int.parse(query['timeout'] as String),
      ),
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.queryParameters, query);
    expect(batch.nextBatch, 's1');
    expect(
        batch.rooms.single.timeline.events.single.textMessage?.body, 'hello');
    expect(await store.read(), 's1');
  });

  test('sync parsers reject malformed payloads', () {
    expect(
      () => OkakaSyncBatch.fromJson({'next_batch': '', 'rooms': []}),
      throwsA(isA<OkakaResponseFormatException>()),
    );
    expect(
      () => OkakaTimelinePage.fromJson({'events': [], 'start': ''}),
      throwsA(isA<OkakaResponseFormatException>()),
    );
  });
}

OkakaClient _client(Future<http.Response> Function(http.Request) handler) {
  return OkakaClient(
    serverBaseUri: Uri.parse('https://example.test'),
    httpClient: MockClient(handler),
  );
}
