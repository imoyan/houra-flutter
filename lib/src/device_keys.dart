import 'errors.dart';
import 'models.dart';
import 'transport.dart';

/// Matrix device-key query endpoints for the Houra auth profile.
final class HouraDeviceKeysClient {
  const HouraDeviceKeysClient(this._transport);

  final HouraTransport _transport;

  /// Queries public Matrix device keys for selected users and devices.
  ///
  /// This implements the SPEC-069 request descriptor and response parser only.
  /// Access-token persistence, transport retry, signature verification, trust
  /// UI, secure storage, and Olm/Megolm sessions remain host-owned.
  Future<HouraDeviceKeyQueryResponse> queryDeviceKeys({
    required String accessToken,
    required Map<String, List<String>> deviceKeys,
    int? timeoutMs,
    String? syncToken,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_matrix', 'client', 'v3', 'keys', 'query'],
        accessToken: accessToken,
        body: _deviceKeyQueryBody(
          deviceKeys: deviceKeys,
          timeoutMs: timeoutMs,
          syncToken: syncToken,
        ),
      ),
    );
    return HouraDeviceKeyQueryResponse.fromJson(response.jsonObject);
  }
}

Map<String, Object?> _deviceKeyQueryBody({
  required Map<String, List<String>> deviceKeys,
  int? timeoutMs,
  String? syncToken,
}) {
  if (deviceKeys.isEmpty) {
    throw HouraTransportException('deviceKeys must not be empty.');
  }
  if (timeoutMs != null && timeoutMs < 0) {
    throw HouraTransportException('timeoutMs must be non-negative.');
  }
  if (syncToken != null && syncToken.isEmpty) {
    throw HouraTransportException('syncToken must be non-empty.');
  }

  final bodyDeviceKeys = <String, Object?>{};
  for (final entry in deviceKeys.entries) {
    if (entry.key.isEmpty) {
      throw HouraTransportException('deviceKeys user ids must be non-empty.');
    }
    bodyDeviceKeys[entry.key] = List<String>.unmodifiable(
      entry.value.map((deviceId) {
        if (deviceId.isEmpty) {
          throw HouraTransportException('device ids must be non-empty.');
        }
        return deviceId;
      }),
    );
  }

  return {
    'device_keys': bodyDeviceKeys,
    if (timeoutMs != null) 'timeout': timeoutMs,
    if (syncToken != null) 'token': syncToken,
  };
}
