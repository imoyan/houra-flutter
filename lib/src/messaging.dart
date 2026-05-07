import 'models.dart';
import 'transport.dart';

const String okakaTextMessageType = 'chawan.text';

/// Messaging endpoints for the Chawan messaging profile.
final class OkakaMessagingClient {
  const OkakaMessagingClient(this._transport);

  final OkakaTransport _transport;

  Future<String> sendTextMessage({
    required String accessToken,
    required String roomId,
    required String clientTransactionId,
    required String body,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: ['_chawan', 'client', 'rooms', roomId, 'messages'],
        accessToken: accessToken,
        body: {
          'client_transaction_id': clientTransactionId,
          'msgtype': okakaTextMessageType,
          'body': body,
        },
      ),
    );
    return OkakaSendMessageResponse.fromJson(response.jsonObject).eventId;
  }
}
