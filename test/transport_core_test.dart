import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:okaka/src/transport.dart';
import 'package:okaka/okaka.dart';

void main() {
  test('transport supports method, query, headers, and JSON body', () async {
    late http.Request observed;
    final transport = OkakaTransport(
      serverBaseUri: Uri.parse('https://example.test/api'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    final response = await transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: const ['_chawan', 'client', 'echo'],
        queryParameters: const {'trace': '1'},
        headers: const {'X-Okaka-Test': 'yes'},
        body: const {'hello': 'world'},
      ),
    );

    expect(observed.method, 'POST');
    expect(
      observed.url.toString(),
      'https://example.test/api/_chawan/client/echo?trace=1',
    );
    expect(observed.headers['x-okaka-test'], 'yes');
    expect(observed.headers['content-type'], 'application/json');
    expect(jsonDecode(observed.body), {'hello': 'world'});
    expect(response.jsonObject, {'ok': true});
  });

  test('transport preserves Chawan error fields when present', () async {
    final transport = OkakaTransport(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'code': 'CHAWAN_UNAVAILABLE',
            'message': 'Service unavailable.',
          }),
          503,
        ),
      ),
    );

    await expectLater(
      transport.send(
        OkakaRequest(
          method: 'GET',
          pathSegments: const ['_chawan', 'client', 'versions'],
        ),
      ),
      throwsA(
        isA<OkakaHttpException>()
            .having((error) => error.statusCode, 'statusCode', 503)
            .having((error) => error.code, 'code', 'CHAWAN_UNAVAILABLE')
            .having(
              (error) => error.serverMessage,
              'serverMessage',
              'Service unavailable.',
            ),
      ),
    );
  });

  test('transport reports timeout before response as typed transport error',
      () {
    final transport = OkakaTransport(
      serverBaseUri: Uri.parse('https://example.test'),
      requestTimeout: const Duration(milliseconds: 1),
      httpClient: MockClient((_) => Completer<http.Response>().future),
    );

    expect(
      transport.send(
        OkakaRequest(
          method: 'GET',
          pathSegments: const ['_chawan', 'client', 'versions'],
        ),
      ),
      throwsA(isA<OkakaTransportException>()),
    );
  });

  test('transport preserves typed transport errors before response', () {
    final transport = OkakaTransport(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => throw StateError('unsupported method was not reached'),
      ),
    );

    expect(
      transport.send(
        OkakaRequest(
          method: 'PATCH',
          pathSegments: const ['_chawan', 'client', 'versions'],
        ),
      ),
      throwsA(
        isA<OkakaTransportException>()
            .having(
              (error) => error.message,
              'message',
              'Unsupported HTTP method: PATCH.',
            )
            .having((error) => error.cause, 'cause', isNull),
      ),
    );
  });
}
