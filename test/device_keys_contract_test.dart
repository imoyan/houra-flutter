import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('key backup version lifecycle follows the SPEC-053 vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-key-backup-version-lifecycle.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;
    expect(steps, hasLength(vector.expected['step_count'] as int));

    for (final rawStep in steps) {
      final step = (rawStep as Map).cast<String, Object?>();

      late http.Request observed;
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((request) async {
          observed = request;
          final responseBody = step['expected_body_contains'];
          return http.Response(
            jsonEncode(responseBody ?? <String, Object?>{}),
            step['expected_status'] as int,
          );
        }),
      );

      switch (step['id']) {
        case 'create-backup-version':
          final expectedBody = objectFrom(step, 'body');
          final result = await client.deviceKeys.createKeyBackupVersion(
            accessToken: step['access_token'] as String,
            algorithm: expectedBody['algorithm'] as String,
            authData: objectFrom(expectedBody, 'auth_data'),
          );
          expect(result.version, '1');
        case 'get-current-backup-version':
          final result = await client.deviceKeys.getCurrentKeyBackupVersion(
            accessToken: step['access_token'] as String,
          );
          expect(result.version, '1');
          expect(
            result.authData!['public_key'],
            'backup-public-key-1',
          );
        case 'update-backup-auth-data':
          final expectedBody = objectFrom(step, 'body');
          await client.deviceKeys.updateKeyBackupVersion(
            accessToken: step['access_token'] as String,
            version: '1',
            algorithm: expectedBody['algorithm'] as String,
            authData: objectFrom(expectedBody, 'auth_data'),
          );
        case 'get-specific-backup-version':
          final result = await client.deviceKeys.getKeyBackupVersion(
            accessToken: step['access_token'] as String,
            version: '1',
          );
          expect(result.algorithm, 'm.megolm_backup.v1.curve25519-aes-sha2');
      }

      expect(observed.method, step['method']);
      expect(observed.url.path, step['path']);
      expect(observed.headers['authorization'], 'Bearer token-alice-device1');
      if (step.containsKey('body')) {
        final expectedBody = objectFrom(step, 'body');
        expect(jsonDecode(observed.body), expectedBody);
      } else {
        expect(observed.body, isEmpty);
      }
    }
  });

  test('key backup upload and restore follow the SPEC-053 vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;
    expect(steps, hasLength(vector.expected['step_count'] as int));

    for (final rawStep in steps) {
      final step = (rawStep as Map).cast<String, Object?>();
      late http.Request observed;
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((request) async {
          observed = request;
          final responseBody = objectFrom(step, 'expected_body_contains');
          return http.Response(
            jsonEncode(responseBody),
            step['expected_status'] as int,
          );
        }),
      );

      if (step['id'] == 'upload-room-key-session') {
        final requestBody = objectFrom(step, 'body');
        final result = await client.deviceKeys.uploadKeyBackupSession(
          accessToken: step['access_token'] as String,
          version: objectFrom(step, 'query')['version'] as String,
          roomId: event['room_id'] as String,
          sessionId: event['session_id'] as String,
          session: HouraKeyBackupSessionData.fromJson(requestBody),
        );
        expect(result.etag, 'etag-1');
        expect(result.count, 1);
        expect(jsonDecode(observed.body), requestBody);
      } else {
        final result = await client.deviceKeys.restoreKeyBackupSession(
          accessToken: step['access_token'] as String,
          version: objectFrom(step, 'query')['version'] as String,
          roomId: event['room_id'] as String,
          sessionId: event['session_id'] as String,
        );
        expect(result.firstMessageIndex, 1);
        expect(result.isVerified, isTrue);
        expect(result.sessionData['ciphertext'], 'backup-ciphertext');
        expect(observed.body, isEmpty);
      }

      expect(observed.method, step['method']);
      expect(observed.url.path, step['path']);
      expect(observed.url.queryParameters, objectFrom(step, 'query'));
    }
  });

  test('key backup HTTP errors map Matrix M_* envelopes', () async {
    final wrongVersion = readVector(
      'test-vectors/messaging/matrix-key-backup-wrong-version.json',
    );
    final missingSession = readVector(
      'test-vectors/messaging/matrix-key-backup-restore-missing-session.json',
    );

    Future<void> expectHttpError(
      ContractVector vector,
      Future<Object?> Function(HouraClient client) invoke,
    ) async {
      final error = objectFrom(vector.expected, 'error');
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient(
          (_) async => http.Response(
              jsonEncode(error), vector.expected['status'] as int),
        ),
      );

      await expectLater(
        invoke(client),
        throwsA(
          isA<HouraHttpException>()
              .having(
                (exception) => exception.statusCode,
                'statusCode',
                vector.expected['status'],
              )
              .having(
                (exception) => exception.code,
                'code',
                error['errcode'],
              )
              .having(
                (exception) => exception.serverMessage,
                'serverMessage',
                error['error'],
              ),
        ),
      );
    }

    await expectHttpError(wrongVersion, (client) {
      final request = objectFrom(wrongVersion.request, 'body');
      return client.deviceKeys.uploadKeyBackupSession(
        accessToken: wrongVersion.request['access_token'] as String,
        version: objectFrom(wrongVersion.request, 'query')['version'] as String,
        roomId: '!encrypted:example.test',
        sessionId: 'megolm-session-1',
        session: HouraKeyBackupSessionData.fromJson(request),
      );
    });

    await expectHttpError(missingSession, (client) {
      return client.deviceKeys.restoreKeyBackupSession(
        accessToken: missingSession.request['access_token'] as String,
        version:
            objectFrom(missingSession.request, 'query')['version'] as String,
        roomId: '!encrypted:example.test',
        sessionId: 'missing-session',
      );
    });
  });

  test('cross-signing lifecycle follows the SPEC-054 vector', () async {
    final vector = readVector(
      'test-vectors/messaging/matrix-cross-signing-key-lifecycle.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final steps = event['steps'] as List<Object?>;

    for (final rawStep in steps) {
      final step = (rawStep as Map).cast<String, Object?>();

      late http.Request observed;
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((request) async {
          observed = request;
          final responseBody = switch (step['id']) {
            'query-cross-signing-keys' => <String, Object?>{
                'failures': <String, Object?>{},
                'device_keys': <String, Object?>{},
                ...objectFrom(step, 'expected_body_contains'),
              },
            'upload-device-signature' => objectFrom(
                step,
                'expected_body_contains',
              ),
            _ => <String, Object?>{},
          };
          return http.Response(
            jsonEncode(responseBody),
            step['expected_status'] as int,
          );
        }),
      );

      switch (step['id']) {
        case 'upload-cross-signing-keys':
          final body = objectFrom(step, 'body');
          await client.deviceKeys.uploadCrossSigningKeys(
            accessToken: step['access_token'] as String,
            masterKey: HouraMatrixCrossSigningKey.fromJson(
              objectFrom(body, 'master_key'),
            ),
            selfSigningKey: HouraMatrixCrossSigningKey.fromJson(
              objectFrom(body, 'self_signing_key'),
            ),
            userSigningKey: HouraMatrixCrossSigningKey.fromJson(
              objectFrom(body, 'user_signing_key'),
            ),
          );
          expect(jsonDecode(observed.body), body);
        case 'query-cross-signing-keys':
          final body = objectFrom(step, 'body');
          final result = await client.deviceKeys.queryDeviceKeys(
            accessToken: step['access_token'] as String,
            deviceKeys: const {'@alice:example.test': []},
          );
          expect(jsonDecode(observed.body), body);
          expect(result.deviceKeys, isEmpty);
          expect(result.masterKeys['@alice:example.test']!.usage, ['master']);
          expect(result.selfSigningKeys['@alice:example.test']!.usage, [
            'self_signing',
          ]);
          expect(result.userSigningKeys['@alice:example.test']!.usage, [
            'user_signing',
          ]);
        case 'upload-device-signature':
          final body = objectFrom(step, 'body');
          final result = await client.deviceKeys.uploadKeySignatures(
            accessToken: step['access_token'] as String,
            signedKeys: {
              '@alice:example.test': {
                'ALICE2': HouraMatrixSignedJsonObject.fromJson(
                  objectFrom(body, '@alice:example.test')['ALICE2']
                      as Map<String, Object?>,
                ),
              },
            },
          );
          expect(jsonDecode(observed.body), body);
          expect(result.failures, isEmpty);
      }

      expect(observed.method, step['method']);
      expect(observed.url.path, step['path']);
      expect(observed.headers['authorization'], 'Bearer token-alice-device1');
    }
  });

  test('verification SAS vectors parse SPEC-054 public envelopes', () {
    final happyPath = readVector(
      'test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json',
    );
    final cancelPath = readVector(
      'test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json',
    );

    final happyEvent = objectFrom(happyPath.raw, 'event');
    final happySteps = happyEvent['steps'] as List<Object?>;
    final request = HouraMatrixVerificationRequestContent.fromJson(
      objectFrom((happySteps[0] as Map).cast<String, Object?>(), 'content'),
    );
    final ready = HouraMatrixVerificationReadyContent.fromJson(
      objectFrom((happySteps[1] as Map).cast<String, Object?>(), 'content'),
    );
    final start = HouraMatrixVerificationStartContent.fromJson(
      objectFrom((happySteps[2] as Map).cast<String, Object?>(), 'content'),
    );
    final accept = HouraMatrixVerificationAcceptContent.fromJson(
      objectFrom((happySteps[3] as Map).cast<String, Object?>(), 'content'),
    );
    final key = HouraMatrixVerificationKeyContent.fromJson(
      objectFrom((happySteps[4] as Map).cast<String, Object?>(), 'content'),
    );
    final mac = HouraMatrixVerificationMacContent.fromJson(
      objectFrom((happySteps[5] as Map).cast<String, Object?>(), 'content'),
    );

    expect(request.transactionId, 'verif-txn-1');
    expect(request.methods, ['m.sas.v1']);
    expect(ready.fromDevice, 'ALICE2');
    expect(start.method, 'm.sas.v1');
    expect(start.shortAuthenticationString, ['decimal', 'emoji']);
    expect(accept.keyAgreementProtocol, 'curve25519-hkdf-sha256');
    expect(key.key, 'base64-ephemeral-public-key');
    expect(mac.mac['ed25519:ALICE2'], 'base64-device-key-mac');
    expect(happyPath.expected['local_sas_allowed'], isFalse);
    expect(happyPath.expected['versions_advertisement_widened'], isFalse);

    final cancelEvent = objectFrom(cancelPath.raw, 'event');
    final cancelSteps = cancelEvent['steps'] as List<Object?>;
    final cancel = HouraMatrixVerificationCancelContent.fromJson(
      objectFrom((cancelSteps[1] as Map).cast<String, Object?>(), 'content'),
    );

    expect(cancel.code, 'm.mismatched_sas');
    expect(cancel.reason, 'Short authentication string did not match');
    expect(cancel.transactionId, 'verif-txn-mismatch');
    expect(cancelPath.expected['verified'], isFalse);
    expect(cancelPath.expected['versions_advertisement_widened'], isFalse);
  });

  test('cross-signing HTTP errors map Matrix M_* envelopes', () async {
    final invalidSignature = readVector(
      'test-vectors/messaging/matrix-cross-signing-invalid-signature.json',
    );
    final missingToken = readVector(
      'test-vectors/messaging/matrix-cross-signing-missing-token.json',
    );
    final missingTokenEvent = objectFrom(missingToken.raw, 'event');
    final missingTokenSteps = missingTokenEvent['steps'] as List<Object?>;

    Future<void> expectHttpError(
      int status,
      Map<String, Object?> error,
      Future<Object?> Function(HouraClient client) invoke,
    ) async {
      final client = HouraClient(
        serverBaseUri: Uri.parse('https://example.test'),
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode(error), status),
        ),
      );

      await expectLater(
        invoke(client),
        throwsA(
          isA<HouraHttpException>()
              .having((exception) => exception.statusCode, 'statusCode', status)
              .having((exception) => exception.code, 'code', error['errcode'])
              .having(
                (exception) => exception.serverMessage,
                'serverMessage',
                error['error'],
              ),
        ),
      );
    }

    await expectHttpError(
      invalidSignature.expected['status'] as int,
      objectFrom(invalidSignature.expected, 'error'),
      (client) => client.deviceKeys.uploadCrossSigningKeys(
        accessToken: 'unused-by-mock',
        selfSigningKey: HouraMatrixCrossSigningKey.fromJson(
          objectFrom(
              objectFrom(invalidSignature.request, 'body'), 'self_signing_key'),
        ),
      ),
    );

    for (final rawStep in missingTokenSteps) {
      final step = (rawStep as Map).cast<String, Object?>();
      final error = objectFrom(step, 'expected_error');
      switch (step['id']) {
        case 'missing-token-device-signing-upload':
          await expectHttpError(step['expected_status'] as int, error,
              (client) {
            final body = objectFrom(step, 'body');
            return client.deviceKeys.uploadCrossSigningKeys(
              accessToken: 'unused-by-mock',
              selfSigningKey: HouraMatrixCrossSigningKey.fromJson(
                objectFrom(body, 'self_signing_key'),
              ),
            );
          });
        case 'missing-token-keys-query':
          await expectHttpError(step['expected_status'] as int, error,
              (client) {
            return client.deviceKeys.queryDeviceKeys(
              accessToken: 'unused-by-mock',
              deviceKeys: const {'@alice:example.test': []},
            );
          });
        case 'missing-token-signatures-upload':
          await expectHttpError(step['expected_status'] as int, error,
              (client) {
            final body = objectFrom(step, 'body');
            return client.deviceKeys.uploadKeySignatures(
              accessToken: 'unused-by-mock',
              signedKeys: {
                '@alice:example.test': {
                  'ALICE2': HouraMatrixSignedJsonObject.fromJson(
                    objectFrom(body, '@alice:example.test')['ALICE2']
                        as Map<String, Object?>,
                  ),
                },
              },
            );
          });
      }
    }
  });

  test('cross-signing request descriptors reject invalid local input',
      () async {
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await expectLater(
      client.deviceKeys
          .uploadCrossSigningKeys(accessToken: 'token-alice-device1'),
      throwsA(isA<HouraTransportException>()),
    );
    await expectLater(
      client.deviceKeys.uploadKeySignatures(
        accessToken: 'token-alice-device1',
        signedKeys: const {},
      ),
      throwsA(isA<HouraTransportException>()),
    );
  });

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
