import 'models.dart';
import 'transport.dart';

/// Host-owned persistence for sync tokens.
abstract interface class HouraSyncTokenStore {
  /// Reads the last persisted sync token, or `null` for an initial sync.
  Future<String?> read();

  /// Persists the next sync token returned by the server.
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

  /// Lists rooms visible to the current access token.
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

  /// Fetches a room timeline page.
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

  /// Performs one sync request.
  ///
  /// The SDK does not persist [since]. Hosts may pass a token from their own
  /// storage and persist the returned [HouraSyncBatch.nextBatch].
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

  /// Performs one sync request using an injected host-owned token store.
  ///
  /// This convenience method writes only through [tokenStore]; it does not add
  /// SDK-owned durable storage.
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

  /// Performs one Matrix Client-Server sync request.
  ///
  /// This parser surface is for SPEC-052 to-device envelope delivery. Host
  /// applications still own sync token persistence and decryption.
  Future<HouraMatrixSyncBatch> matrixSync({
    required String accessToken,
    String? since,
    Duration? timeout,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_matrix', 'client', 'v3', 'sync'],
        accessToken: accessToken,
        queryParameters: {
          if (since != null) 'since': since,
          if (timeout != null) 'timeout': '${timeout.inMilliseconds}',
        },
      ),
    );
    return HouraMatrixSyncBatch.fromJson(response.jsonObject);
  }
}
