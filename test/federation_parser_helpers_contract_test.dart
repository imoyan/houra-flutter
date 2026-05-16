import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix federation PDU/EDU parser helpers follow SPEC-099', () {
    final vector = readVector(
      'test-vectors/events/matrix-federation-pdu-edu-parser-helpers.json',
    );
    expect(vector.raw['contract'], 'SPEC-099');
    final event = objectFrom(vector.raw, 'event');

    final descriptor = HouraMatrixFederationRequestDescriptor.fromJson(
      objectFrom(event, 'request_descriptor'),
    );
    expect(
      descriptor.responseParser,
      'federation_transaction_response_descriptor',
    );
    expect(descriptor.adoptedRuntimeBehavior, isFalse);

    final transaction = HouraMatrixFederationTransaction.fromJson(
      objectFrom(event, 'sample_transaction'),
    );
    expect(transaction.pdus, hasLength(vector.expected['pdu_count']));
    expect(transaction.edus, hasLength(vector.expected['edu_count']));
    expect(
      transaction.pdus.single.signatures['remote.example.test'],
      contains('ed25519:auto1'),
    );
    expect(transaction.edus.first.eduType, 'm.typing');

    final canonical =
        HouraMatrixFederationCanonicalJsonInputDescriptor.fromJson(
      objectFrom(event, 'canonical_json_descriptor'),
    );
    expect(
      canonical.inputFields,
      hasLength(vector.expected['canonical_input_field_count']),
    );
    expect(canonical.hashCalculated, isFalse);
    expect(canonical.signatureVerified, isFalse);
    expect(canonical.privateKeyPresent, isFalse);

    final response = HouraMatrixFederationTransactionResponse.fromJson(
      objectFrom(event, 'sample_response'),
    );
    expect(response.pdus[r'$event1:remote.example.test']?.error, isNull);
    expect(
      response.pdus[r'$bad:remote.example.test']?.error,
      'Event failed authorization',
    );

    final tooManyPdus = Map<String, Object?>.from(
      objectFrom(event, 'sample_transaction'),
    );
    tooManyPdus['pdus'] = List<Object?>.filled(51, transaction.pdus.single.raw);
    expect(
      () => HouraMatrixFederationTransaction.fromJson(tooManyPdus),
      throwsA(isA<HouraResponseFormatException>()),
    );

    final missingSignatures = Map<String, Object?>.from(
      objectFrom(event, 'sample_transaction'),
    );
    missingSignatures['pdus'] = [
      {
        ...transaction.pdus.single.raw,
      }..remove('signatures'),
    ];
    expect(
      () => HouraMatrixFederationTransaction.fromJson(missingSignatures),
      throwsA(isA<HouraResponseFormatException>()),
    );

    final invalidKeyId = Map<String, Object?>.from(
      objectFrom(event, 'sample_transaction'),
    );
    invalidKeyId['pdus'] = [
      {
        ...transaction.pdus.single.raw,
        'signatures': {
          'remote.example.test': {'rsa:auto1': 'base64-event-signature'},
        },
      },
    ];
    expect(
      () => HouraMatrixFederationTransaction.fromJson(invalidKeyId),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test('Matrix federation directory/query/OpenID helpers follow SPEC-100', () {
    final vector = readVector(
      'test-vectors/core/matrix-federation-directory-query-openid-parser-helpers.json',
    );
    expect(vector.raw['contract'], 'SPEC-100');
    final event = objectFrom(vector.raw, 'event');
    final descriptors = (event['request_descriptors'] as List<Object?>)
        .map((descriptor) => (descriptor as Map).cast<String, Object?>())
        .map(HouraMatrixFederationRequestDescriptor.fromJson)
        .toList();
    expect(descriptors, hasLength(vector.expected['descriptor_count']));
    expect(
      descriptors.map((descriptor) => descriptor.responseParser),
      containsAll([
        'federation_public_rooms_response',
        'federation_hierarchy_response',
        'federation_directory_query_response',
        'federation_profile_query_response',
        'federation_openid_userinfo_response',
      ]),
    );

    final responses = objectFrom(event, 'sample_responses');
    final publicRooms = HouraMatrixFederationPublicRoomsResponse.fromJson(
      objectFrom(responses, 'public_rooms'),
    );
    expect(publicRooms.chunk, hasLength(vector.expected['public_room_count']));
    expect(publicRooms.nextBatch, 'token-b');

    final hierarchy = HouraMatrixFederationHierarchyResponse.fromJson(
      objectFrom(responses, 'hierarchy'),
    );
    expect(hierarchy.rooms, hasLength(vector.expected['hierarchy_room_count']));
    expect(
      hierarchy.rooms.single.childrenState,
      hasLength(vector.expected['children_state_count']),
    );

    final directory = HouraMatrixFederationDirectoryQueryResponse.fromJson(
      objectFrom(responses, 'directory_query'),
    );
    expect(
      directory.servers,
      hasLength(vector.expected['directory_server_count']),
    );

    final profile = HouraMatrixFederationProfileQueryResponse.fromJson(
      objectFrom(responses, 'profile_query'),
    );
    expect(profile.displayName, 'Alice');

    final generic = HouraMatrixFederationGenericQueryResponse.fromJson(
      objectFrom(responses, 'generic_query'),
    );
    expect(generic.responseObjectPresent, isTrue);

    final openId = HouraMatrixFederationOpenIdUserinfoResponse.fromJson(
      objectFrom(responses, 'openid_userinfo'),
    );
    expect(openId.subject, vector.expected['openid_subject']);

    expect(
      () => HouraMatrixFederationPublicRoomsResponse.fromJson({}),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationHierarchyResponse.fromJson({
        'rooms': [
          {
            'room_id': '!space:example.test',
            'num_joined_members': -1,
            'world_readable': true,
            'guest_can_join': false,
          },
        ],
        'inaccessible_children': <String>[],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationDirectoryQueryResponse.fromJson({
        'room_id': '!room:example.test',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixFederationOpenIdUserinfoResponse.fromJson({}),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
