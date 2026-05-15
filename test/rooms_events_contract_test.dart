import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix event retrieval helpers follow SPEC-085 vector', () async {
    final vector = readVector(
      'test-vectors/core/'
      'matrix-'
      'client-server-event-retrieval-membership-history.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final responses = objectFrom(event, 'sample_responses');
    final observed = <http.Request>[];
    final client = _client((request) async {
      observed.add(request);
      final path = request.url.path;
      final body = switch (path) {
        '/_matrix/client/v3/rooms/!room:example.test/event/\$event:example.test' =>
          objectFrom(responses, 'client_event'),
        '/_matrix/client/v3/rooms/!room:example.test/joined_members' =>
          objectFrom(responses, 'joined_members'),
        '/_matrix/client/v3/rooms/!room:example.test/members' =>
          objectFrom(responses, 'membership_chunk'),
        '/_matrix/client/v1/rooms/!room:example.test/timestamp_to_event' =>
          objectFrom(responses, 'timestamp_to_event'),
        _ => fail('unexpected Matrix room path: $path'),
      };
      return http.Response(jsonEncode(body), 200);
    });

    final roomEvent = await client.rooms.getMatrixRoomEvent(
      accessToken: 'token-1',
      roomId: '!room:example.test',
      eventId: r'$event:example.test',
    );
    final joined = await client.rooms.getMatrixJoinedMembers(
      accessToken: 'token-1',
      roomId: '!room:example.test',
    );
    final members = await client.rooms.getMatrixMembers(
      accessToken: 'token-1',
      roomId: '!room:example.test',
      at: 's123_456',
      membership: 'join',
      notMembership: 'leave',
    );
    final timestampToEvent = await client.rooms.matrixTimestampToEvent(
      accessToken: 'token-1',
      roomId: '!room:example.test',
      timestamp: 1715754600000,
      direction: 'b',
    );

    expect(roomEvent.eventId, r'$event:example.test');
    expect(roomEvent.content['body'], 'Hello');
    expect(joined.joined['@alice:example.test']!.displayName, 'Alice');
    expect(members.chunk, hasLength(2));
    expect(members.chunk.first.membership, 'join');
    expect(timestampToEvent.eventId, r'$event:example.test');
    expect(timestampToEvent.originServerTs, 1715754600000);
    expect(observed.map((request) => request.method), everyElement('GET'));
    expect(
      observed.map((request) => request.headers['authorization']),
      everyElement('Bearer token-1'),
    );
    expect(
      observed[2].url.queryParameters,
      {'at': 's123_456', 'membership': 'join', 'not_membership': 'leave'},
    );
    expect(observed[3].url.queryParameters, {
      'ts': '1715754600000',
      'dir': 'b',
    });
  });

  test('Matrix event retrieval parsers reject malformed SPEC-085 payloads', () {
    expect(
      () => HouraMatrixClientEvent.fromJson({
        'event_id': r'$event:example.test',
        'room_id': '!room:example.test',
        'sender': '@alice:example.test',
        'origin_server_ts': -1,
        'type': 'm.room.message',
        'content': {'body': 'Hello'},
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixJoinedMembers.fromJson({'joined': []}),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixMembers.fromJson({
        'chunk': [
          {
            'event_id': r'$event:example.test',
            'room_id': '!room:example.test',
            'sender': '@alice:example.test',
            'origin_server_ts': 1715754600000,
            'type': 'm.room.message',
            'content': {'body': 'Hello'},
          },
        ],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixTimestampToEvent.fromJson({
        'event_id': r'$event:example.test',
        'origin_server_ts': -1,
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () =>
          _client((_) async => http.Response('{}', 200)).rooms.getMatrixMembers(
                accessToken: 'token-1',
                roomId: '!room:example.test',
                membership: 'bad',
              ),
      throwsArgumentError,
    );
  });

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
    expect(room.membership, HouraRoomMembership.join);
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
    expect(joined.membership, HouraRoomMembership.join);
    expect(observed.last.method, leaveVector.request['method']);
    expect(observed.last.url.path, leaveVector.request['path']);
    expect(left.membership, HouraRoomMembership.leave);
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
    expect(state.events.single.type, 'houra.room.name');
    expect(state.events.single.content['name'], 'General');
  });

  test('event model parses text events and rejects untrusted content', () {
    final valid = readVector('test-vectors/events/event-basic.json');
    final event = HouraEvent.fromJson(objectFrom(valid.raw, 'event'));

    expect(event.eventId, r'$event:example.test');
    expect(event.textMessage?.body, valid.expected['text_body']);

    final bad = readVector('test-vectors/events/bad-event-payload.json');
    expect(
      () => HouraEvent.fromJson(objectFrom(bad.raw, 'event')),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraRoom.fromJson({
        'room_id': '!room:example.test',
        'membership': 'unknown',
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
