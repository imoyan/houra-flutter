import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix Identity Service parser helpers follow SPEC-059 vectors', () {
    final boundary = readVector(
      'test-vectors/core/matrix-identity-service-boundary-basic.json',
    );
    expect(boundary.raw['contract'], 'SPEC-059');

    final boundaryEvent = objectFrom(boundary.raw, 'event');
    final endpoints = boundaryEvent['endpoints'] as List<Object?>;
    expect(endpoints, contains('GET /_matrix/identity/versions'));
    expect(boundary.expected['versions_advertisement_widened'], isFalse);

    final hashLookup = readVector(
      'test-vectors/core/matrix-identity-lookup-hash-details-basic.json',
    );
    final hashEvent = objectFrom(hashLookup.raw, 'event');
    final hashRequest = HouraMatrixIdentityRequestDescriptor.fromJson(
      objectFrom(hashEvent, 'hash_details_request'),
    );
    expect(hashRequest.path, '/_matrix/identity/v2/hash_details');
    expect(hashRequest.authorizationScheme, 'Bearer');

    final hashResponse = HouraMatrixIdentityHashDetails.fromJson(
      objectFrom(objectFrom(hashEvent, 'hash_details_response'), 'body'),
    );
    expect(hashResponse.algorithms, contains('sha256'));

    final lookupRequest = HouraMatrixIdentityRequestDescriptor.fromJson(
      objectFrom(hashEvent, 'lookup_request'),
    );
    expect(lookupRequest.body['algorithm'], 'sha256');

    final lookupResponse = HouraMatrixIdentityLookupResponse.fromJson(
      objectFrom(objectFrom(hashEvent, 'lookup_response'), 'body'),
    );
    expect(lookupResponse.mappings['sha256-address-redacted'],
        '@alice:example.test');

    final validationBind = readVector(
      'test-vectors/core/matrix-identity-validation-bind-basic.json',
    );
    final validationEvent = objectFrom(validationBind.raw, 'event');
    final validationSteps =
        validationEvent['validation_steps'] as List<Object?>;
    final requestToken = validationSteps.first as Map;
    final session = HouraMatrixIdentityValidationSession.fromJson(
      objectFrom(
          objectFrom(requestToken.cast<String, Object?>(), 'response'), 'body'),
    );
    expect(session.sid, 'sid-123');

    final getValidated = validationSteps[2] as Map;
    final validated = HouraMatrixIdentityValidatedThreePid.fromJson(
      objectFrom(
          objectFrom(getValidated.cast<String, Object?>(), 'response'), 'body'),
    );
    expect(validated.medium, 'email');

    final association = HouraMatrixIdentityAssociation.fromJson(
      objectFrom(objectFrom(validationEvent, 'bind_response'), 'body'),
    );
    expect(association.mxid, '@alice:example.test');
    expect(
        association.signatures['identity.example.test'], contains('ed25519:0'));

    final failures = objectFrom(
      readVector('test-vectors/core/matrix-identity-unbind-auth-failures.json')
          .raw,
      'event',
    )['failure_cases'] as List<Object?>;
    final parsedFailures = failures
        .map((item) => (item as Map).cast<String, Object?>())
        .map(HouraMatrixIdentityErrorEnvelope.fromJson)
        .toList();
    expect(parsedFailures.map((item) => item.errcode),
        containsAll(['M_UNAUTHORIZED', 'M_TERMS_NOT_SIGNED']));
  });

  test('Matrix Identity Service full-breadth evidence stays fail-closed', () {
    final vectors = [
      readVector(
        'test-vectors/core/matrix-identity-bind-unbind-lifecycle-boundary.json',
      ),
      readVector(
        'test-vectors/core/matrix-identity-validation-provider-delivery-boundary.json',
      ),
      readVector(
        'test-vectors/core/matrix-identity-public-key-signature-boundary.json',
      ),
    ];

    for (final vector in vectors) {
      final event = objectFrom(vector.raw, 'event');
      final cases = event['cases'] as List<Object?>;
      final parsedCases = cases
          .map((item) => (item as Map).cast<String, Object?>())
          .map(HouraMatrixIdentityEvidenceCase.fromJson)
          .toList();
      expect(parsedCases, hasLength(vector.expected['case_count']));
      expect(
        parsedCases.where((item) => item.result == 'accepted'),
        hasLength(vector.expected['accepted_case_count']),
      );
      expect(
          parsedCases.every(
              (item) => item.request.path.startsWith('/_matrix/identity/')),
          isTrue);
      expect(vector.expected['identity_service_full_breadth_claimed'], isFalse);
      expect(vector.expected['versions_advertisement_widened'], isFalse);
    }

    final inventory = readVector(
      'test-vectors/core/matrix-identity-service-full-breadth-gap-inventory.json',
    );
    expect(inventory.raw['contract'], 'SPEC-076');
    expect(inventory.expected['support_claim_not_widened'], isTrue);
    expect(inventory.expected['follow_up_required'], isTrue);

    final redacted = const HouraMatrixIdentityEvidenceRedactor().redact({
      'identity_token': 'raw-token',
      'nested': {
        'client_secret': 'raw-secret',
        'provider_log': 'raw-log',
      },
      'kept': 'metadata',
    });
    expect(redacted['identity_token'], 'identity-redacted');
    expect((redacted['nested']! as Map)['client_secret'], 'identity-redacted');
    expect((redacted['nested']! as Map)['provider_log'], 'identity-redacted');
    expect(redacted['kept'], 'metadata');
  });

  test('Matrix Identity Service parser helpers reject malformed inputs', () {
    expect(
      () => HouraMatrixIdentityRequestDescriptor.fromJson({
        'method': 'DELETE',
        'path': '/_matrix/identity/v2/account',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixIdentityRequestDescriptor.fromJson({
        'method': 'GET',
        'path': '/_matrix/client/v3/account',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixIdentityHashDetails.fromJson({
        'algorithms': ['none'],
        'lookup_pepper': 'pepper-redacted',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixIdentityAssociation.fromJson({
        'address': 'alice@example.test',
        'medium': 'email',
        'mxid': 'alice:example.test',
        'not_after': 1,
        'not_before': 2,
        'signatures': <String, Object?>{},
        'ts': 1,
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
