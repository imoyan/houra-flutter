const cryptoEvidenceRedactionMarker = '[redacted]';

const cryptoEvidenceForbiddenKeyFragments = [
  'access_token',
  'backup_secret',
  'local_path',
  'passphrase',
  'plaintext',
  'private_key',
  'provider_secret',
  'raw_key',
  'recovery_key',
  'secret_storage',
  'secure_storage_handle',
  'session_key',
  'token',
];

Map<String, Object?> buildCryptoEvidenceHelper({
  String? stackName,
  String? stackVersion,
  Iterable<String> platforms = const [],
  Map<String, Object?> artifactMetadata = const {},
}) {
  return redactEvidenceObject({
    'issue': 133,
    'status': 'shared-evidence-helper-adopted',
    'spec_ids': ['SPEC-079', 'SPEC-081'],
    'release_evidence_lane':
        'shared-parser-artifacts-security-release-evidence-breadth',
    'crypto_stack': {
      'selected': stackName != null && stackName.isNotEmpty,
      'name': stackName,
      'version': stackVersion,
      'platforms': platforms.toList(),
      'selection_owner': 'host-application',
    },
    'redaction_policy': {
      'marker': cryptoEvidenceRedactionMarker,
      'forbidden_key_fragments': cryptoEvidenceForbiddenKeyFragments,
      'raw_secret_values_allowed': false,
      'local_secret_paths_allowed': false,
    },
    'artifact_metadata': artifactMetadata,
    'advertisement': {
      'matrix_versions_widened': false,
      'e2ee_support_widened': false,
      'reason':
          'SPEC-079 and SPEC-081 evidence helpers do not select or operate a crypto stack.',
    },
    'out_of_scope': [
      'Olm or Megolm primitives',
      'secure storage ownership',
      'trust UI',
      'transport',
      'retry',
      'Matrix E2EE support advertisement',
    ],
  });
}

Map<String, Object?> redactEvidenceObject(Map<String, Object?> value) {
  return Map<String, Object?>.fromEntries(
    value.entries.map(
      (entry) =>
          MapEntry(entry.key, _redactEvidenceValue(entry.key, entry.value)),
    ),
  );
}

Object? _redactEvidenceValue(String key, Object? value) {
  if (_isForbiddenEvidenceKey(key)) {
    return cryptoEvidenceRedactionMarker;
  }
  if (value is Map) {
    return Map<String, Object?>.fromEntries(
      value.entries.map(
        (entry) => MapEntry(
          entry.key.toString(),
          _redactEvidenceValue(entry.key.toString(), entry.value),
        ),
      ),
    );
  }
  if (value is List) {
    return [
      for (final item in value) _redactEvidenceValue(key, item),
    ];
  }
  if (value is String && _looksLikeLocalSecretPath(value)) {
    return cryptoEvidenceRedactionMarker;
  }
  return value;
}

bool _isForbiddenEvidenceKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return cryptoEvidenceForbiddenKeyFragments.any(normalized.contains);
}

bool _looksLikeLocalSecretPath(String value) {
  final normalized = value.toLowerCase();
  final looksLikeAbsolutePath =
      normalized.startsWith('/users/') || normalized.startsWith('/var/');
  if (!looksLikeAbsolutePath) {
    return false;
  }
  return normalized.contains('keychain') ||
      normalized.contains('secure') ||
      normalized.contains('secret') ||
      normalized.contains('session') ||
      normalized.contains('recovery') ||
      normalized.contains('private');
}
