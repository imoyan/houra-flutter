import 'dart:io';

const flutterSdkBaseSpecIds = [
  'SPEC-001',
  'SPEC-003',
  'SPEC-004',
  'SPEC-006',
  'SPEC-007',
  'SPEC-008',
  'SPEC-009',
  'SPEC-010',
  'SPEC-011',
  'SPEC-020',
];

const protocolCoreManifestSpecIds = [
  'SPEC-030',
  'SPEC-031',
  'SPEC-032',
  'SPEC-033',
  'SPEC-034',
  'SPEC-035',
  'SPEC-036',
  'SPEC-037',
  'SPEC-038',
  'SPEC-039',
  'SPEC-040',
  'SPEC-045',
  'SPEC-046',
  'SPEC-047',
  'SPEC-048',
  'SPEC-049',
  'SPEC-051',
  'SPEC-053',
  'SPEC-054',
  'SPEC-055',
  'SPEC-056',
  'SPEC-057',
  'SPEC-068',
  'SPEC-069',
  'SPEC-085',
  'SPEC-090',
  'SPEC-093',
  'SPEC-095',
  'SPEC-097',
];

const releaseEvidenceSpecIds = [
  ...protocolCoreManifestSpecIds,
  'SPEC-079',
  'SPEC-081',
  'SPEC-058',
  'SPEC-075',
  'SPEC-059',
  'SPEC-076',
  'SPEC-098',
  'SPEC-099',
  'SPEC-100',
  'SPEC-078',
  'SPEC-083',
];

const conformanceCoverageSchemaVersion = 1;
const conformanceCoverageReportKind = 'houra-labs-conformance-coverage';

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

Map<String, Object?> buildConformanceCoverageReport({
  required Iterable<String> flutterSdkSpecIds,
  Iterable<String> protocolCoreSpecIds = protocolCoreManifestSpecIds,
  Iterable<String> releaseSpecIds = releaseEvidenceSpecIds,
}) {
  final flutterSpecs = sortedSpecIds(flutterSdkSpecIds);
  final protocolSpecs = sortedSpecIds(protocolCoreSpecIds);
  final evidenceSpecs = releaseSpecIds.toList(growable: false);
  return {
    'schema_version': conformanceCoverageSchemaVersion,
    'report_kind': conformanceCoverageReportKind,
    'redaction': 'metadata-only-no-raw-requests-or-secrets',
    'normative_source':
        '../houra-spec/contracts and ../houra-spec/test-vectors',
    'generated_by': 'tool/generate_release_evidence.dart',
    'surfaces': [
      _coverageSurface(
        surfaceKind: 'flutter-sdk',
        supportClaimStatus:
            'claimed-with-contract-tests-and-readme-adoption-records',
        specIds: flutterSpecs,
        sourceFiles: [
          'lib/',
          'test/*_contract_test.dart',
          'README.md',
        ],
        testGates: [
          'HOURA_SPEC_ROOT=../houra-spec flutter test',
          'HOURA_SPEC_ROOT=../houra-spec dart run tool/check_spec_sync.dart',
        ],
      ),
      _coverageSurface(
        surfaceKind: 'rust-protocol-core-manifest',
        supportClaimStatus: 'manifest-and-parser-evidence-only',
        specIds: protocolSpecs,
        sourceFiles: [
          'rust-protocol-core/src/lib.rs',
          'rust-protocol-core/Cargo.toml',
        ],
        testGates: [
          'cd rust-protocol-core && HOURA_SPEC_ROOT=../../houra-spec cargo test',
        ],
      ),
      _coverageSurface(
        surfaceKind: 'rust-wasm-wrapper-exports',
        supportClaimStatus: 'thin-binding-wrapper-metadata-only',
        specIds: protocolSpecs,
        sourceFiles: [
          'rust-protocol-core-wasm/src/lib.rs',
          'rust-protocol-core-wasm/Cargo.toml',
        ],
        testGates: [
          'cd rust-protocol-core-wasm && cargo test',
          'cd rust-protocol-core-wasm && cargo build --target wasm32-unknown-unknown',
        ],
      ),
      _coverageSurface(
        surfaceKind: 'typescript-wasm-facade',
        supportClaimStatus: 'private-package-facade-metadata-only',
        specIds: protocolSpecs,
        sourceFiles: [
          'ts-protocol-core-wasm/src/index.ts',
          'ts-protocol-core-wasm/test/index.test.mjs',
          'ts-protocol-core-wasm/package.json',
        ],
        testGates: [
          'cd ts-protocol-core-wasm && npm run typecheck',
          'cd ts-protocol-core-wasm && npm test',
        ],
      ),
      _coverageSurface(
        surfaceKind: 'release-evidence',
        supportClaimStatus: 'metadata-only-release-gate',
        specIds: evidenceSpecs,
        sourceFiles: [
          'tool/generate_release_evidence.dart',
          'tool/check_spec_sync.dart',
          'tool/release_evidence_helpers.dart',
        ],
        testGates: [
          'HOURA_SPEC_ROOT=../houra-spec dart run tool/generate_release_evidence.dart --output build/release-evidence/houra-labs-release-evidence.json',
          'HOURA_SPEC_ROOT=../houra-spec dart run tool/check_spec_sync.dart',
        ],
      ),
    ],
    'drift_guards': [
      {
        'guard': 'readme_flutter_sdk_claim',
        'source_file': 'README.md',
        'test_gate':
            'HOURA_SPEC_ROOT=../houra-spec dart run tool/check_spec_sync.dart',
      },
      {
        'guard': 'dart_contract_test_spec_ids',
        'source_file': 'test/*_contract_test.dart',
        'test_gate': 'HOURA_SPEC_ROOT=../houra-spec flutter test',
      },
      {
        'guard': 'typescript_facade_spec_constants',
        'source_file': 'ts-protocol-core-wasm/src/index.ts',
        'test_gate':
            'HOURA_SPEC_ROOT=../houra-spec dart run tool/generate_release_evidence.dart',
      },
      {
        'guard': 'release_evidence_coverage_report',
        'source_file': 'tool/release_evidence_helpers.dart',
        'test_gate':
            'HOURA_SPEC_ROOT=../houra-spec dart run tool/check_spec_sync.dart',
      },
    ],
    'non_normative': true,
  };
}

Map<String, Object?> _coverageSurface({
  required String surfaceKind,
  required String supportClaimStatus,
  required List<String> specIds,
  required List<String> sourceFiles,
  required List<String> testGates,
}) {
  return {
    'surface_kind': surfaceKind,
    'support_claim_status': supportClaimStatus,
    'spec_ids': specIds,
    'source_files': sourceFiles,
    'test_gates': testGates,
  };
}

List<String> readDartContractTestSpecIds({Directory? testRoot}) {
  final root = testRoot ?? Directory('test');
  if (!root.existsSync()) {
    return const [];
  }

  final specIds = <String>{};
  for (final file in root.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('_contract_test.dart')) {
      continue;
    }
    specIds.addAll(uniqueSpecIdsFromText(file.readAsStringSync()));
  }
  return sortedSpecIds(specIds);
}

List<String> sortedSpecIds(Iterable<String> specIds) {
  final ordered = specIds.toList()..sort(compareSpecIds);
  return ordered;
}

List<String> uniqueSpecIdsFromText(String source) {
  final specPattern = RegExp(r'\bSPEC-\d{3}\b');
  final seen = <String>{};
  final specIds = <String>[];
  for (final match in specPattern.allMatches(source)) {
    final specId = match.group(0)!;
    if (seen.add(specId)) {
      specIds.add(specId);
    }
  }
  return specIds;
}

int compareSpecIds(String left, String right) {
  final leftValue = int.parse(left.substring('SPEC-'.length));
  final rightValue = int.parse(right.substring('SPEC-'.length));
  return leftValue.compareTo(rightValue);
}

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
