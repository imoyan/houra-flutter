import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('uploadKeys follows the SPEC-051 upload vector', () async {
    final vector = readVector(
      'test-vectors/auth/matrix-keys-upload-device-one-time-fallback-basic.json',
    );
    final requestBody = objectFrom(vector.request, 'body');
    final oneTimeKeys = objectFrom(requestBody, 'one_time_keys');
    final fallbackKeys = objectFrom(requestBody, 'fallback_keys');
    final responseBody = vector.bodyContains;

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(responseBody),
          vector.expected['status'] as int,
        );
      }),
    );

    final result = await client.deviceKeys.uploadKeys(
      accessToken: vector.request['access_token'] as String,
      deviceKey: HouraMatrixDeviceKey.fromJson(
        objectFrom(requestBody, 'device_keys'),
      ),
      oneTimeKeys: {
        'signed_curve25519:otk1': HouraMatrixSignedKey.fromJson(
          objectFrom(oneTimeKeys, 'signed_curve25519:otk1'),
        ),
      },
      fallbackKeys: {
        'signed_curve25519:fb1': HouraMatrixSignedKey.fromJson(
          objectFrom(fallbackKeys, 'signed_curve25519:fb1'),
        ),
      },
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-alice-device1');
    expect(jsonDecode(observed.body), requestBody);
    expect(result.oneTimeKeyCounts, {'signed_curve25519': 1});
  });

  test('claimKeys follows the SPEC-051 one-time and fallback vector', () async {
    final vector = readVector(
      'test-vectors/auth/matrix-keys-claim-one-time-fallback-basic.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;
    expect(steps, hasLength(vector.expected['step_count'] as int));

    for (final rawStep in steps) {
      final step = (rawStep as Map).cast<String, Object?>();
      final requestBody = objectFrom(step, 'body');
      final responseBody = objectFrom(step, 'expected_body_contains');

      late http.Request observed;
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((request) async {
          observed = request;
          return http.Response(
            jsonEncode(responseBody),
            step['expected_status'] as int,
          );
        }),
      );

      final result = await client.deviceKeys.claimKeys(
        accessToken: step['access_token'] as String,
        oneTimeKeys: const {
          '@alice:example.test': {'DEVICE1': 'signed_curve25519'},
        },
      );

      expect(observed.method, step['method']);
      expect(observed.url.path, step['path']);
      expect(observed.headers['authorization'], 'Bearer token-bob-device1');
      expect(jsonDecode(observed.body), requestBody);

      final claimedKeys =
          result.oneTimeKeys['@alice:example.test']!['DEVICE1']!;
      if (step['id'] == 'claim-one-time-key') {
        final oneTimeKey = claimedKeys['signed_curve25519:otk1']!;
        expect(oneTimeKey.key, 'one-time-public-key-1');
        expect(oneTimeKey.fallback, isNull);
        expect(
          oneTimeKey.signatures['@alice:example.test']!['ed25519:DEVICE1'],
          'signature-otk1',
        );
      } else {
        final fallbackKey = claimedKeys['signed_curve25519:fb1']!;
        expect(fallbackKey.key, 'fallback-public-key-1');
        expect(fallbackKey.fallback, isTrue);
        expect(
          fallbackKey.signatures['@alice:example.test']!['ed25519:DEVICE1'],
          'signature-fb1',
        );
      }
    }
  });

  test('queryDeviceKeys follows the SPEC-069 basic vector', () async {
    final vector = readVector('test-vectors/auth/matrix-keys-query-basic.json');
    final requestBody = objectFrom(vector.request, 'body');
    final body = vector.bodyContains;

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(
          jsonEncode(body),
          vector.expected['status'] as int,
        );
      }),
    );

    final result = await client.deviceKeys.queryDeviceKeys(
      accessToken: vector.request['access_token'] as String,
      deviceKeys: const {
        '@alice:example.test': ['DEVICE1'],
      },
      timeoutMs: 10000,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.url.query, isEmpty);
    expect(observed.headers['authorization'], 'Bearer token-bob-device1');
    expect(jsonDecode(observed.body), requestBody);

    expect(result.failures, isEmpty);
    final device = result.deviceKeys['@alice:example.test']!['DEVICE1']!;
    expect(device.userId, '@alice:example.test');
    expect(device.deviceId, 'DEVICE1');
    expect(device.algorithms, [
      'm.olm.v1.curve25519-aes-sha2',
      'm.megolm.v1.aes-sha2',
    ]);
    expect(device.keys['curve25519:DEVICE1'], 'curve25519-public-device1');
    expect(device.keys['ed25519:DEVICE1'], 'ed25519-public-device1');
    expect(
      device.signatures['@alice:example.test']!['ed25519:DEVICE1'],
      'signature-device1',
    );
    expect(device.unsigned!['device_display_name'], 'Alice phone');
    expect(device.raw['unsigned'], isA<Map<String, Object?>>());
  });

  test('queryDeviceKeys handles all-device and omission vectors', () async {
    final allDevices = readVector(
      'test-vectors/auth/matrix-keys-query-all-devices.json',
    );
    final unknownDevice = readVector(
      'test-vectors/auth/matrix-keys-query-unknown-device-omitted.json',
    );

    final allDevicesResult = HouraDeviceKeyQueryResponse.fromJson(
      allDevices.bodyContains,
    );
    expect(
      allDevicesResult.deviceKeys['@alice:example.test']!.keys,
      containsAll(['DEVICE1', 'DEVICE2']),
    );

    final unknownDeviceResult = HouraDeviceKeyQueryResponse.fromJson(
      unknownDevice.bodyContains,
    );
    expect(unknownDeviceResult.deviceKeys.keys, ['@alice:example.test']);
    expect(unknownDeviceResult.deviceKeys['@alice:example.test']!.keys, [
      'DEVICE1',
    ]);
  });

  test('queryDeviceKeys rejects invalid request descriptors locally', () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await expectLater(
      client.deviceKeys.queryDeviceKeys(
        accessToken: 'token-bob-device1',
        deviceKeys: const {},
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.queryDeviceKeys(
        accessToken: 'token-bob-device1',
        deviceKeys: const {'@alice:example.test': []},
        timeoutMs: -1,
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.queryDeviceKeys(
        accessToken: 'token-bob-device1',
        deviceKeys: const {
          '@alice:example.test': [''],
        },
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.queryDeviceKeys(
        accessToken: 'token-bob-device1',
        deviceKeys: const {'@alice:example.test': []},
        syncToken: '',
      ),
      throwsA(isA<HouraTransportException>()),
    );
  });

  test('uploadKeys and claimKeys reject invalid request descriptors locally',
      () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await expectLater(
      client.deviceKeys.uploadKeys(accessToken: 'token-alice-device1'),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.uploadKeys(
        accessToken: 'token-alice-device1',
        oneTimeKeys: {
          '': HouraMatrixSignedKey.fromJson({
            'key': 'one-time-public-key-1',
            'signatures': {
              '@alice:example.test': {'ed25519:DEVICE1': 'signature-otk1'},
            },
          }),
        },
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.claimKeys(
        accessToken: 'token-bob-device1',
        oneTimeKeys: const {},
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.claimKeys(
        accessToken: 'token-bob-device1',
        oneTimeKeys: const {'@alice:example.test': {}},
      ),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.claimKeys(
        accessToken: 'token-bob-device1',
        oneTimeKeys: const {
          '@alice:example.test': {'DEVICE1': 'signed_curve25519'},
        },
        timeoutMs: -1,
      ),
      throwsA(isA<HouraTransportException>()),
    );
  });

  test('key upload request bodies derive JSON from typed public fields',
      () async {
    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response('{"one_time_key_counts":{}}', 200);
      }),
    );

    await client.deviceKeys.uploadKeys(
      accessToken: 'token-alice-device1',
      deviceKey: HouraMatrixDeviceKey(
        userId: '@alice:example.test',
        deviceId: 'DEVICE1',
        algorithms: const ['m.olm.v1.curve25519-aes-sha2'],
        keys: const {'ed25519:DEVICE1': 'ed25519-public-device1'},
        signatures: const {
          '@alice:example.test': {'ed25519:DEVICE1': 'signature-device1'},
        },
        raw: const {'user_id': '@stale:example.test'},
      ),
      oneTimeKeys: {
        'signed_curve25519:otk1': HouraMatrixSignedKey(
          key: 'one-time-public-key-1',
          signatures: const {
            '@alice:example.test': {'ed25519:DEVICE1': 'signature-otk1'},
          },
          raw: const {'key': 'stale-key'},
        ),
      },
    );

    final body = jsonDecode(observed.body) as Map<String, Object?>;
    expect(objectFrom(body, 'device_keys')['user_id'], '@alice:example.test');
    expect(
      objectFrom(
          objectFrom(body, 'one_time_keys'), 'signed_curve25519:otk1')['key'],
      'one-time-public-key-1',
    );
  });

  test('device key parser rejects malformed successful responses', () {
    expect(
      () => HouraDeviceKeyQueryResponse.fromJson({
        'failures': <String, Object?>{},
        'device_keys': {
          '@alice:example.test': {
            'DEVICE1': {
              'user_id': '@alice:example.test',
              'device_id': 'DEVICE1',
              'algorithms': ['m.olm.v1.curve25519-aes-sha2'],
              'keys': {'ed25519:DEVICE1': ''},
              'signatures': <String, Object?>{},
            },
          },
        },
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraDeviceKeyQueryResponse.fromJson({
        'failures': <String, Object?>{},
        'device_keys': {
          '@alice:example.test': {
            'DEVICE1': {
              'user_id': '@alice:example.test',
              'device_id': 'DEVICE1',
              'algorithms': [1],
              'keys': {'ed25519:DEVICE1': 'ed25519-public-device1'},
              'signatures': <String, Object?>{},
            },
          },
        },
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('key upload and claim parsers reject malformed successful responses',
      () {
    expect(
      () => HouraKeyUploadResponse.fromJson({
        'one_time_key_counts': {'signed_curve25519': '1'},
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraKeyUploadResponse.fromJson({
        'one_time_key_counts': {'signed_curve25519': -1},
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraKeyClaimResponse.fromJson({
        'failures': <String, Object?>{},
        'one_time_keys': {
          '@alice:example.test': {
            'DEVICE1': {
              'signed_curve25519:otk1': {
                'key': '',
                'signatures': <String, Object?>{},
              },
            },
          },
        },
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('Matrix M_* HTTP errors are exposed on HouraHttpException', () async {
    final vector = readVector(
      'test-vectors/auth/matrix-keys-query-missing-token.json',
    );
    final error = objectFrom(vector.expected, 'error');

    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient(
        (_) async =>
            http.Response(jsonEncode(error), vector.expected['status'] as int),
      ),
    );

    await expectLater(
      client.deviceKeys.queryDeviceKeys(
        accessToken: 'unused-by-mock',
        deviceKeys: const {'@alice:example.test': []},
      ),
      throwsA(
        isA<HouraHttpException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.code, 'code', 'M_MISSING_TOKEN')
            .having(
              (error) => error.serverMessage,
              'serverMessage',
              'Missing access token.',
            ),
      ),
    );
  });
}
