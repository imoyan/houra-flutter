import 'errors.dart';
import 'models.dart';
import 'transport.dart';

/// Matrix device-key endpoints for the Houra auth profile.
final class HouraDeviceKeysClient {
  const HouraDeviceKeysClient(this._transport);

  final HouraTransport _transport;

  /// Uploads public Matrix device, one-time, and fallback keys.
  ///
  /// This implements the SPEC-051 request descriptor and upload-count parser
  /// only. Key generation, private-key storage, signature verification,
  /// one-time-key lifecycle, trust UI, and E2EE advertisement remain host-owned.
  Future<HouraKeyUploadResponse> uploadKeys({
    required String accessToken,
    HouraMatrixDeviceKey? deviceKey,
    Map<String, HouraMatrixSignedKey> oneTimeKeys = const {},
    Map<String, HouraMatrixSignedKey> fallbackKeys = const {},
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_matrix', 'client', 'v3', 'keys', 'upload'],
        accessToken: accessToken,
        body: _keyUploadBody(
          deviceKey: deviceKey,
          oneTimeKeys: oneTimeKeys,
          fallbackKeys: fallbackKeys,
        ),
      ),
    );
    return HouraKeyUploadResponse.fromJson(response.jsonObject);
  }

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

  /// Claims public one-time or fallback keys for selected devices.
  ///
  /// This implements the SPEC-051 claim request descriptor and public response
  /// parser only. Claim lifecycle, retry policy, signature verification, trust
  /// UI, secure storage, and Olm/Megolm sessions remain host-owned.
  Future<HouraKeyClaimResponse> claimKeys({
    required String accessToken,
    required Map<String, Map<String, String>> oneTimeKeys,
    int? timeoutMs,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_matrix', 'client', 'v3', 'keys', 'claim'],
        accessToken: accessToken,
        body: _keyClaimBody(
          oneTimeKeys: oneTimeKeys,
          timeoutMs: timeoutMs,
        ),
      ),
    );
    return HouraKeyClaimResponse.fromJson(response.jsonObject);
  }
}

Map<String, Object?> _keyUploadBody({
  HouraMatrixDeviceKey? deviceKey,
  required Map<String, HouraMatrixSignedKey> oneTimeKeys,
  required Map<String, HouraMatrixSignedKey> fallbackKeys,
}) {
  if (deviceKey == null && oneTimeKeys.isEmpty && fallbackKeys.isEmpty) {
    throw HouraTransportException('At least one key payload must be provided.');
  }
  return {
    if (deviceKey != null) 'device_keys': deviceKey.toJson(),
    if (oneTimeKeys.isNotEmpty)
      'one_time_keys': _signedKeyRequestMap(oneTimeKeys),
    if (fallbackKeys.isNotEmpty)
      'fallback_keys': _signedKeyRequestMap(fallbackKeys),
  };
}

Map<String, Object?> _signedKeyRequestMap(
  Map<String, HouraMatrixSignedKey> keys,
) {
  final result = <String, Object?>{};
  for (final entry in keys.entries) {
    if (entry.key.isEmpty) {
      throw HouraTransportException('Key ids must be non-empty.');
    }
    result[entry.key] = entry.value.toJson();
  }
  return result;
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

Map<String, Object?> _keyClaimBody({
  required Map<String, Map<String, String>> oneTimeKeys,
  int? timeoutMs,
}) {
  if (oneTimeKeys.isEmpty) {
    throw HouraTransportException('oneTimeKeys must not be empty.');
  }
  if (timeoutMs != null && timeoutMs < 0) {
    throw HouraTransportException('timeoutMs must be non-negative.');
  }

  final bodyOneTimeKeys = <String, Object?>{};
  for (final userEntry in oneTimeKeys.entries) {
    if (userEntry.key.isEmpty) {
      throw HouraTransportException('oneTimeKeys user ids must be non-empty.');
    }
    if (userEntry.value.isEmpty) {
      throw HouraTransportException(
        'oneTimeKeys device map must not be empty.',
      );
    }
    final devices = <String, Object?>{};
    for (final deviceEntry in userEntry.value.entries) {
      if (deviceEntry.key.isEmpty || deviceEntry.value.isEmpty) {
        throw HouraTransportException(
          'oneTimeKeys device ids and algorithms must be non-empty.',
        );
      }
      devices[deviceEntry.key] = deviceEntry.value;
    }
    bodyOneTimeKeys[userEntry.key] = devices;
  }

  return {
    'one_time_keys': bodyOneTimeKeys,
    if (timeoutMs != null) 'timeout': timeoutMs,
  };
}
