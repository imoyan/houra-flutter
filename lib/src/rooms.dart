import 'models.dart';
import 'transport.dart';

/// Room endpoints for the Ichi-Go rooms profile.
final class HouraRoomsClient {
  const HouraRoomsClient(this._transport);

  final HouraTransport _transport;

  Future<HouraRoom> createRoom({
    required String accessToken,
    String? name,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_ichi-go', 'client', 'rooms'],
        accessToken: accessToken,
        body: {
          if (name != null) 'name': name,
        },
      ),
    );
    return HouraRoom.fromJson(response.jsonObject);
  }

  Future<HouraRoom> joinRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: ['_ichi-go', 'client', 'rooms', roomId, 'join'],
        accessToken: accessToken,
      ),
    );
    return HouraRoom.fromJson(response.jsonObject);
  }

  Future<HouraRoom> leaveRoom({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: ['_ichi-go', 'client', 'rooms', roomId, 'leave'],
        accessToken: accessToken,
      ),
    );
    return HouraRoom.fromJson(response.jsonObject);
  }

  Future<HouraRoomState> getRoomState({
    required String accessToken,
    required String roomId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: ['_ichi-go', 'client', 'rooms', roomId, 'state'],
        accessToken: accessToken,
      ),
    );
    return HouraRoomState.fromJson(response.jsonObject);
  }
}
