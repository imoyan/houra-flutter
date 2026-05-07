import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:okaka/okaka.dart';

import 'vector_test_support.dart';

void main() {
  test('createRoom follows SPEC-006 vector', () async {
    final vector = readVector('test-vectors/rooms/create-room-basic.json');
    final requestBody = objectFrom(vector.request, 'body');

    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(
        jsonEncode(vector.bodyContains),
        vector.expected['status'] as int,
      );
    });

    final room = await client.rooms.createRoom(
      accessToken: vector.request['access_token'] as String,
      name: requestBody['name'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-1');
    expect(jsonDecode(observed.body), requestBody);
    expect(room.roomId, vector.bodyContains['room_id']);
    expect(room.name, vector.bodyContains['name']);
    expect(room.membership, OkakaRoomMembership.join);
  });

  test('joinRoom and leaveRoom follow SPEC-006 vectors', () async {
    final joinVector = readVector('test-vectors/rooms/join-room-basic.json');
    final leaveVector = readVector('test-vectors/rooms/leave-room-basic.json');
    final observed = <http.Request>[];
    final client = _client((request) async {
      observed.add(request);
      final body = observed.length == 1
          ? joinVector.bodyContains
          : leaveVector.bodyContains;
      return http.Response(jsonEncode(body), 200);
    });

    final joined = await client.rooms.joinRoom(
      accessToken: 'token-1',
      roomId: '!room:example.test',
    );
    final left = await client.rooms.leaveRoom(
      accessToken: 'token-1',
      roomId: '!room:example.test',
    );

    expect(observed.first.method, joinVector.request['method']);
    expect(observed.first.url.path, joinVector.request['path']);
    expect(joined.membership, OkakaRoomMembership.join);
    expect(observed.last.method, leaveVector.request['method']);
    expect(observed.last.url.path, leaveVector.request['path']);
    expect(left.membership, OkakaRoomMembership.leave);
  });

  test('getRoomState parses SPEC-006 event state vector', () async {
    final vector = readVector('test-vectors/rooms/room-state-basic.json');
    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final state = await client.rooms.getRoomState(
      accessToken: 'token-1',
      roomId: '!room:example.test',
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(state.events, hasLength(1));
    expect(state.events.single.type, 'chawan.room.name');
    expect(state.events.single.content['name'], 'General');
  });

  test('event model parses text events and rejects untrusted content', () {
    final valid = readVector('test-vectors/events/event-basic.json');
    final event = OkakaEvent.fromJson(objectFrom(valid.raw, 'event'));

    expect(event.eventId, r'$event:example.test');
    expect(event.textMessage?.body, valid.expected['text_body']);

    final bad = readVector('test-vectors/events/bad-event-payload.json');
    expect(
      () => OkakaEvent.fromJson(objectFrom(bad.raw, 'event')),
      throwsA(isA<OkakaResponseFormatException>()),
    );
    expect(
      () => OkakaRoom.fromJson({
        'room_id': '!room:example.test',
        'membership': 'unknown',
      }),
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
