import 'models.dart';
import 'transport.dart';

const String okakaPasswordLoginType = 'chawan.login.password';
const String okakaUserIdentifierType = 'chawan.id.user';

/// Auth endpoints for the Chawan auth profile.
final class OkakaAuthClient {
  const OkakaAuthClient(this._transport);

  final OkakaTransport _transport;

  /// Fetches SPEC-003 supported login flows.
  Future<OkakaLoginFlows> fetchLoginFlows() async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: const ['_chawan', 'client', 'login'],
      ),
    );
    return OkakaLoginFlows.fromJson(response.jsonObject);
  }

  /// Performs SPEC-004 password login.
  Future<OkakaAuthSession> loginWithPassword({
    required String username,
    required String password,
    String? deviceId,
    String? initialDeviceDisplayName,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: const ['_chawan', 'client', 'login'],
        body: {
          'type': okakaPasswordLoginType,
          'identifier': {
            'type': okakaUserIdentifierType,
            'user': username,
          },
          'password': password,
          if (deviceId != null) 'device_id': deviceId,
          if (initialDeviceDisplayName != null)
            'initial_device_display_name': initialDeviceDisplayName,
        },
      ),
    );
    return OkakaAuthSession.fromJson(response.jsonObject);
  }

  /// Validates an access token and returns the current user identity.
  Future<OkakaWhoami> whoami({required String accessToken}) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: const ['_chawan', 'client', 'account', 'whoami'],
        accessToken: accessToken,
      ),
    );
    return OkakaWhoami.fromJson(response.jsonObject);
  }

  /// Logs out the current token. Token persistence remains host-owned.
  Future<void> logout({required String accessToken}) async {
    await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: const ['_chawan', 'client', 'logout'],
        accessToken: accessToken,
      ),
    );
  }
}
