import 'models.dart';
import 'transport.dart';

/// Room endpoints for the Chawan rooms profile.
final class OkakaRoomsClient {
  const OkakaRoomsClient(this._transport);

  final OkakaTransport _transport;

  Future<OkakaRoom> createRoom({
    required String accessToken,
    String? name,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: const ['_chawan', 'client', 'rooms'],
        accessToken: accessToken,
        body: {
          if (name != null) 'name': name,
        },
      ),
    );
    return OkakaRoom.fromJson(response.jsonObject);
  }

  Future<OkakaRoom> joinRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: ['_chawan', 'client', 'rooms', roomId, 'join'],
        accessToken: accessToken,
      ),
    );
    return OkakaRoom.fromJson(response.jsonObject);
  }

  Future<OkakaRoom> leaveRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: ['_chawan', 'client', 'rooms', roomId, 'leave'],
        accessToken: accessToken,
      ),
    );
    return OkakaRoom.fromJson(response.jsonObject);
  }

  Future<OkakaRoomState> getRoomState({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: ['_chawan', 'client', 'rooms', roomId, 'state'],
        accessToken: accessToken,
      ),
    );
    return OkakaRoomState.fromJson(response.jsonObject);
  }
}
