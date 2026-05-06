import 'package:http/http.dart' as http;

import 'auth.dart';
import 'discovery.dart';
import 'media.dart';
import 'messaging.dart';
import 'rooms.dart';
import 'sync.dart';
import 'transport.dart';

/// Root client for Chawan API calls.
final class OkakaClient {
  OkakaClient({
    required Uri serverBaseUri,
    http.Client? httpClient,
    Duration requestTimeout = const Duration(seconds: 60),
  }) : _transport = OkakaTransport(
          serverBaseUri: serverBaseUri,
          httpClient: httpClient,
          requestTimeout: requestTimeout,
        );

  final OkakaTransport _transport;

  /// Discovery endpoints for server version and feature metadata.
  OkakaDiscoveryClient get discovery => OkakaDiscoveryClient(_transport);

  /// Auth endpoints for login flows, sessions, and token validation.
  OkakaAuthClient get auth => OkakaAuthClient(_transport);

  /// Room creation, membership, and state endpoints.
  OkakaRoomsClient get rooms => OkakaRoomsClient(_transport);

  /// Text-message send endpoints.
  OkakaMessagingClient get messaging => OkakaMessagingClient(_transport);

  /// Room list, timeline, and incremental sync endpoints.
  OkakaSyncClient get sync => OkakaSyncClient(_transport);

  /// Media metadata and base64 upload endpoints.
  OkakaMediaClient get media => OkakaMediaClient(_transport);

  /// Releases the owned HTTP client, if this client created one.
  void close() {
    _transport.close();
  }
}
