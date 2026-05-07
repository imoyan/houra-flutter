import 'models.dart';
import 'transport.dart';

/// Discovery client for the Ichi-Go core profile.
final class HouraDiscoveryClient {
  const HouraDiscoveryClient(this._transport);

  final HouraTransport _transport;

  /// Fetches SPEC-001 server discovery metadata.
  Future<HouraServerVersions> fetchVersions() async {
    final json = await _transport.getJsonObject(
      const ['_ichi-go', 'client', 'versions'],
    );
    return HouraServerVersions.fromJson(json);
  }
}
