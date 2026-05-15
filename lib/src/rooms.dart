import 'models.dart';
import 'transport.dart';

/// Room endpoints for the Houra rooms profile.
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
        pathSegments: const ['_houra', 'client', 'rooms'],
        accessToken: accessToken,
        body: {if (name != null) 'name': name},
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
        pathSegments: ['_houra', 'client', 'rooms', roomId, 'join'],
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
        pathSegments: ['_houra', 'client', 'rooms', roomId, 'leave'],
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
        pathSegments: ['_houra', 'client', 'rooms', roomId, 'state'],
        accessToken: accessToken,
      ),
    );
    return HouraRoomState.fromJson(response.jsonObject);
  }

  /// Fetches one Matrix room event by event id.
  ///
  /// This is SPEC-085 parser/request descriptor support only. History
  /// visibility, authorization, storage lookup, and deprecated endpoint
  /// compatibility remain server-owned and are not inferred by this SDK helper.
  Future<HouraMatrixClientEvent> getMatrixRoomEvent({
    required String accessToken,
    required String roomId,
    required String eventId,
  }) async {
    _validateMatrixRoomId(roomId);
    _validateMatrixEventId(eventId);
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'rooms',
          roomId,
          'event',
          eventId,
        ],
        accessToken: accessToken,
      ),
    );
    return HouraMatrixClientEvent.fromJson(response.jsonObject);
  }

  /// Fetches joined member profile fields for a Matrix room.
  ///
  /// This is SPEC-085 parser/request descriptor support only. Membership
  /// visibility and room authorization remain server-owned.
  Future<HouraMatrixJoinedMembers> getMatrixJoinedMembers({
    required String accessToken,
    required String roomId,
  }) async {
    _validateMatrixRoomId(roomId);
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'rooms',
          roomId,
          'joined_members',
        ],
        accessToken: accessToken,
      ),
    );
    return HouraMatrixJoinedMembers.fromJson(response.jsonObject);
  }

  /// Fetches Matrix membership history for a room.
  ///
  /// This is SPEC-085 parser/request descriptor support only. Pagination,
  /// visibility, and storage lookup semantics remain outside this SDK helper.
  Future<HouraMatrixMembers> getMatrixMembers({
    required String accessToken,
    required String roomId,
    String? at,
    String? membership,
    String? notMembership,
  }) async {
    _validateMatrixRoomId(roomId);
    final query = {
      if (at != null) 'at': _requireNonEmpty(at, 'at'),
      if (membership != null)
        'membership': _validateMatrixMembershipFilter(membership),
      if (notMembership != null)
        'not_membership': _validateMatrixMembershipFilter(notMembership),
    };
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: ['_matrix', 'client', 'v3', 'rooms', roomId, 'members'],
        accessToken: accessToken,
        queryParameters: query,
      ),
    );
    return HouraMatrixMembers.fromJson(response.jsonObject);
  }

  /// Resolves the closest Matrix event for a room timestamp.
  ///
  /// This is SPEC-085 parser/request descriptor support only. Event ordering
  /// and room-version visibility decisions remain outside this helper.
  Future<HouraMatrixTimestampToEvent> matrixTimestampToEvent({
    required String accessToken,
    required String roomId,
    required int timestamp,
    required String direction,
  }) async {
    _validateMatrixRoomId(roomId);
    if (timestamp < 0) {
      throw ArgumentError.value(timestamp, 'timestamp', 'must be non-negative');
    }
    if (direction != 'f' && direction != 'b') {
      throw ArgumentError.value(direction, 'direction', 'must be "f" or "b"');
    }
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: [
          '_matrix',
          'client',
          'v1',
          'rooms',
          roomId,
          'timestamp_to_event',
        ],
        accessToken: accessToken,
        queryParameters: {'ts': '$timestamp', 'dir': direction},
      ),
    );
    return HouraMatrixTimestampToEvent.fromJson(response.jsonObject);
  }
}

void _validateMatrixRoomId(String roomId) {
  if (_hasMatrixSigilAndServer(roomId, '!')) {
    return;
  }
  throw ArgumentError.value(roomId, 'roomId', 'must be a Matrix room id');
}

void _validateMatrixEventId(String eventId) {
  if (_hasMatrixSigilAndServer(eventId, r'$')) {
    return;
  }
  throw ArgumentError.value(eventId, 'eventId', 'must be a Matrix event id');
}

bool _hasMatrixSigilAndServer(String value, String sigil) {
  if (!value.startsWith(sigil)) {
    return false;
  }
  final colonIndex = value.lastIndexOf(':');
  return colonIndex > sigil.length && colonIndex < value.length - 1;
}

String _requireNonEmpty(String value, String name) {
  if (value.isNotEmpty) {
    return value;
  }
  throw ArgumentError.value(value, name, 'must be non-empty');
}

String _validateMatrixMembershipFilter(String membership) {
  const allowed = {'invite', 'join', 'knock', 'leave', 'ban'};
  if (allowed.contains(membership)) {
    return membership;
  }
  throw ArgumentError.value(
    membership,
    'membership',
    'must be one of ${allowed.join(', ')}',
  );
}
