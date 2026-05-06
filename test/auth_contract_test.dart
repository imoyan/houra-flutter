import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:okaka/src/transport.dart';
import 'package:okaka/okaka.dart';

import 'vector_test_support.dart';

void main() {
  test('fetchLoginFlows follows SPEC-003 vector', () async {
    final vector = readVector('test-vectors/auth/login-flows-basic.json');
    final body = vector.bodyContains;

    late http.Request observed;
    final client = OkakaClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(body),
          vector.expected['status'] as int,
        );
      }),
    );

    final flows = await client.auth.fetchLoginFlows();

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(flows.flows, hasLength(1));
    expect(flows.flows.single.type, okakaPasswordLoginType);
  });

  test('loginWithPassword follows SPEC-004 vector', () async {
    final vector = readVector('test-vectors/auth/password-login-basic.json');
    final requestBody = objectFrom(vector.request, 'body');
    final body = vector.bodyContains;

    late http.Request observed;
    final client = OkakaClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(body),
          vector.expected['status'] as int,
        );
      }),
    );

    final session = await client.auth.loginWithPassword(
      username: 'alice',
      password: 'correct horse battery staple',
      deviceId: 'DEVICE1',
      initialDeviceDisplayName: 'Alice phone',
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(jsonDecode(observed.body), requestBody);
    expect(session.userId, body['user_id']);
    expect(session.accessToken, body['access_token']);
    expect(session.deviceId, body['device_id']);
  });

  test('whoami follows SPEC-004 bearer token vector', () async {
    final vector = readVector('test-vectors/auth/whoami-basic.json');
    final body = vector.bodyContains;

    late http.Request observed;
    final client = OkakaClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(body),
          vector.expected['status'] as int,
        );
      }),
    );

    final whoami = await client.auth.whoami(
      accessToken: vector.request['access_token'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.query, isEmpty);
    expect(observed.headers['authorization'], 'Bearer token-1');
    expect(whoami.userId, body['user_id']);
    expect(whoami.deviceId, body['device_id']);
  });

  test('logout follows SPEC-004 bearer token vector', () async {
    final vector = readVector('test-vectors/auth/logout-basic.json');

    late http.Request observed;
    final client = OkakaClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response('{}', vector.expected['status'] as int);
      }),
    );

    await client.auth.logout(
      accessToken: vector.request['access_token'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.query, isEmpty);
    expect(observed.headers['authorization'], 'Bearer token-1');
  });

  test('auth parsers reject malformed responses', () {
    expect(
      () => OkakaLoginFlows.fromJson({'flows': <Object?>[]}),
      throwsA(isA<OkakaResponseFormatException>()),
    );
    expect(
      () => OkakaLoginFlows.fromJson({
        'flows': [
          {'type': ''},
        ],
      }),
      throwsA(isA<OkakaResponseFormatException>()),
    );
    expect(
      () => OkakaAuthSession.fromJson({
        'user_id': '@alice:example.test',
        'access_token': '',
      }),
      throwsA(isA<OkakaResponseFormatException>()),
    );
    expect(
      () => OkakaWhoami.fromJson({'device_id': 'DEVICE1'}),
      throwsA(isA<OkakaResponseFormatException>()),
    );
  });

  test('auth HTTP errors preserve Chawan error fields', () async {
    final vector = readVector('test-vectors/auth/auth-error-basic.json');
    final response = objectFrom(vector.raw, 'response');
    final expected = objectFrom(vector.raw, 'expected');
    final body = objectFrom(response, 'body');

    final client = OkakaClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode(body),
          response['status'] as int,
        ),
      ),
    );

    await expectLater(
      client.auth.whoami(accessToken: 'bad-token'),
      throwsA(
        isA<OkakaHttpException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.code, 'code', expected['code'])
            .having(
              (error) => error.serverMessage,
              'serverMessage',
              expected['message'],
            )
            .having(
              (error) => error.responseBodySummary,
              'responseBodySummary',
              contains(expected['code'] as String),
            ),
      ),
    );
  });

  test('transport rejects access_token query parameters', () {
    expect(
      () => OkakaRequest(
        method: 'GET',
        pathSegments: const ['_chawan', 'client', 'account', 'whoami'],
        queryParameters: const {'access_token': 'token-1'},
      ),
      throwsA(isA<OkakaTransportException>()),
    );
  });
}
