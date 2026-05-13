import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
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
