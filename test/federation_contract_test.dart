import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix federation version/key lifecycle parsers follow SPEC-097', () {
    final vector = readVector(
      'test-vectors/core/matrix-federation-version-key-lifecycle-request-auth.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final descriptors = event['request_descriptors'] as List<Object?>;
    final responses = objectFrom(event, 'sample_responses');

    final parsedDescriptors = descriptors
        .map((descriptor) => (descriptor as Map).cast<String, Object?>())
        .map(HouraMatrixFederationRequestDescriptor.fromJson)
        .toList();
    expect(parsedDescriptors, hasLength(vector.expected['descriptor_count']));
    expect(parsedDescriptors.first.responseParser, 'federation_version');

    final version = HouraMatrixFederationVersion.fromJson(
      objectFrom(responses, 'version'),
    );
    expect(version.serverName, 'Houra');
    expect(version.serverVersion, '0.1.0');

    final keyQuery = HouraMatrixFederationKeyQueryResponse.fromJson(
      objectFrom(responses, 'key_query'),
    );
    expect(keyQuery.serverKeys, hasLength(1));
    final signingKey = keyQuery.serverKeys.single;
    expect(
        signingKey.verifyKeys, hasLength(vector.expected['verify_key_count']));
    expect(
        signingKey.oldVerifyKeys, hasLength(vector.expected['old_key_count']));
    expect(signingKey.signatures, contains('notary.example.test'));

    final auth = HouraMatrixFederationRequestAuthDescriptor.fromJson(
      objectFrom(responses, 'request_auth'),
    );
    expect(auth.scheme, 'X-Matrix');
    expect(auth.origin, 'example.test');
    expect(auth.destination, 'remote.example.test');
    expect(auth.key, 'ed25519:auto1');
    expect(auth.signedJsonFields, contains('method'));

    expect(
      () => HouraMatrixFederationRequestAuthDescriptor.fromJson({
        'scheme': 'X-Matrix',
        'origin': 'example.test',
        'destination': 'remote.example.test',
        'key': 'rsa:auto1',
        'sig': 'signature',
        'signed_json_fields': ['method'],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationVersion.fromJson({
        'server': {'name': '', 'version': '0.1.0'},
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationRequestAuthDescriptor.fromJson({
        'scheme': 'X-Matrix',
        'origin': '.example.test',
        'destination': 'remote.example.test',
        'key': 'ed25519:auto1',
        'sig': 'signature',
        'signed_json_fields': ['method'],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationRequestAuthDescriptor.fromJson({
        'scheme': 'X-Matrix',
        'origin': 'example.test',
        'destination': 'remote.example.test:not-a-port',
        'key': 'ed25519:auto1',
        'sig': 'signature',
        'signed_json_fields': ['method'],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationRequestAuthDescriptor.fromJson({
        'scheme': 'X-Matrix',
        'origin': 'example.test',
        'destination': 'remote.example.test',
        'key': 'ed25519:auto1',
        'sig': 'signature',
        'signed_json_fields': <String>[],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
