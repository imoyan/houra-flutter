import 'package:http/http.dart' as http;

import 'auth.dart';
import 'device_keys.dart';
import 'discovery.dart';
import 'media.dart';
import 'messaging.dart';
import 'rooms.dart';
import 'sync.dart';
import 'transport.dart';

/// Root client for Houra API calls.
final class HouraClient {
  /// Creates a client for a single Houra server base URI.
  ///
  /// [serverBaseUri] must use `http` or `https` and include a host. If
  /// [httpClient] is omitted, this client creates and owns an HTTP client that
  /// is closed by [close]. If [httpClient] is provided, the host keeps ownership
  /// and must close it. [requestTimeout] bounds each SDK request.
  HouraClient({
    required Uri serverBaseUri,
    http.Client? httpClient,
    Duration requestTimeout = const Duration(seconds: 60),
  }) : _transport = HouraTransport(
          serverBaseUri: serverBaseUri,
          httpClient: httpClient,
          requestTimeout: requestTimeout,
        );

  final HouraTransport _transport;

  /// Discovery endpoints for server version and feature metadata.
  HouraDiscoveryClient get discovery => HouraDiscoveryClient(_transport);

  /// Auth endpoints for login flows, sessions, and token validation.
  HouraAuthClient get auth => HouraAuthClient(_transport);

  /// Matrix public device-key query endpoints.
  HouraDeviceKeysClient get deviceKeys => HouraDeviceKeysClient(_transport);

  /// Room creation, membership, and state endpoints.
  HouraRoomsClient get rooms => HouraRoomsClient(_transport);

  /// Text-message send endpoints.
  HouraMessagingClient get messaging => HouraMessagingClient(_transport);

  /// Room list, timeline, and incremental sync endpoints.
  HouraSyncClient get sync => HouraSyncClient(_transport);

  /// Media metadata and base64 upload endpoints.
  HouraMediaClient get media => HouraMediaClient(_transport);

  /// Releases the owned HTTP client, if this client created one.
  void close() {
    _transport.close();
  }
}
