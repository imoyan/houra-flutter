import 'dart:convert';
import 'dart:io';

import 'package:houra/houra.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<void> main() async {
  try {
    await runSdkUsageExample(log: stdout.writeln);
  } on HouraHttpException catch (error) {
    final details = [
      'status=${error.statusCode}',
      if (error.code != null) 'code=${error.code}',
      if (error.serverMessage != null) 'message=${error.serverMessage}',
    ].join(' ');
    stderr.writeln('Houra HTTP error: $details');
    exitCode = 1;
  } on HouraException catch (error) {
    stderr.writeln('Houra SDK error: ${error.message}');
    exitCode = 1;
  }
}

Future<HouraExampleSummary> runSdkUsageExample({
  void Function(String message)? log,
}) async {
  final httpClient = _fakeHouraServer();
  final client = HouraClient(
    serverBaseUri: Uri.parse('https://example.test'),
    httpClient: httpClient,
  );
  final syncTokens = HouraMemorySyncTokenStore();

  try {
    final versions = await client.discovery.fetchVersions();
    final flows = await client.auth.fetchLoginFlows();
    final session = await client.auth.loginWithPassword(
      username: '@alice:example.test',
      password: 'example-only-password',
      deviceId: 'EXAMPLE_DEVICE',
      initialDeviceDisplayName: 'Houra SDK example',
    );
    final rooms = await client.sync.listRooms(
      accessToken: session.accessToken,
    );
    final firstRoom = rooms.rooms.first;
    final timeline = await client.sync.getTimeline(
      accessToken: session.accessToken,
      roomId: firstRoom.roomId,
      limit: 10,
    );
    final sentEventId = await client.messaging.sendTextMessage(
      accessToken: session.accessToken,
      roomId: firstRoom.roomId,
      clientTransactionId: 'example-tx-1',
      body: 'Hello from Houra SDK example',
    );
    final media = await client.media.getMetadata(
      accessToken: session.accessToken,
      mediaId: 'media-1',
    );
    final sync = await client.sync.pollOnce(
      accessToken: session.accessToken,
      tokenStore: syncTokens,
      timeout: const Duration(seconds: 1),
    );
    final theme = HouraThemeTokens.fromJsonString(
      File('design/themes/smoke.json').readAsStringSync(),
    ).resolve(HouraThemeVariant.light);

    final summary = HouraExampleSummary(
      apiVersion: versions.apiVersion,
      loginFlowTypes: flows.flows.map((flow) => flow.type).toList(),
      userId: session.userId,
      roomNames: rooms.rooms.map((room) => room.name ?? room.roomId).toList(),
      timelineBodies: timeline.events
          .map((event) => event.textMessage?.body)
          .whereType<String>()
          .toList(),
      sentEventId: sentEventId,
      mediaFilename: media.filename ?? media.mediaId,
      nextBatch: sync.nextBatch,
      lightBackground: theme.colorHex('background'),
    );

    log?.call('API version: ${summary.apiVersion}');
    log?.call('Login flows: ${summary.loginFlowTypes.join(', ')}');
    log?.call('Signed in as: ${summary.userId}');
    log?.call('Rooms: ${summary.roomNames.join(', ')}');
    log?.call('Timeline: ${summary.timelineBodies.join(' | ')}');
    log?.call('Sent event: ${summary.sentEventId}');
    log?.call('Media: ${summary.mediaFilename}');
    log?.call('Next sync token: ${summary.nextBatch}');
    log?.call('Light background token: ${summary.lightBackground}');

    return summary;
  } finally {
    client.close();
    httpClient.close();
  }
}

final class HouraExampleSummary {
  const HouraExampleSummary({
    required this.apiVersion,
    required this.loginFlowTypes,
    required this.userId,
    required this.roomNames,
    required this.timelineBodies,
    required this.sentEventId,
    required this.mediaFilename,
    required this.nextBatch,
    required this.lightBackground,
  });

  final String apiVersion;
  final List<String> loginFlowTypes;
  final String userId;
  final List<String> roomNames;
  final List<String> timelineBodies;
  final String sentEventId;
  final String mediaFilename;
  final String nextBatch;
  final String lightBackground;
}

http.Client _fakeHouraServer() {
  return MockClient((request) async {
    final path = request.url.pathSegments;
    final auth = request.headers['authorization'];

    if (request.method == 'GET' && _matches(path, '_houra/client/versions')) {
      return _json({
        'project': 'houra',
        'api_version': '0.2.0-example',
        'compatibility_level': 'draft',
        'features': ['discovery', 'auth', 'rooms', 'messaging', 'media'],
      });
    }

    if (request.method == 'GET' && _matches(path, '_houra/client/login')) {
      return _json({
        'flows': [
          {'type': houraPasswordLoginType},
        ],
      });
    }

    if (request.method == 'POST' && _matches(path, '_houra/client/login')) {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      if (body['type'] != houraPasswordLoginType) {
        return _json({'code': 'HOURA_BAD_LOGIN', 'message': 'Bad login.'}, 400);
      }
      return _json({
        'user_id': '@alice:example.test',
        'access_token': 'example-access-token',
        'device_id': 'EXAMPLE_DEVICE',
      });
    }

    if (auth != 'Bearer example-access-token') {
      return _json(
        {'code': 'HOURA_MISSING_TOKEN', 'message': 'Missing token.'},
        401,
      );
    }

    if (request.method == 'GET' && _matches(path, '_houra/client/rooms')) {
      return _json({
        'rooms': [
          {
            'room_id': '!demo:example.test',
            'name': 'Demo room',
            'membership': 'join',
          },
        ],
      });
    }

    if (request.method == 'GET' &&
        _matches(path, '_houra/client/rooms/!demo:example.test/timeline')) {
      return _json({
        'start': 's1',
        'end': 's2',
        'events': [_messageEvent('event-1', 'Welcome to Houra')],
      });
    }

    if (request.method == 'POST' &&
        _matches(path, '_houra/client/rooms/!demo:example.test/messages')) {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      if (body['client_transaction_id'] != 'example-tx-1') {
        return _json(
          {'code': 'HOURA_BAD_TXN', 'message': 'Bad transaction.'},
          400,
        );
      }
      return _json({'event_id': 'event-2'});
    }

    if (request.method == 'GET' &&
        _matches(path, '_houra/client/media/media-1')) {
      return _json({
        'media_id': 'media-1',
        'filename': 'sample.txt',
        'content_type': 'text/plain',
        'download_url': 'https://example.test/download/media-1',
      });
    }

    if (request.method == 'GET' && _matches(path, '_houra/client/sync')) {
      return _json({
        'next_batch': 'sync-2',
        'rooms': [
          {
            'room_id': '!demo:example.test',
            'timeline': {
              'events': [_messageEvent('event-3', 'Synced update')],
            },
          },
        ],
      });
    }

    return _json({'code': 'HOURA_NOT_FOUND', 'message': 'Not found.'}, 404);
  });
}

http.Response _json(Map<String, Object?> body, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

Map<String, Object?> _messageEvent(String eventId, String body) {
  return {
    'event_id': eventId,
    'room_id': '!demo:example.test',
    'sender': '@alice:example.test',
    'origin_server_ts': 1760000000000,
    'type': 'houra.room.message',
    'content': {'msgtype': houraTextMessageType, 'body': body},
  };
}

bool _matches(List<String> pathSegments, String pattern) {
  return pathSegments.join('/') == pattern;
}
