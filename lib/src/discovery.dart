import 'models.dart';
import 'transport.dart';

/// Discovery client for the Chawan core profile.
final class OkakaDiscoveryClient {
  const OkakaDiscoveryClient(this._transport);

  final OkakaTransport _transport;

  /// Fetches SPEC-001 server discovery metadata.
  Future<OkakaServerVersions> fetchVersions() async {
    final json = await _transport.getJsonObject(
      const ['_chawan', 'client', 'versions'],
    );
    return OkakaServerVersions.fromJson(json);
  }
}
