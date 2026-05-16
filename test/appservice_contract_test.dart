import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix Application Service parser helpers follow SPEC-058 vectors', () {
    final registrationVector = readVector(
      'test-vectors/core/matrix-appservice-registration-basic.json',
    );
    expect(registrationVector.raw['contract'], 'SPEC-058');

    final registrationEvent = objectFrom(registrationVector.raw, 'event');
    final registration = HouraMatrixApplicationServiceRegistration.fromJson(
      objectFrom(registrationEvent, 'registration'),
    );
    expect(registration.id, 'irc-bridge');
    expect(registration.url, Uri.parse('https://appservice.example.test'));
    expect(registration.asToken, isNot(registration.hsToken));
    expect(registration.senderUserId('example.test'), '@_irc_bot:example.test');
    expect(
      registration.namespaces.users.single.matches(
        '@_irc_bridge_alice:example.test',
      ),
      isTrue,
    );
    expect(registration.namespaces.aliases.single.exclusive, isTrue);

    final namespaceVector = readVector(
      'test-vectors/core/matrix-appservice-namespace-ownership.json',
    );
    final namespaceEvent = objectFrom(namespaceVector.raw, 'event');
    final namespaces = HouraMatrixApplicationServiceNamespaces.fromJson(
      objectFrom(namespaceEvent, 'namespaces'),
    );
    expect(namespaces.users.single.exclusive, isTrue);
    expect(namespaces.rooms.single.exclusive, isFalse);

    final transactionVector = readVector(
      'test-vectors/core/matrix-appservice-transaction-basic.json',
    );
    final transaction = HouraMatrixApplicationServiceTransaction.fromJson(
      transactionVector.request,
    );
    expect(transaction.transactionId, 'txn-1');
    expect(transaction.events.single.type, 'm.room.message');
    expect(transaction.ephemeral.single.type, 'm.typing');
    expect(
        transactionVector.expected['versions_advertisement_widened'], isFalse);

    final queryVector = readVector(
      'test-vectors/core/matrix-appservice-query-user-room-basic.json',
    );
    final queryEvent = objectFrom(queryVector.raw, 'event');
    final queries = queryEvent['queries'] as List<Object?>;
    final parsedQueries = queries
        .map((item) => (item as Map).cast<String, Object?>())
        .map(HouraMatrixApplicationServiceQueryDescriptor.fromJson)
        .toList();
    expect(parsedQueries, hasLength(2));
    expect(parsedQueries.map((item) => item.authorizationScheme),
        everyElement('Bearer'));
    expect(queryVector.expected['queries_limited_to_namespaces'], isTrue);
  });

  test('Matrix Application Service full-breadth inventory stays fail-closed',
      () {
    final inventory = readVector(
      'test-vectors/core/matrix-application-service-full-breadth-gap-inventory.json',
    );
    expect(inventory.raw['contract'], 'SPEC-075');

    final event = objectFrom(inventory.raw, 'event');
    final lanes = event['required_gap_lanes'] as List<Object?>;
    final parsedLanes = lanes
        .map((item) => (item as Map).cast<String, Object?>())
        .map(HouraMatrixApplicationServiceGapLane.fromJson)
        .toList();
    expect(parsedLanes, hasLength(8));
    expect(
      parsedLanes.map((item) => item.id),
      containsAll([
        'third-party-network-directory-breadth',
        'ping-health-liveness-breadth',
        'client-server-extension-masquerade-timestamp-admin-breadth',
      ]),
    );
    expect(parsedLanes.every((item) => !item.advertisementAllowed), isTrue);
    expect(inventory.expected['support_claim_not_widened'], isTrue);
    expect(inventory.expected['follow_up_required'], isTrue);

    final redacted =
        const HouraMatrixApplicationServiceEvidenceRedactor().redact({
      'as_token': 'raw-as-token',
      'nested': {
        'hs_token': 'raw-hs-token',
        'external_url': 'https://bridge.example.test/raw',
      },
      'kept': 'metadata',
    });
    expect(redacted['as_token'], 'appservice-redacted');
    expect((redacted['nested']! as Map)['hs_token'], 'appservice-redacted');
    expect((redacted['nested']! as Map)['external_url'], 'appservice-redacted');
    expect(redacted['kept'], 'metadata');
  });

  test('Matrix Application Service parser helpers reject malformed inputs', () {
    expect(
      () => HouraMatrixApplicationServiceRegistration.fromJson({
        'id': 'bad',
        'url': 'http://appservice.example.test',
        'as_token': 'same',
        'hs_token': 'same',
        'sender_localpart': '_bot',
        'namespaces': {
          'users': <Object?>[],
          'aliases': <Object?>[],
          'rooms': <Object?>[],
        },
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixApplicationServiceNamespace.fromJson({
        'exclusive': true,
        'regex': '[',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixApplicationServiceRequestDescriptor.fromJson({
        'method': 'DELETE',
        'path': '/_matrix/app/v1/users/@_irc_bridge_alice:example.test',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixApplicationServiceGapLane.fromJson({
        'id': 'bad-advertisement',
        'status': 'unsupported',
        'endpoint_examples': ['GET /_matrix/app/v1/thirdparty/user'],
        'owner_repos': ['houra-server'],
        'advertisement_allowed': true,
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixApplicationServiceNamespaces.fromJson({
        'users': List<Object?>.filled(33, {
          'exclusive': true,
          'regex': '@_irc_.*:example\\.test',
        }),
        'aliases': <Object?>[],
        'rooms': <Object?>[],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixApplicationServiceTransaction.fromJson({
        'method': 'PUT',
        'path': '/_matrix/app/v1/transactions/oversized',
        'body': {
          'events': List<Object?>.filled(101, {
            'type': 'm.room.message',
            'content': {'body': 'hello'},
          }),
        },
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => const HouraMatrixApplicationServiceEvidenceRedactor().redact({
        'items': List<Object?>.filled(65, 'metadata'),
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
