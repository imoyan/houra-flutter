import 'errors.dart';
import 'models.dart';
import 'transport.dart';

const String houraTextMessageType = 'houra.text';
const String matrixEncryptedEventType = 'm.room.encrypted';
const String matrixRoomEncryptionEventType = 'm.room.encryption';
const String matrixMegolmAlgorithm = 'm.megolm.v1.aes-sha2';

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

  /// Sends Matrix encrypted to-device payload envelopes.
  ///
  /// This is SPEC-052 request descriptor support only. Payload encryption,
  /// device trust, retry policy, and Olm session lifecycle remain host-owned.
  Future<void> sendEncryptedToDevice({
    required String accessToken,
    required String clientTransactionId,
    required Map<String, Map<String, HouraEncryptedPayload>> messages,
  }) async {
    if (clientTransactionId.isEmpty) {
      throw const HouraTransportException(
        'clientTransactionId must be non-empty.',
      );
    }
    await _transport.send(
      HouraRequest(
        method: 'PUT',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'sendToDevice',
          matrixEncryptedEventType,
          clientTransactionId,
        ],
        accessToken: accessToken,
        body: {'messages': _toDeviceMessagesBody(messages)},
      ),
    );
  }

  /// Sends the Matrix room encryption state event descriptor.
  Future<String> setRoomEncryption({
    required String accessToken,
    required String roomId,
    int? rotationPeriodMs,
    int? rotationPeriodMsgs,
  }) async {
    _validateMatrixRoomId(roomId);
    _validateOptionalNonNegative(rotationPeriodMs, 'rotationPeriodMs');
    _validateOptionalNonNegative(rotationPeriodMsgs, 'rotationPeriodMsgs');
    final response = await _transport.send(
      HouraRequest(
        method: 'PUT',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'rooms',
          roomId,
          'state',
          matrixRoomEncryptionEventType,
          '',
        ],
        accessToken: accessToken,
        body: {
          'algorithm': matrixMegolmAlgorithm,
          if (rotationPeriodMs != null) 'rotation_period_ms': rotationPeriodMs,
          if (rotationPeriodMsgs != null)
            'rotation_period_msgs': rotationPeriodMsgs,
        },
      ),
    );
    return HouraSendMessageResponse.fromJson(response.jsonObject).eventId;
  }

  /// Sends a Matrix encrypted room event envelope.
  ///
  /// The SDK validates and serializes the public envelope only. It does not
  /// encrypt, decrypt, verify, or store room sessions.
  Future<String> sendEncryptedRoomEvent({
    required String accessToken,
    required String roomId,
    required String clientTransactionId,
    required HouraEncryptedPayload payload,
  }) async {
    _validateMatrixRoomId(roomId);
    if (clientTransactionId.isEmpty) {
      throw const HouraTransportException(
        'clientTransactionId must be non-empty.',
      );
    }
    final response = await _transport.send(
      HouraRequest(
        method: 'PUT',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'rooms',
          roomId,
          'send',
          matrixEncryptedEventType,
          clientTransactionId,
        ],
        accessToken: accessToken,
        body: payload.toJson(),
      ),
    );
    return HouraSendMessageResponse.fromJson(response.jsonObject).eventId;
  }
}

Map<String, Object?> _toDeviceMessagesBody(
  Map<String, Map<String, HouraEncryptedPayload>> messages,
) {
  if (messages.isEmpty) {
    throw const HouraTransportException('messages must not be empty.');
  }
  final users = <String, Object?>{};
  for (final userEntry in messages.entries) {
    if (userEntry.key.isEmpty || userEntry.value.isEmpty) {
      throw const HouraTransportException(
        'messages user ids and device maps must be non-empty.',
      );
    }
    final devices = <String, Object?>{};
    for (final deviceEntry in userEntry.value.entries) {
      if (deviceEntry.key.isEmpty) {
        throw const HouraTransportException('device ids must be non-empty.');
      }
      devices[deviceEntry.key] = deviceEntry.value.toJson();
    }
    users[userEntry.key] = devices;
  }
  return users;
}

void _validateMatrixRoomId(String roomId) {
  if (roomId.isEmpty) {
    throw const HouraTransportException('roomId must be non-empty.');
  }
}

void _validateOptionalNonNegative(int? value, String name) {
  if (value != null && value < 0) {
    throw HouraTransportException('$name must be non-negative.');
  }
}
