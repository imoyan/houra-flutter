import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('sendTextMessage follows SPEC-008 vector', () async {
    final vector = readVector('test-vectors/messaging/send-text-basic.json');
    final requestBody = objectFrom(vector.request, 'body');

    late http.Request observed;
    final client = HouraClient(
      serverBaseUri: Uri.parse('https://example.test'),
      httpClient: MockClient((request) async {
        observed = request;
        return http.Response(jsonEncode(vector.bodyContains), 200);
      }),
    );

    final eventId = await client.messaging.sendTextMessage(
      accessToken: vector.request['access_token'] as String,
      roomId: '!room:example.test',
      clientTransactionId: requestBody['client_transaction_id'] as String,
      body: requestBody['body'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-1');
    expect(jsonDecode(observed.body), requestBody);
    expect(eventId, vector.bodyContains['event_id']);
  });

  test('send response parser rejects malformed responses', () {
    expect(
      () => HouraSendMessageResponse.fromJson({'event_id': ''}),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
