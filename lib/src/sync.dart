import 'models.dart';
import 'transport.dart';

/// Host-owned persistence for sync tokens.
abstract interface class HouraSyncTokenStore {
  Future<String?> read();

  Future<void> write(String token);
}

/// In-memory token store for tests and demos.
final class HouraMemorySyncTokenStore implements HouraSyncTokenStore {
  HouraMemorySyncTokenStore([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    _token = token;
  }
}

/// Sync endpoints for room lists, timelines, and incremental sync.
final class HouraSyncClient {
  const HouraSyncClient(this._transport);

  final HouraTransport _transport;

  Future<HouraRoomList> listRooms({required String accessToken}) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_houra', 'client', 'rooms'],
        accessToken: accessToken,
      ),
    );
    return HouraRoomList.fromJson(response.jsonObject);
  }

  Future<HouraTimelinePage> getTimeline({
    required String accessToken,
    required String roomId,
    String? from,
    int? limit,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: ['_houra', 'client', 'rooms', roomId, 'timeline'],
        accessToken: accessToken,
        queryParameters: {
          if (from != null) 'from': from,
          if (limit != null) 'limit': '$limit',
        },
      ),
    );
    return HouraTimelinePage.fromJson(response.jsonObject);
  }

  Future<HouraSyncBatch> sync({
    required String accessToken,
    String? since,
    Duration? timeout,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_houra', 'client', 'sync'],
        accessToken: accessToken,
        queryParameters: {
          if (since != null) 'since': since,
          if (timeout != null) 'timeout': '${timeout.inMilliseconds}',
        },
      ),
    );
    return HouraSyncBatch.fromJson(response.jsonObject);
  }

  Future<HouraSyncBatch> pollOnce({
    required String accessToken,
    required HouraSyncTokenStore tokenStore,
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
