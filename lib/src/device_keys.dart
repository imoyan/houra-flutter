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
  /// This implements the SPEC-069 request descriptor and response parser, and
  /// also parses the optional SPEC-054 cross-signing maps returned by the same
  /// Matrix endpoint. Access-token persistence, transport retry, signature
  /// verification, trust UI, secure storage, and Olm/Megolm sessions remain
  /// host-owned.
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

  /// Creates a public Matrix room-key backup version descriptor.
  ///
  /// This implements the SPEC-053 request descriptor and create-response
  /// parser only. Backup trust, recovery secret storage, Megolm backup
  /// encryption, and Matrix E2EE advertisement remain host-owned.
  Future<HouraKeyBackupVersionCreateResponse> createKeyBackupVersion({
    required String accessToken,
    required String algorithm,
    required Map<String, Object?> authData,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_matrix', 'client', 'v3', 'room_keys', 'version'],
        accessToken: accessToken,
        body: _keyBackupVersionBody(
          algorithm: algorithm,
          authData: authData,
        ),
      ),
    );
    return HouraKeyBackupVersionCreateResponse.fromJson(response.jsonObject);
  }

  /// Reads the current public Matrix room-key backup version metadata.
  Future<HouraKeyBackupVersion> getCurrentKeyBackupVersion({
    required String accessToken,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: const ['_matrix', 'client', 'v3', 'room_keys', 'version'],
        accessToken: accessToken,
      ),
    );
    return HouraKeyBackupVersion.fromJson(response.jsonObject);
  }

  /// Reads a specific public Matrix room-key backup version metadata object.
  Future<HouraKeyBackupVersion> getKeyBackupVersion({
    required String accessToken,
    required String version,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'room_keys',
          'version',
          _requiredNonEmptyIdentifier(version, 'version'),
        ],
        accessToken: accessToken,
      ),
    );
    return HouraKeyBackupVersion.fromJson(response.jsonObject);
  }

  /// Updates public Matrix room-key backup metadata for an existing version.
  Future<void> updateKeyBackupVersion({
    required String accessToken,
    required String version,
    required String algorithm,
    required Map<String, Object?> authData,
  }) async {
    await _transport.send(
      HouraRequest(
        method: 'PUT',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'room_keys',
          'version',
          _requiredNonEmptyIdentifier(version, 'version'),
        ],
        accessToken: accessToken,
        body: _keyBackupVersionBody(
          algorithm: algorithm,
          authData: authData,
        ),
      ),
    );
  }

  /// Uploads an opaque encrypted Matrix room-key backup session payload.
  Future<HouraKeyBackupUploadResponse> uploadKeyBackupSession({
    required String accessToken,
    required String version,
    required String roomId,
    required String sessionId,
    required HouraKeyBackupSessionData session,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'PUT',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'room_keys',
          'keys',
          _requiredNonEmptyIdentifier(roomId, 'roomId'),
          _requiredNonEmptyIdentifier(sessionId, 'sessionId'),
        ],
        queryParameters: {
          'version': _requiredNonEmptyIdentifier(version, 'version'),
        },
        accessToken: accessToken,
        body: _keyBackupSessionBody(session),
      ),
    );
    return HouraKeyBackupUploadResponse.fromJson(response.jsonObject);
  }

  /// Restores an opaque encrypted Matrix room-key backup session payload.
  Future<HouraKeyBackupSessionData> restoreKeyBackupSession({
    required String accessToken,
    required String version,
    required String roomId,
    required String sessionId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: [
          '_matrix',
          'client',
          'v3',
          'room_keys',
          'keys',
          _requiredNonEmptyIdentifier(roomId, 'roomId'),
          _requiredNonEmptyIdentifier(sessionId, 'sessionId'),
        ],
        queryParameters: {
          'version': _requiredNonEmptyIdentifier(version, 'version'),
        },
        accessToken: accessToken,
      ),
    );
    return HouraKeyBackupSessionData.fromJson(response.jsonObject);
  }

  /// Uploads public Matrix cross-signing key material.
  ///
  /// This implements the SPEC-054 request descriptor only. Private signing
  /// keys, signature verification, interactive-auth handling, trust decisions,
  /// and Matrix E2EE advertisement remain host-owned.
  Future<void> uploadCrossSigningKeys({
    required String accessToken,
    HouraMatrixCrossSigningKey? masterKey,
    HouraMatrixCrossSigningKey? selfSigningKey,
    HouraMatrixCrossSigningKey? userSigningKey,
  }) async {
    await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const [
          '_matrix',
          'client',
          'v3',
          'keys',
          'device_signing',
          'upload',
        ],
        accessToken: accessToken,
        body: _crossSigningUploadBody(
          masterKey: masterKey,
          selfSigningKey: selfSigningKey,
          userSigningKey: userSigningKey,
        ),
      ),
    );
  }

  /// Uploads public signatures over Matrix device or cross-signing keys.
  Future<HouraKeySignatureUploadResponse> uploadKeySignatures({
    required String accessToken,
    required Map<String, Map<String, HouraMatrixSignedJsonObject>> signedKeys,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const [
          '_matrix',
          'client',
          'v3',
          'keys',
          'signatures',
          'upload',
        ],
        accessToken: accessToken,
        body: _keySignatureUploadBody(signedKeys),
      ),
    );
    return HouraKeySignatureUploadResponse.fromJson(response.jsonObject);
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

Map<String, Object?> _keyBackupVersionBody({
  required String algorithm,
  required Map<String, Object?> authData,
}) {
  if (algorithm.isEmpty) {
    throw const HouraTransportException('algorithm must be non-empty.');
  }
  if (authData.isEmpty) {
    throw const HouraTransportException('authData must not be empty.');
  }
  return {
    'algorithm': algorithm,
    'auth_data': Map<String, Object?>.unmodifiable(authData),
  };
}

Map<String, Object?> _keyBackupSessionBody(HouraKeyBackupSessionData session) {
  if (session.sessionData.isEmpty) {
    throw const HouraTransportException('sessionData must not be empty.');
  }
  return session.toJson();
}

Map<String, Object?> _crossSigningUploadBody({
  HouraMatrixCrossSigningKey? masterKey,
  HouraMatrixCrossSigningKey? selfSigningKey,
  HouraMatrixCrossSigningKey? userSigningKey,
}) {
  if (masterKey == null && selfSigningKey == null && userSigningKey == null) {
    throw const HouraTransportException(
      'At least one cross-signing key payload must be provided.',
    );
  }
  return {
    if (masterKey != null) 'master_key': masterKey.toJson(),
    if (selfSigningKey != null) 'self_signing_key': selfSigningKey.toJson(),
    if (userSigningKey != null) 'user_signing_key': userSigningKey.toJson(),
  };
}

Map<String, Object?> _keySignatureUploadBody(
  Map<String, Map<String, HouraMatrixSignedJsonObject>> signedKeys,
) {
  if (signedKeys.isEmpty) {
    throw const HouraTransportException('signedKeys must not be empty.');
  }
  final users = <String, Object?>{};
  for (final userEntry in signedKeys.entries) {
    if (userEntry.key.isEmpty || userEntry.value.isEmpty) {
      throw const HouraTransportException(
        'signedKeys user ids and key maps must be non-empty.',
      );
    }
    final objects = <String, Object?>{};
    for (final objectEntry in userEntry.value.entries) {
      if (objectEntry.key.isEmpty) {
        throw const HouraTransportException(
          'signed key object ids must be non-empty.',
        );
      }
      objects[objectEntry.key] = objectEntry.value.toJson();
    }
    users[userEntry.key] = objects;
  }
  return users;
}

String _requiredNonEmptyIdentifier(String value, String name) {
  if (value.isEmpty) {
    throw HouraTransportException('$name must be non-empty.');
  }
  return value;
}
