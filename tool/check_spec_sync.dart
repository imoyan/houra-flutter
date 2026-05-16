import 'dart:convert';
import 'dart:io';

Map<String, Object?>? _releaseEvidenceCache;
bool _releaseEvidenceReadAttempted = false;

void main() {
  final failures = <String>[];
  checkSdkBoundary(failures);
  checkCanonicalSpecRoot(failures);
  checkDesignSync(failures);
  checkVectorReferences(failures);
  checkDocReferences(failures);
  checkSpec039ProtocolCoreGate(failures);
  checkSpec040ProtocolCoreGate(failures);
  checkSpec048ProtocolCoreGate(failures);
  checkSpec049ProtocolCoreGate(failures);
  checkSpec051ProtocolCoreGate(failures);
  checkSpec053ProtocolCoreGate(failures);
  checkSpec054ProtocolCoreGate(failures);
  checkSpec069ProtocolCoreGate(failures);
  checkSpec085ProtocolCoreGate(failures);
  checkSpec090ProtocolCoreGate(failures);
  checkSpec093ProtocolCoreGate(failures);
  checkSpec095ProtocolCoreGate(failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Spec sync check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
  }
}

void checkSdkBoundary(List<String> failures) {
  const allowedTopLevel = {
    '.github',
    '.gitignore',
    'AGENTS.md',
    'CHANGELOG.md',
    'LICENSE',
    'README.md',
    'SECURITY.md',
    'design',
    'example',
    'lib',
    'pubspec.yaml',
    'rust-protocol-core',
    'rust-protocol-core-wasm',
    'test',
    'tool',
    'ts-protocol-core-wasm',
  };
  const allowedToolFiles = {
    'check_spec_sync.dart',
    'generate_release_evidence.dart',
    'release_evidence_helpers.dart',
  };
  const canonicalOnlyEntries = {
    'contracts',
    'test-vectors',
    'SOURCE_OF_TRUTH.md',
    'REFERENCE_POLICY.md',
    'FEATURE_PROFILES.md',
    'MODULE_DEPENDENCIES.md',
    'CONTRACT_MODULE_MAP.md',
  };

  for (final entity in Directory.current.listSync()) {
    final name = entityName(entity);
    if (isGeneratedEntry(name)) {
      continue;
    }
    if (!allowedTopLevel.contains(name)) {
      failures.add('Unexpected top-level entry in SDK root: $name');
    }
    if (canonicalOnlyEntries.contains(name)) {
      failures.add(
        'Canonical spec entry must not be copied into SDK root: '
        '$name',
      );
    }
  }

  final toolRoot = Directory('tool');
  if (!toolRoot.existsSync()) {
    failures.add('Missing tool directory.');
    return;
  }
  for (final entity in toolRoot.listSync()) {
    final name = entityName(entity);
    if (entity is! File || !allowedToolFiles.contains(name)) {
      failures.add(
        'Unexpected SDK tool entry: ${relativePath(entity, Directory.current)}',
      );
    }
  }
}

void checkCanonicalSpecRoot(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  if (!specRoot.existsSync()) {
    failures.add('Missing sibling spec root: ${specRoot.path}');
    return;
  }

  final script = File('${specRoot.path}/tool/check_spec.dart');
  if (!script.existsSync()) {
    failures.add('Missing canonical spec check: ${script.path}');
    return;
  }

  final result = Process.runSync(
      'dart',
      [
        'tool/check_spec.dart',
      ],
      workingDirectory: specRoot.path);
  if (result.exitCode != 0) {
    failures.add('Canonical spec check failed: dart tool/check_spec.dart');
    addCommandOutput('stdout', result.stdout, failures);
    addCommandOutput('stderr', result.stderr, failures);
  }
}

void checkDesignSync(List<String> failures) {
  final localRoot = Directory('design');
  final specRoot = canonicalSpecRoot();
  final canonicalRoot = Directory('${specRoot.path}/design');

  if (!localRoot.existsSync()) {
    failures.add('Missing local design directory: ${localRoot.path}');
    return;
  }
  if (!canonicalRoot.existsSync()) {
    failures.add('Missing canonical design directory: ${canonicalRoot.path}');
    return;
  }

  final localFiles = filesByRelativePath(localRoot);
  final canonicalFiles = filesByRelativePath(canonicalRoot);
  for (final relativePath in canonicalFiles.keys) {
    final local = localFiles[relativePath];
    final canonical = canonicalFiles[relativePath]!;
    if (local == null) {
      failures.add('Missing bundled design file: design/$relativePath');
      continue;
    }
    if (local.readAsStringSync() != canonical.readAsStringSync()) {
      failures.add(
        'design/$relativePath differs from '
        '${specRoot.path}/design/$relativePath',
      );
    }
  }
  for (final relativePath in localFiles.keys) {
    if (!canonicalFiles.containsKey(relativePath)) {
      failures.add(
        'Bundled design file has no canonical source: '
        'design/$relativePath',
      );
    }
  }
}

void checkVectorReferences(List<String> failures) {
  final testRoot = Directory('test');
  if (!testRoot.existsSync()) {
    failures.add('Missing test directory.');
    return;
  }

  final readVectorPattern = RegExp(r'''readVector\(\s*['"]([^'"]+)['"]\s*\)''');
  final directSpecVectorPattern = RegExp(
    r'''(?:\.\./)?houra-spec/test-vectors/[^'"\s)]+''',
  );
  for (final file in dartFilesUnder(testRoot)) {
    final source = file.readAsStringSync();
    final relativeTestPath = relativePath(file, Directory.current);
    for (final match in readVectorPattern.allMatches(source)) {
      final vectorPath = match.group(1)!;
      final specRoot = canonicalSpecRoot();
      final canonical = File('${specRoot.path}/$vectorPath');
      if (!canonical.existsSync()) {
        failures.add(
          '$relativeTestPath references missing vector: '
          '${specRoot.path}/$vectorPath',
        );
      }
    }

    if (file.path.endsWith('vector_test_support.dart')) {
      continue;
    }
    for (final match in directSpecVectorPattern.allMatches(source)) {
      failures.add(
        '$relativeTestPath should use readVector(...) for '
        'canonical vector reference: ${match.group(0)}',
      );
    }
  }
}

void checkDocReferences(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  if (!specRoot.existsSync()) {
    failures.add('Missing sibling spec root: ${specRoot.path}');
    return;
  }

  final contractIds = <String>{};
  final contractRoot = Directory('${specRoot.path}/contracts');
  if (!contractRoot.existsSync()) {
    failures.add('Missing canonical contract directory: ${contractRoot.path}');
    return;
  }
  for (final file in contractRoot.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    final match = RegExp(r'^(SPEC-\d{3})-.*\.md$').firstMatch(name);
    if (match != null) {
      contractIds.add(match.group(1)!);
    }
  }

  final docFiles = [File('README.md'), File('AGENTS.md')];
  final specReferencePattern = RegExp(r'\bSPEC-\d{3}\b');
  final relativeSpecPathPattern = RegExp(
    r'''`?(\.\./houra-spec(?:/[A-Za-z0-9._/\-]+)?)`?''',
  );

  for (final doc in docFiles) {
    if (!doc.existsSync()) {
      failures.add('Missing documentation file: ${doc.path}');
      continue;
    }
    final source = doc.readAsStringSync();
    for (final match in specReferencePattern.allMatches(source)) {
      final specId = match.group(0)!;
      if (!contractIds.contains(specId)) {
        failures.add('${doc.path} references missing contract: $specId');
      }
    }
    for (final match in relativeSpecPathPattern.allMatches(source)) {
      final path = match.group(1)!;
      final resolved = resolveSpecReference(path, specRoot);
      if (!File(resolved).existsSync() && !Directory(resolved).existsSync()) {
        failures.add('${doc.path} references missing spec path: $resolved');
      }
    }
  }
}

void checkSpec039ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final spec039ContractName = [
    'SPEC-039',
    'matrix',
    'client',
    'server',
    'mvp',
    'live',
    'e2e',
    'gate.md',
  ].join('-');
  final spec039VectorName = [
    'matrix',
    'client',
    'server',
    'mvp',
    'live',
    'e2e',
    'gate.json',
  ].join('-');
  final contract = File('${specRoot.path}/contracts/$spec039ContractName');
  final vector = File('${specRoot.path}/test-vectors/core/$spec039VectorName');
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-039 contract: ${contract.path}');
    return;
  }
  if (!vector.existsSync()) {
    failures.add('Missing SPEC-039 canonical vector: ${vector.path}');
    return;
  }

  final decoded = jsonDecode(vector.readAsStringSync());
  if (decoded is! Map<String, Object?> || decoded['contract'] != 'SPEC-039') {
    failures.add('SPEC-039 canonical vector has an unexpected contract id.');
    return;
  }
  final event = decoded['event'];
  if (event is! Map<String, Object?>) {
    failures.add('SPEC-039 canonical vector is missing event metadata.');
    return;
  }
  final requiredContracts = event['required_contracts'];
  const expectedRequiredContracts = [
    'SPEC-030',
    'SPEC-031',
    'SPEC-032',
    'SPEC-033',
    'SPEC-034',
    'SPEC-035',
    'SPEC-036',
    'SPEC-037',
    'SPEC-038',
  ];
  if (requiredContracts is! List ||
      !orderedListEquals(requiredContracts, expectedRequiredContracts)) {
    failures.add(
      'SPEC-039 canonical vector must list required_contracts '
      'exactly as SPEC-030 through SPEC-038.',
    );
  }

  final requiredFragmentsByFile = {
    'rust-protocol-core/src/lib.rs': ['"SPEC-039"', 'SPEC-039'],
    'rust-protocol-core-wasm/src/lib.rs': [
      'artifact_manifest_json_for_binding_kinds',
    ],
    'ts-protocol-core-wasm/src/index.ts': ['"SPEC-039"'],
    'ts-protocol-core-wasm/test/index.test.mjs': [
      'HOURA_PROTOCOL_CORE_SPEC_IDS',
      'SPEC-039',
    ],
  };
  for (final entry in requiredFragmentsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing protocol core gate file: ${entry.key}');
      continue;
    }
    final source = file.readAsStringSync();
    for (final fragment in entry.value) {
      if (!source.contains(fragment)) {
        failures.add(
          '${entry.key} is missing SPEC-039 gate fragment: $fragment',
        );
      }
    }
  }
}

void checkSpec040ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-040-matrix-event-dag-auth-events.md',
  );
  final validVector = File(
    '${specRoot.path}/test-vectors/events/matrix-event-dag-auth-events-basic.json',
  );
  final invalidVector = File(
    '${specRoot.path}/test-vectors/events/matrix-event-dag-auth-events-invalid.json',
  );
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-040 contract: ${contract.path}');
    return;
  }
  if (!validVector.existsSync()) {
    failures.add('Missing SPEC-040 canonical vector: ${validVector.path}');
    return;
  }
  if (!invalidVector.existsSync()) {
    failures.add('Missing SPEC-040 canonical vector: ${invalidVector.path}');
    return;
  }

  final validDecoded = jsonDecode(validVector.readAsStringSync());
  final invalidDecoded = jsonDecode(invalidVector.readAsStringSync());
  if (validDecoded is! Map<String, Object?> ||
      validDecoded['contract'] != 'SPEC-040') {
    failures.add('SPEC-040 valid vector has an unexpected contract id.');
    return;
  }
  if (invalidDecoded is! Map<String, Object?> ||
      invalidDecoded['contract'] != 'SPEC-040') {
    failures.add('SPEC-040 invalid vector has an unexpected contract id.');
    return;
  }

  final validEvent = validDecoded['event'];
  final invalidEvent = invalidDecoded['event'];
  if (validEvent is! Map<String, Object?> ||
      validEvent['matrix_spec_version'] != 'v1.18' ||
      validEvent['room_version'] != '12') {
    failures.add(
      'SPEC-040 valid vector is missing Matrix v1.18 room v12 metadata.',
    );
  }
  if (invalidEvent is! Map<String, Object?> ||
      invalidEvent['matrix_spec_version'] != 'v1.18') {
    failures.add('SPEC-040 invalid vector is missing Matrix v1.18 metadata.');
  }

  final requiredFragmentsByFile = {
    'rust-protocol-core/src/lib.rs': ['"SPEC-040"', 'SPEC-040'],
    'rust-protocol-core-wasm/src/lib.rs': [
      'artifact_manifest_json_for_binding_kinds',
    ],
    'ts-protocol-core-wasm/src/index.ts': ['"SPEC-040"'],
    'ts-protocol-core-wasm/test/index.test.mjs': [
      'HOURA_PROTOCOL_CORE_SPEC_IDS',
      'SPEC-040',
      'matrix-event-dag-auth-events-basic',
      'matrix-event-dag-auth-events-invalid',
    ],
  };
  for (final entry in requiredFragmentsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing protocol core gate file: ${entry.key}');
      continue;
    }
    final source = file.readAsStringSync();
    for (final fragment in entry.value) {
      if (!source.contains(fragment)) {
        failures.add(
          '${entry.key} is missing SPEC-040 gate fragment: $fragment',
        );
      }
    }
  }
}

void checkSpec049ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-049-matrix-moderation-reporting-admin-controls.md',
  );
  final vectors = [
    'test-vectors/rooms/matrix-room-moderation-kick-ban-unban.json',
    'test-vectors/rooms/matrix-room-moderation-permission-denied.json',
    'test-vectors/rooms/matrix-room-redaction-basic.json',
    'test-vectors/rooms/matrix-room-redaction-forbidden.json',
    'test-vectors/rooms/matrix-room-reporting-basic.json',
    'test-vectors/rooms/matrix-admin-account-moderation-basic.json',
    'test-vectors/rooms/matrix-admin-account-moderation-forbidden.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-049 contract: ${contract.path}');
    return;
  }
  for (final vectorPath in vectors) {
    final vector = File('${specRoot.path}/$vectorPath');
    if (!vector.existsSync()) {
      failures.add('Missing SPEC-049 canonical vector: ${vector.path}');
      continue;
    }
    final decoded = jsonDecode(vector.readAsStringSync());
    if (decoded is! Map<String, Object?> || decoded['contract'] != 'SPEC-049') {
      failures
          .add('SPEC-049 vector has an unexpected contract id: $vectorPath');
    }
  }
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'moderation_reporting_parser_adoption',
    issue: 64,
    specId: 'SPEC-049',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'kick/ban/unban request descriptor',
      'redaction request descriptor',
      'redaction response envelope',
      'room/event/user report request descriptor',
      'account moderation capability envelope',
      'admin lock/suspend request and status envelope',
      'moderation Matrix error envelope',
    ],
    outOfScope: [
      'authorization decisions',
      'policy enforcement',
      'appeal process',
      'moderation queue UI',
      'audit logging',
      'federation enforcement',
      'Matrix moderation support advertisement',
    ],
  );

  final requiredFragmentsByFile = {
    'AGENTS.md': ['SPEC-049'],
    'rust-protocol-core/src/lib.rs': [
      '"SPEC-049"',
      'parse_matrix_moderation_request',
      'parse_matrix_redaction_request',
      'parse_matrix_redaction_response',
      'parse_matrix_report_request',
      'parse_matrix_account_moderation_capability',
      'parse_matrix_admin_account_moderation_status',
      'parse_matrix_moderation_error',
      'matrix-room-redaction-forbidden.json',
    ],
    'rust-protocol-core-wasm/src/lib.rs': [
      'parseMatrixModerationRequestJson',
      'parseMatrixRedactionRequestJson',
      'parseMatrixRedactionResponseJson',
      'parseMatrixReportRequestJson',
      'parseMatrixAccountModerationCapabilityJson',
      'parseMatrixAdminAccountModerationStatusJson',
      'parseMatrixModerationErrorJson',
    ],
    'ts-protocol-core-wasm/src/index.ts': [
      '"SPEC-049"',
      'parseMatrixModerationRequest',
      'parseMatrixRedactionRequest',
      'parseMatrixRedactionResponse',
      'parseMatrixReportRequest',
      'parseMatrixAccountModerationCapability',
      'parseMatrixAdminAccountModerationStatus',
      'parseMatrixModerationError',
    ],
    'ts-protocol-core-wasm/test/index.test.mjs': [
      'SPEC-049',
      'matrix-room-moderation-kick-ban-unban.json',
      'matrix-room-redaction-basic.json',
      'matrix-room-reporting-basic.json',
      'matrix-admin-account-moderation-basic.json',
      'matrix-room-moderation-permission-denied.json',
    ],
  };
  for (final entry in requiredFragmentsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing SPEC-049 gate file: ${entry.key}');
      continue;
    }
    final source = file.readAsStringSync();
    for (final fragment in entry.value) {
      if (!source.contains(fragment)) {
        failures
            .add('${entry.key} is missing SPEC-049 gate fragment: $fragment');
      }
    }
  }
}

void checkSpec051ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-051-matrix-device-one-time-fallback-keys.md',
  );
  final vectors = [
    'test-vectors/auth/matrix-keys-upload-device-one-time-fallback-basic.json',
    'test-vectors/auth/matrix-keys-upload-malformed-device-keys.json',
    'test-vectors/auth/matrix-keys-claim-one-time-fallback-basic.json',
    'test-vectors/auth/matrix-keys-claim-invalid-algorithm.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-051 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-051', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'device_key_parser_adoption',
    issue: 66,
    specId: 'SPEC-051',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'device key upload request',
      'one-time key upload request',
      'fallback key upload request',
      'one-time key count upload response',
      'one-time/fallback key claim request',
      'one-time/fallback key claim response',
      'device-key Matrix error envelope',
    ],
    outOfScope: [
      'Olm or Megolm key generation',
      'private key storage',
      'signature verification',
      'trust policy decisions',
      'claim lifecycle enforcement',
      'Matrix E2EE support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-051',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-051'],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-051"',
        'parse_matrix_keys_upload_request',
        'parse_matrix_keys_upload_response',
        'parse_matrix_keys_claim_request',
        'parse_matrix_keys_claim_response',
        'parse_matrix_device_key_error',
        'matrix-keys-upload-malformed-device-keys.json',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixKeysUploadRequestJson',
        'parseMatrixKeysUploadResponseJson',
        'parseMatrixKeysClaimRequestJson',
        'parseMatrixKeysClaimResponseJson',
        'parseMatrixDeviceKeyErrorJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-051"',
        'parseMatrixKeysUploadRequest',
        'parseMatrixKeysUploadResponse',
        'parseMatrixKeysClaimRequest',
        'parseMatrixKeysClaimResponse',
        'parseMatrixDeviceKeyError',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-051',
        'matrix-keys-upload-device-one-time-fallback-basic.json',
        'matrix-keys-claim-one-time-fallback-basic.json',
        'matrix-keys-claim-invalid-algorithm.json',
      ],
    },
  );
}

void checkSpec053ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-053-matrix-key-backup-restore-gate.md',
  );
  final vectors = [
    'test-vectors/messaging/matrix-key-backup-version-lifecycle.json',
    'test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json',
    'test-vectors/messaging/matrix-key-backup-wrong-version.json',
    'test-vectors/messaging/matrix-key-backup-restore-missing-session.json',
    'test-vectors/messaging/matrix-key-backup-owner-scope.json',
    'test-vectors/messaging/matrix-key-backup-logout-relogin-recovery-gate.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-053 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-053', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'key_backup_parser_adoption',
    issue: 68,
    specId: 'SPEC-053',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'key backup version create response',
      'key backup version metadata',
      'room key backup session metadata',
      'room key backup upload response',
      'wrong-version and missing-session errors',
      'owner-scope protection gate',
      'logout/relogin recovery evidence gate',
    ],
    outOfScope: [
      'Megolm backup encryption or decryption',
      'room key storage',
      'recovery secret storage',
      'backup ownership authorization policy',
      'logout/relogin UX',
      'Matrix E2EE support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-053',
    requiredFragmentsByFile: {
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-053"',
        'parse_matrix_key_backup_version_create_response',
        'parse_matrix_key_backup_version',
        'parse_matrix_key_backup_session',
        'parse_matrix_key_backup_session_upload_response',
        'parse_matrix_key_backup_error',
        'parse_matrix_key_backup_owner_scope_gate',
        'parse_matrix_key_backup_recovery_gate',
        'matrix-key-backup-owner-scope.json',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixKeyBackupVersionCreateResponseJson',
        'parseMatrixKeyBackupVersionJson',
        'parseMatrixKeyBackupSessionJson',
        'parseMatrixKeyBackupSessionUploadResponseJson',
        'parseMatrixKeyBackupErrorJson',
        'parseMatrixKeyBackupOwnerScopeGateJson',
        'parseMatrixKeyBackupRecoveryGateJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-053"',
        'parseMatrixKeyBackupVersionCreateResponse',
        'parseMatrixKeyBackupVersion',
        'parseMatrixKeyBackupSession',
        'parseMatrixKeyBackupSessionUploadResponse',
        'parseMatrixKeyBackupError',
        'parseMatrixKeyBackupOwnerScopeGate',
        'parseMatrixKeyBackupRecoveryGate',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-053',
        'matrix-key-backup-version-lifecycle.json',
        'matrix-key-backup-session-upload-restore-basic.json',
        'matrix-key-backup-owner-scope.json',
      ],
    },
  );
}

void checkSpec054ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-054-matrix-verification-cross-signing-gate.md',
  );
  final vectors = [
    'test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json',
    'test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json',
    'test-vectors/messaging/matrix-cross-signing-key-lifecycle.json',
    'test-vectors/messaging/matrix-cross-signing-invalid-signature.json',
    'test-vectors/messaging/matrix-cross-signing-missing-token.json',
    'test-vectors/messaging/matrix-wrong-device-failure-gate.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-054 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-054', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'verification_cross_signing_parser_adoption',
    issue: 69,
    specId: 'SPEC-054',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'SAS to-device message flow envelope',
      'verification cancel envelope',
      'cross-signing public key upload envelope',
      'signature upload envelope',
      'invalid signature failure envelope',
      'missing-token gate envelope',
      'wrong-device failure gate envelope',
    ],
    outOfScope: [
      'local SAS calculation',
      'Ed25519 verification',
      'Olm or Megolm session handling',
      'cross-signing private key storage',
      'trust policy decisions',
      'QR verification or account recovery UI',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-054',
    requiredFragmentsByFile: {
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-054"',
        'parse_matrix_verification_sas_flow',
        'parse_matrix_verification_cancel',
        'parse_matrix_cross_signing_device_signing_upload',
        'parse_matrix_cross_signing_signature_upload',
        'parse_matrix_cross_signing_invalid_signature_failure',
        'parse_matrix_cross_signing_missing_token_gate',
        'parse_matrix_wrong_device_failure_gate',
        'matrix-cross-signing-missing-token.json',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixVerificationSasFlowJson',
        'parseMatrixVerificationCancelJson',
        'parseMatrixCrossSigningDeviceSigningUploadJson',
        'parseMatrixCrossSigningSignatureUploadJson',
        'parseMatrixCrossSigningInvalidSignatureFailureJson',
        'parseMatrixCrossSigningMissingTokenGateJson',
        'parseMatrixWrongDeviceFailureGateJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-054"',
        'parseMatrixVerificationSasFlow',
        'parseMatrixVerificationCancel',
        'parseMatrixCrossSigningDeviceSigningUpload',
        'parseMatrixCrossSigningSignatureUpload',
        'parseMatrixCrossSigningInvalidSignatureFailure',
        'parseMatrixCrossSigningMissingTokenGate',
        'parseMatrixWrongDeviceFailureGate',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-054',
        'matrix-verification-sas-to-device-happy-path.json',
        'matrix-cross-signing-key-lifecycle.json',
        'matrix-wrong-device-failure-gate.json',
      ],
    },
  );
}

void checkSpec069ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-069-matrix-device-key-query.md',
  );
  final vectors = [
    'test-vectors/auth/matrix-keys-query-basic.json',
    'test-vectors/auth/matrix-keys-query-all-devices.json',
    'test-vectors/auth/matrix-keys-query-unknown-device-omitted.json',
    'test-vectors/auth/matrix-keys-query-missing-token.json',
    'test-vectors/auth/matrix-keys-query-timeout-not-integer.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-069 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-069', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'device_key_query_parser_adoption',
    issue: 65,
    specId: 'SPEC-069',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'device key query request descriptor',
      'all-devices query selector',
      'public device-key query response',
      'unknown-device omission response',
      'device-key query Matrix error envelope',
    ],
    outOfScope: [
      'signature verification',
      'device trust decisions',
      'secure storage',
      'crypto verification',
      'device list lifecycle',
      'Matrix E2EE support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-069',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-069'],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-069"',
        'parse_matrix_device_key_query_request',
        'parse_matrix_device_key_query_response',
        'matrix-keys-query-all-devices.json',
        'matrix-keys-query-timeout-not-integer.json',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixDeviceKeyQueryRequestJson',
        'parseMatrixDeviceKeyQueryResponseJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-069"',
        'parseMatrixDeviceKeyQueryRequest',
        'parseMatrixDeviceKeyQueryResponse',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-069',
        'matrix-keys-query-basic.json',
        'matrix-keys-query-all-devices.json',
        'matrix-keys-query-missing-token.json',
      ],
    },
  );
}

void checkSpec085ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/'
    'SPEC-085-matrix-'
    'client-server-event-retrieval-membership-history.md',
  );
  final vectors = [
    'test-vectors/core/'
        'matrix-'
        'client-server-event-retrieval-membership-history.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-085 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-085', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'event_retrieval_membership_parser_adoption',
    issue: 119,
    specId: 'SPEC-085',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'event retrieval request descriptor',
      'Matrix ClientEvent response envelope',
      'joined_members response envelope',
      'members membership chunk envelope',
      'timestamp_to_event response envelope',
      'deprecated compatibility unsupported descriptor',
    ],
    outOfScope: [
      'runtime route behavior',
      'history visibility',
      'authorization',
      'storage lookup',
      'deprecated endpoint compatibility',
      'Matrix Client-Server support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-085',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-085'],
      'README.md': ['SPEC-085', 'event retrieval'],
      'lib/src/models.dart': [
        'HouraMatrixClientEvent',
        'HouraMatrixJoinedMembers',
        'HouraMatrixMembers',
        'HouraMatrixTimestampToEvent',
      ],
      'lib/src/rooms.dart': [
        'getMatrixRoomEvent',
        'getMatrixJoinedMembers',
        'getMatrixMembers',
        'matrixTimestampToEvent',
      ],
      'test/rooms_events_contract_test.dart': [
        'SPEC-085',
        'event-retrieval-membership-history.json',
      ],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-085"',
        'parse_matrix_event_retrieval_request_descriptor',
        'parse_matrix_joined_members_response',
        'parse_matrix_members_response',
        'parse_matrix_timestamp_to_event_response',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixEventRetrievalRequestDescriptorJson',
        'parseMatrixJoinedMembersResponseJson',
        'parseMatrixMembersResponseJson',
        'parseMatrixTimestampToEventResponseJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-085"',
        'parseMatrixEventRetrievalRequestDescriptor',
        'parseMatrixJoinedMembersResponse',
        'parseMatrixMembersResponse',
        'parseMatrixTimestampToEventResponse',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-085',
        'event-retrieval-membership-history.json',
      ],
    },
  );
}

void checkSpec090ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/'
    'SPEC-090-matrix-'
    'client-server-relations-threads-reactions.md',
  );
  final vectors = [
    'test-vectors/core/'
        'matrix-'
        'client-server-relations-threads-reactions.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-090 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-090', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'relations_threads_reactions_parser_adoption',
    issue: 120,
    specId: 'SPEC-090',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'relations request descriptor',
      'relation chunk response envelope',
      'thread roots response envelope',
      'reaction event relation content',
      'edit relation content',
      'reply relation content',
      'membership variant failure envelope',
    ],
    outOfScope: [
      'runtime route behavior',
      'relation aggregation correctness',
      'thread ordering',
      'fanout',
      'authorization',
      'knock runtime behavior',
      'restricted join runtime behavior',
      'Matrix Client-Server support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-090',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-090'],
      'README.md': ['SPEC-090', 'relations'],
      'lib/src/models.dart': [
        'HouraMatrixRelationChunk',
        'HouraMatrixThreadRoots',
        'HouraMatrixReactionRelation',
        'HouraMatrixThreadSummary',
        'HouraMatrixEditRelation',
      ],
      'lib/src/rooms.dart': ['getMatrixRelations', 'getMatrixThreads'],
      'test/rooms_events_contract_test.dart': [
        'SPEC-090',
        'relations-threads-reactions.json',
      ],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-090"',
        'parse_matrix_relations_request_descriptor',
        'parse_matrix_relation_chunk_response',
        'parse_matrix_thread_roots_response',
        'parse_matrix_reaction_event',
        'parse_matrix_edit_event',
        'parse_matrix_reply_event',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixRelationsRequestDescriptorJson',
        'parseMatrixRelationChunkResponseJson',
        'parseMatrixThreadRootsResponseJson',
        'parseMatrixReactionEventJson',
        'parseMatrixEditEventJson',
        'parseMatrixReplyEventJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-090"',
        'parseMatrixRelationsRequestDescriptor',
        'parseMatrixRelationChunkResponse',
        'parseMatrixThreadRootsResponse',
        'parseMatrixReactionEvent',
        'parseMatrixEditEvent',
        'parseMatrixReplyEvent',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-090',
        'relations-threads-reactions.json',
      ],
    },
  );
}

void checkSpec093ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-093-matrix-sync-breadth-extensions.md',
  );
  final vectors = [
    'test-vectors/sync/matrix-sync-breadth-extensions.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-093 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-093', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'sync_breadth_extensions_parser_adoption',
    issue: 121,
    specId: 'SPEC-093',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'sync request descriptor',
      'presence event snippets',
      'to-device event snippets',
      'device list changes',
      'one-time key counts',
      'invite room section map',
      'leave room section map',
      'knock room section map',
    ],
    outOfScope: [
      'sync long-poll runtime',
      'sync token persistence',
      'fanout timing',
      'authorization',
      'filter storage',
      'timeline ordering',
      'device-list freshness',
      'Matrix Client-Server support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-093',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-093'],
      'README.md': ['SPEC-093', 'sync breadth extension'],
      'lib/src/models.dart': [
        'HouraMatrixSyncRequestDescriptor',
        'HouraMatrixSyncBatch',
        'HouraMatrixDeviceLists',
        'HouraMatrixSyncRooms',
      ],
      'test/sync_contract_test.dart': [
        'SPEC-093',
        'matrix-sync-breadth-extensions.json',
      ],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-093"',
        'parse_matrix_sync_request_descriptor',
        'parse_matrix_sync_response',
        'MatrixSyncDeviceLists',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixSyncRequestDescriptorJson',
        'parseMatrixSyncResponseJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-093"',
        'parseMatrixSyncRequestDescriptor',
        'parseMatrixSyncResponse',
        'MatrixSyncRequestDescriptor',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-093',
        'matrix-sync-breadth-extensions.json',
      ],
    },
  );
}

void checkSpec095ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-095-matrix-media-repository-breadth.md',
  );
  final vectors = [
    'test-vectors/media/matrix-media-repository-breadth.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-095 contract: ${contract.path}');
    return;
  }
  checkVectorsHaveContract(failures, specRoot, 'SPEC-095', vectors);
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'media_repository_breadth_parser_adoption',
    issue: 122,
    specId: 'SPEC-095',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'media repository request descriptor',
      'media config metadata',
      'URL preview metadata',
      'thumbnail metadata',
      'async upload metadata',
      'Content-Disposition filename helper',
      'Matrix Content URI validation',
    ],
    outOfScope: [
      'binary media transfer',
      'thumbnail generation',
      'preview crawling',
      'remote media fetch',
      'resumable upload runtime',
      'range requests',
      'encrypted attachment behavior',
      'Matrix Client-Server support advertisement',
    ],
  );

  checkRequiredFragments(
    failures,
    specId: 'SPEC-095',
    requiredFragmentsByFile: {
      'AGENTS.md': ['SPEC-095'],
      'README.md': ['SPEC-095', 'media repository breadth'],
      'lib/src/models.dart': [
        'HouraMatrixMediaRequestDescriptor',
        'HouraMatrixMediaConfig',
        'HouraMatrixMediaPreviewMetadata',
        'HouraMatrixMediaThumbnailMetadata',
        'HouraMatrixMediaAsyncUploadMetadata',
        'HouraMatrixMediaContentDisposition',
      ],
      'test/media_contract_test.dart': [
        'SPEC-095',
        'matrix-media-repository-breadth.json',
      ],
      'rust-protocol-core/src/lib.rs': [
        '"SPEC-095"',
        'parse_matrix_media_repository_request_descriptor',
        'parse_matrix_media_config_response',
        'parse_matrix_media_preview_url_response',
        'parse_matrix_media_thumbnail_metadata',
        'parse_matrix_media_upload_create_response',
        'parse_matrix_media_content_disposition_filename',
      ],
      'rust-protocol-core-wasm/src/lib.rs': [
        'parseMatrixMediaRepositoryRequestDescriptorJson',
        'parseMatrixMediaConfigResponseJson',
        'parseMatrixMediaPreviewUrlResponseJson',
        'parseMatrixMediaThumbnailMetadataJson',
        'parseMatrixMediaUploadCreateResponseJson',
        'parseMatrixMediaContentDispositionFilenameJson',
      ],
      'ts-protocol-core-wasm/src/index.ts': [
        '"SPEC-095"',
        'parseMatrixMediaRepositoryRequestDescriptor',
        'parseMatrixMediaConfigResponse',
        'parseMatrixMediaPreviewUrlResponse',
        'parseMatrixMediaThumbnailMetadata',
        'parseMatrixMediaUploadCreateResponse',
        'parseMatrixMediaContentDispositionFilename',
      ],
      'ts-protocol-core-wasm/test/index.test.mjs': [
        'SPEC-095',
        'matrix-media-repository-breadth.json',
      ],
    },
  );
}

void checkSpec048ProtocolCoreGate(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  final contract = File(
    '${specRoot.path}/contracts/SPEC-048-matrix-room-directory-aliases-invites.md',
  );
  final vectors = [
    'test-vectors/rooms/matrix-public-rooms-basic.json',
    'test-vectors/rooms/matrix-public-rooms-filter-basic.json',
    'test-vectors/rooms/matrix-room-directory-visibility-basic.json',
    'test-vectors/rooms/matrix-room-aliases-basic.json',
    'test-vectors/rooms/matrix-room-alias-update-forbidden.json',
    'test-vectors/rooms/matrix-room-invite-basic.json',
    'test-vectors/rooms/matrix-room-invite-forbidden.json',
  ];
  if (!contract.existsSync()) {
    failures.add('Missing SPEC-048 contract: ${contract.path}');
    return;
  }
  for (final vectorPath in vectors) {
    final vector = File('${specRoot.path}/$vectorPath');
    if (!vector.existsSync()) {
      failures.add('Missing SPEC-048 canonical vector: ${vector.path}');
      continue;
    }
    final decoded = jsonDecode(vector.readAsStringSync());
    if (decoded is! Map<String, Object?> || decoded['contract'] != 'SPEC-048') {
      failures
          .add('SPEC-048 vector has an unexpected contract id: $vectorPath');
    }
  }
  checkReleaseEvidenceAdoption(
    failures,
    blockName: 'room_directory_parser_adoption',
    issue: 63,
    specId: 'SPEC-048',
    parityVectors: vectors,
    parserOnlySurfaces: [
      'public room directory request descriptor',
      'public room directory response envelope',
      'directory visibility envelope',
      'room alias list envelope',
      'invite request descriptor',
      'stripped invite state envelope',
      'room directory Matrix error envelope',
    ],
    outOfScope: [
      'directory storage',
      'visibility policy',
      'federation invite signing',
      'remote public room federation',
      'third-party invite behavior',
      'spaces hierarchy traversal',
      'Matrix room directory support advertisement',
    ],
  );

  final requiredFragmentsByFile = {
    'AGENTS.md': ['SPEC-048'],
    'rust-protocol-core/src/lib.rs': [
      '"SPEC-048"',
      'parse_matrix_public_rooms_request',
      'parse_matrix_public_rooms_response',
      'parse_matrix_directory_visibility',
      'parse_matrix_room_aliases',
      'parse_matrix_invite_request',
      'parse_matrix_invite_room',
      'parse_matrix_room_directory_error',
      'matrix-room-invite-forbidden.json',
    ],
    'rust-protocol-core-wasm/src/lib.rs': [
      'parseMatrixPublicRoomsRequestJson',
      'parseMatrixPublicRoomsResponseJson',
      'parseMatrixDirectoryVisibilityJson',
      'parseMatrixRoomAliasesJson',
      'parseMatrixInviteRequestJson',
      'parseMatrixInviteRoomJson',
      'parseMatrixRoomDirectoryErrorJson',
    ],
    'ts-protocol-core-wasm/src/index.ts': [
      '"SPEC-048"',
      'parseMatrixPublicRoomsRequest',
      'parseMatrixPublicRoomsResponse',
      'parseMatrixDirectoryVisibility',
      'parseMatrixRoomAliases',
      'parseMatrixInviteRequest',
      'parseMatrixInviteRoom',
      'parseMatrixRoomDirectoryError',
    ],
    'ts-protocol-core-wasm/test/index.test.mjs': [
      'SPEC-048',
      'matrix-public-rooms-basic.json',
      'matrix-public-rooms-filter-basic.json',
      'matrix-room-aliases-basic.json',
      'matrix-room-invite-basic.json',
    ],
  };
  for (final entry in requiredFragmentsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing SPEC-048 gate file: ${entry.key}');
      continue;
    }
    final source = file.readAsStringSync();
    for (final fragment in entry.value) {
      if (!source.contains(fragment)) {
        failures
            .add('${entry.key} is missing SPEC-048 gate fragment: $fragment');
      }
    }
  }
}

void checkVectorsHaveContract(
  List<String> failures,
  Directory specRoot,
  String specId,
  List<String> vectorPaths,
) {
  for (final vectorPath in vectorPaths) {
    final vector = File('${specRoot.path}/$vectorPath');
    if (!vector.existsSync()) {
      failures.add('Missing $specId canonical vector: ${vector.path}');
      continue;
    }
    final decoded = jsonDecode(vector.readAsStringSync());
    if (decoded is! Map<String, Object?> || decoded['contract'] != specId) {
      failures.add('$specId vector has an unexpected contract id: $vectorPath');
    }
  }
}

void checkRequiredFragments(
  List<String> failures, {
  required String specId,
  required Map<String, List<String>> requiredFragmentsByFile,
}) {
  for (final entry in requiredFragmentsByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing $specId gate file: ${entry.key}');
      continue;
    }
    final source = file.readAsStringSync();
    for (final fragment in entry.value) {
      if (!source.contains(fragment)) {
        failures
            .add('${entry.key} is missing $specId gate fragment: $fragment');
      }
    }
  }
}

void checkReleaseEvidenceAdoption(
  List<String> failures, {
  required String blockName,
  required int issue,
  required String specId,
  required List<String> parityVectors,
  required List<String> parserOnlySurfaces,
  required List<String> outOfScope,
}) {
  final evidence = readGeneratedReleaseEvidence(failures);
  if (evidence == null) {
    return;
  }
  final coveredSpecIds = evidence['covered_spec_ids'];
  if (coveredSpecIds is! List || !coveredSpecIds.contains(specId)) {
    failures.add('Release evidence covered_spec_ids is missing $specId.');
  }

  final adoption = evidence[blockName];
  if (adoption is! Map<String, Object?>) {
    failures.add('Release evidence is missing adoption block: $blockName');
    return;
  }
  if (adoption['issue'] != issue) {
    failures.add('$blockName issue must be $issue.');
  }
  if (adoption['status'] != 'parser-only-adopted') {
    failures.add('$blockName status must be parser-only-adopted.');
  }
  final specIds = adoption['spec_ids'];
  if (specIds is! List || !orderedListEquals(specIds, [specId])) {
    failures.add('$blockName spec_ids must be [$specId].');
  }
  requireListContainsAll(
    failures,
    adoption['parity_vectors'],
    parityVectors,
    '$blockName parity_vectors',
  );
  requireListContainsAll(
    failures,
    adoption['parser_only_surfaces'],
    parserOnlySurfaces,
    '$blockName parser_only_surfaces',
  );
  requireListContainsAll(
    failures,
    adoption['out_of_scope'],
    outOfScope,
    '$blockName out_of_scope',
  );
}

Map<String, Object?>? readGeneratedReleaseEvidence(List<String> failures) {
  if (_releaseEvidenceReadAttempted) {
    return _releaseEvidenceCache;
  }
  _releaseEvidenceReadAttempted = true;
  final tempRoot = Directory.systemTemp.createTempSync(
    'houra-labs-release-evidence-',
  );
  final output = File('${tempRoot.path}/release-evidence.json');
  try {
    final result = Process.runSync('dart', [
      'run',
      'tool/generate_release_evidence.dart',
      '--output',
      output.path,
    ]);
    if (result.exitCode != 0) {
      failures.add(
        'Release evidence generation failed: dart run tool/generate_release_evidence.dart --output ${output.path}',
      );
      addCommandOutput('stdout', result.stdout, failures);
      addCommandOutput('stderr', result.stderr, failures);
      return null;
    }
    final decoded = jsonDecode(output.readAsStringSync());
    if (decoded is Map<String, Object?>) {
      _releaseEvidenceCache = decoded;
      return decoded;
    }
    failures.add('Release evidence output must be a JSON object.');
    return null;
  } finally {
    tempRoot.deleteSync(recursive: true);
  }
}

void requireListContainsAll(
  List<String> failures,
  Object? actual,
  List<String> expected,
  String label,
) {
  if (actual is! List) {
    failures.add('$label must be a list.');
    return;
  }
  for (final value in expected) {
    if (!actual.contains(value)) {
      failures.add('$label is missing: $value');
    }
  }
}

bool orderedListEquals(List actual, List<String> expected) {
  if (actual.length != expected.length) {
    return false;
  }
  for (var index = 0; index < expected.length; index += 1) {
    if (actual[index] != expected[index]) {
      return false;
    }
  }
  return true;
}

Directory canonicalSpecRoot() {
  final fromEnv = Platform.environment['HOURA_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory('../houra-spec');
}

String resolveSpecReference(String path, Directory specRoot) {
  const siblingPrefix = '../houra-spec';
  if (path == siblingPrefix) {
    return specRoot.path;
  }
  if (path.startsWith('$siblingPrefix/')) {
    return '${specRoot.path}/${path.substring(siblingPrefix.length + 1)}';
  }
  return path;
}

Map<String, File> filesByRelativePath(Directory root) {
  final files = <String, File>{};
  for (final file in root.listSync(recursive: true).whereType<File>()) {
    files[relativePath(file, root)] = file;
  }
  return files;
}

Iterable<File> dartFilesUnder(Directory root) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String relativePath(FileSystemEntity entity, Directory root) {
  final rootPath = root.absolute.uri.path.endsWith('/')
      ? root.absolute.uri.path
      : '${root.absolute.uri.path}/';
  final entityPath = entity.absolute.uri.path;
  if (!entityPath.startsWith(rootPath)) {
    return Uri.decodeComponent(entityPath);
  }
  return Uri.decodeComponent(entityPath.substring(rootPath.length));
}

void addCommandOutput(String label, Object? output, List<String> failures) {
  final text = output?.toString().trim();
  if (text == null || text.isEmpty) {
    return;
  }
  failures.add('$label: ${text.split('\n').take(6).join(' | ')}');
}

String entityName(FileSystemEntity entity) {
  final segments = entity.uri.pathSegments.where(
    (segment) => segment.isNotEmpty,
  );
  if (segments.isEmpty) {
    return entity.path;
  }
  return segments.last;
}

bool isGeneratedEntry(String name) {
  return name == '.git' ||
      name == '.dart_tool' ||
      name == 'build' ||
      name == 'node_modules' ||
      name == 'pubspec.lock';
}
