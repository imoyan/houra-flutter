import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/src/transport.dart';
import 'package:houra/houra.dart';

void main() {
  test('transport supports method, query, headers, and JSON body', () async {
    late http.Request observed;
    final transport = HouraTransport(
      serverBaseUri: Uri.parse('https://example.test/api'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    final response = await transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_houra', 'client', 'echo'],
        queryParameters: const {'trace': '1'},
        headers: const {'X-Houra-Test': 'yes'},
        body: const {'hello': 'world'},
      ),
    );

    expect(observed.method, 'POST');
    expect(
      observed.url.toString(),
      'https://example.test/api/_houra/client/echo?trace=1',
    );
    expect(observed.headers['x-houra-test'], 'yes');
    expect(observed.headers['content-type'], 'application/json');
    expect(jsonDecode(observed.body), {'hello': 'world'});
    expect(response.jsonObject, {'ok': true});
  });

  test('transport preserves Houra error fields when present', () async {
    final transport = HouraTransport(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'code': 'HOURA_UNAVAILABLE',
            'message': 'Service unavailable.',
          }),
          503,
        ),
      ),
    );

    await expectLater(
      transport.send(
        HouraRequest(
          method: 'GET',
          pathSegments: const ['_houra', 'client', 'versions'],
        ),
      ),
      throwsA(
        isA<HouraHttpException>()
            .having((error) => error.statusCode, 'statusCode', 503)
            .having((error) => error.code, 'code', 'HOURA_UNAVAILABLE')
            .having(
              (error) => error.serverMessage,
              'serverMessage',
              'Service unavailable.',
            ),
      ),
    );
  });

  test(
    'transport reports timeout before response as typed transport error',
    () {
      final transport = HouraTransport(
        serverBaseUri: Uri.parse('https://example.test'),
        requestTimeout: const Duration(milliseconds: 1),
        httpClient: MockClient((_) => Completer<http.Response>().future),
      );

      expect(
        transport.send(
          HouraRequest(
            method: 'GET',
            pathSegments: const ['_houra', 'client', 'versions'],
          ),
        ),
        throwsA(isA<HouraTransportException>()),
      );
    },
  );

  test('transport preserves typed transport errors before response', () {
    final transport = HouraTransport(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => throw StateError('unsupported method was not reached'),
      ),
    );

    expect(
      transport.send(
        HouraRequest(
          method: 'PATCH',
          pathSegments: const ['_houra', 'client', 'versions'],
        ),
      ),
      throwsA(
        isA<HouraTransportException>()
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
