import 'models.dart';
import 'transport.dart';

const String houraPasswordLoginType = 'ichigo.login.password';
const String houraUserIdentifierType = 'ichigo.id.user';

/// Auth endpoints for the Ichi-Go auth profile.
final class HouraAuthClient {
  const HouraAuthClient(this._transport);

  final HouraTransport _transport;

  /// Fetches SPEC-003 supported login flows.
  Future<HouraLoginFlows> fetchLoginFlows() async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_ichi-go', 'client', 'login'],
      ),
    );
    return HouraLoginFlows.fromJson(response.jsonObject);
  }

  /// Performs SPEC-004 password login.
  Future<HouraAuthSession> loginWithPassword({
    required String username,
    required String password,
    String? deviceId,
    String? initialDeviceDisplayName,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_ichi-go', 'client', 'login'],
        body: {
          'type': houraPasswordLoginType,
          'identifier': {
            'type': houraUserIdentifierType,
            'user': username,
          },
          'password': password,
          if (deviceId != null) 'device_id': deviceId,
          if (initialDeviceDisplayName != null)
            'initial_device_display_name': initialDeviceDisplayName,
        },
      ),
    );
    return HouraAuthSession.fromJson(response.jsonObject);
  }

  /// Validates an access token and returns the current user identity.
  Future<HouraWhoami> whoami({required String accessToken}) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_ichi-go', 'client', 'account', 'whoami'],
        accessToken: accessToken,
      ),
    );
    return HouraWhoami.fromJson(response.jsonObject);
  }

  /// Logs out the current token. Token persistence remains host-owned.
  Future<void> logout({required String accessToken}) async {
    await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_ichi-go', 'client', 'logout'],
        accessToken: accessToken,
      ),
    );
  }
}
