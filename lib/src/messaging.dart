import 'errors.dart';
import 'models.dart';
import 'transport.dart';

const String houraTextMessageType = 'houra.text';

/// Messaging endpoints for the Houra messaging profile.
final class HouraMessagingClient {
  const HouraMessagingClient(this._transport);

  final HouraTransport _transport;

  Future<String> sendTextMessage({
    required String accessToken,
    required String roomId,
    required String clientTransactionId,
    required String body,
  }) async {
    if (clientTransactionId.isEmpty) {
      throw const HouraTransportException(
        'clientTransactionId must be non-empty.',
      );
    }
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: ['_houra', 'client', 'rooms', roomId, 'messages'],
        accessToken: accessToken,
        body: {
          'client_transaction_id': clientTransactionId,
          'msgtype': houraTextMessageType,
          'body': body,
        },
      ),
    );
    return HouraSendMessageResponse.fromJson(response.jsonObject).eventId;
  }
}
