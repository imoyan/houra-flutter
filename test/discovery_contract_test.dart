import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('fetchVersions uses the SPEC-001 Houra discovery endpoint', () async {
    final vector = readVector('test-vectors/core/versions-basic.json');
    final bodyContains = vector.bodyContains;

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test/base'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(bodyContains),
          vector.expected['status'] as int,
        );
      }),
    );

    final versions = await client.discovery.fetchVersions();

    expect(observed.method, vector.request['method']);
    expect(
      observed.url.path,
      '/base${vector.request['path']}',
    );
    expect(versions.project, bodyContains['project']);
    expect(versions.apiVersion, bodyContains['api_version']);
    expect(versions.compatibilityLevel, bodyContains['compatibility_level']);
    expect(versions.features, bodyContains['features']);
  });

  test('fetchVersions rejects malformed response bodies', () async {
    final arrayClient = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((_) async => http.Response('[]', 200)),
    );

    await expectLater(
      arrayClient.discovery.fetchVersions(),
      throwsA(isA<HouraResponseFormatException>()),
    );

    final invalidJsonClient = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((_) async => http.Response('{', 200)),
    );

    await expectLater(
      invalidJsonClient.discovery.fetchVersions(),
      throwsA(isA<HouraResponseFormatException>()),
    );

    final invalidFeatureClient = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'project': 'houra',
            'api_version': '0.1-draft',
            'compatibility_level': 'level-1-csapi-subset',
            'features': [1],
          }),
          200,
        ),
      ),
    );

    await expectLater(
      invalidFeatureClient.discovery.fetchVersions(),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('fetchVersions preserves HTTP error body without logging it by default',
      () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async => http.Response('server unavailable', 503),
      ),
    );

    await expectLater(
      client.discovery.fetchVersions(),
      throwsA(
        isA<HouraHttpException>()
            .having((error) => error.statusCode, 'statusCode', 503)
            .having(
              (error) => error.responseBody,
              'responseBody',
              'server unavailable',
            )
            .having(
              (error) => error.responseBodySummary,
              'responseBodySummary',
              'server unavailable',
            )
            .having(
              (error) => error.message,
              'message',
              isNot(contains('server unavailable')),
            ),
      ),
    );
  });
}
