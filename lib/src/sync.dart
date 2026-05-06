import 'models.dart';
import 'transport.dart';

/// Host-owned persistence for sync tokens.
abstract interface class OkakaSyncTokenStore {
  Future<String?> read();

  Future<void> write(String token);
}

/// In-memory token store for tests and demos.
final class OkakaMemorySyncTokenStore implements OkakaSyncTokenStore {
  OkakaMemorySyncTokenStore([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    _token = token;
  }
}

/// Sync endpoints for room lists, timelines, and incremental sync.
final class OkakaSyncClient {
  const OkakaSyncClient(this._transport);

  final OkakaTransport _transport;

  Future<OkakaRoomList> listRooms({required String accessToken}) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: const ['_chawan', 'client', 'rooms'],
        accessToken: accessToken,
      ),
    );
    return OkakaRoomList.fromJson(response.jsonObject);
  }

  Future<OkakaTimelinePage> getTimeline({
    required String accessToken,
    required String roomId,
    String? from,
    int? limit,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: ['_chawan', 'client', 'rooms', roomId, 'timeline'],
        accessToken: accessToken,
        queryParameters: {
          if (from != null) 'from': from,
          if (limit != null) 'limit': '$limit',
        },
      ),
    );
    return OkakaTimelinePage.fromJson(response.jsonObject);
  }

  Future<OkakaSyncBatch> sync({
    required String accessToken,
    String? since,
    Duration? timeout,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: const ['_chawan', 'client', 'sync'],
        accessToken: accessToken,
        queryParameters: {
          if (since != null) 'since': since,
          if (timeout != null) 'timeout': '${timeout.inMilliseconds}',
        },
      ),
    );
    return OkakaSyncBatch.fromJson(response.jsonObject);
  }

  Future<OkakaSyncBatch> pollOnce({
    required String accessToken,
    required OkakaSyncTokenStore tokenStore,
    Duration? timeout,
  }) async {
    final batch = await sync(
      accessToken: accessToken,
      since: await tokenStore.read(),
      timeout: timeout,
    );
    await tokenStore.write(batch.nextBatch);
    return batch;
  }
}
