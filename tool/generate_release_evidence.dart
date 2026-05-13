import 'dart:convert';
import 'dart:io';

const expectedSpecIds = [
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
];

void main(List<String> args) {
  final outputPath = _readOutputPath(args);
  final failures = <String>[];

  final rustCore = _readCargoPackage(File('rust-protocol-core/Cargo.toml'));
  final rustWasm = _readCargoPackage(
    File('rust-protocol-core-wasm/Cargo.toml'),
  );
  final tsPackage = _readJsonObject(File('ts-protocol-core-wasm/package.json'));
  final tsConstants =
      _readTsConstants(File('ts-protocol-core-wasm/src/index.ts'));

  _expect(
    failures,
    rustCore['name'] == tsConstants['crateName'],
    'Rust crate name and TypeScript facade crate constant differ.',
  );
  _expect(
    failures,
    rustCore['version'] == tsConstants['crateVersion'],
    'Rust crate version and TypeScript facade crate version constant differ.',
  );
  _expect(
    failures,
    _listEquals(tsConstants['specIds'] as List<String>, expectedSpecIds),
    'TypeScript facade SPEC coverage must exactly match the release gate list.',
  );
  _expect(
    failures,
    tsPackage['private'] == true,
    'TypeScript package must remain private until a publish issue removes it.',
  );
  _expect(
    failures,
    tsPackage['name'] == '@houra/protocol-core-wasm-facade',
    'TypeScript package name changed without updating release evidence.',
  );
  _expect(
    failures,
    (tsPackage['files'] as List).length == 1 &&
        (tsPackage['files'] as List).single == 'dist/',
    'TypeScript package must publish only dist/ until artifact packaging changes.',
  );

  final specRoot = _canonicalSpecRoot();
  final specRef = _gitRevParse(specRoot.path) ??
      Platform.environment['HOURA_SPEC_REF'] ??
      'unknown';
  final headSha = _gitRevParse(Directory.current.path) ?? 'unknown';

  final evidence = {
    'evidence_schema_version': 1,
    'evidence_kind': 'houra-labs-shared-core-release-gate',
    'redaction': 'metadata-only-no-raw-requests-or-secrets',
    'head_sha': headSha,
    'spec_snapshot_ref': specRef,
    'covered_spec_ids': expectedSpecIds,
    'protocol_core': {
      'crate_name': rustCore['name'],
      'crate_version': rustCore['version'],
      'abi_version': tsConstants['abiVersion'],
      'manifest_schema_version': tsConstants['manifestSchemaVersion'],
      'protocol_boundary': tsConstants['protocolBoundary'],
      'binding_kinds': [tsConstants['wasmBindingKind']],
      'publish': rustCore['publish'],
    },
    'wasm_wrapper': {
      'crate_name': rustWasm['name'],
      'crate_version': rustWasm['version'],
      'publish': rustWasm['publish'],
      'target': 'wasm32-unknown-unknown',
    },
    'typescript_facade': {
      'package_name': tsPackage['name'],
      'package_version': tsPackage['version'],
      'private': tsPackage['private'],
      'exports': tsPackage['exports'],
      'files': tsPackage['files'],
      'side_effects': tsPackage['sideEffects'],
      'primary_runtime_target': 'browser-esm',
      'secondary_facade_targets': ['next', 'vue'],
      'node_runtime_status': 'package-validation-and-tests-only',
    },
    'checks': [
      {
        'name': 'spec-sync',
        'command': 'dart run tool/check_spec_sync.dart',
        'guards': [
          'canonical spec checkout exists',
          'canonical spec check passes',
          'design bundle matches canonical design',
          'SPEC-039 integration gate references are present',
          'SPEC-040 event DAG/auth event vector references are present',
        ],
      },
      {
        'name': 'rust-protocol-core',
        'command': 'cargo test --locked',
        'guards': [
          'artifact manifest serializes stably',
          'covered SPEC ids include SPEC-030 through SPEC-040',
        ],
      },
      {
        'name': 'wasm-wrapper',
        'command': 'cargo build --locked --target wasm32-unknown-unknown',
        'guards': [
          'WASM binding kind is present in the manifest',
          'wrapper exports the manifest and JSON envelope functions',
        ],
      },
      {
        'name': 'typescript-facade',
        'command': 'npm run typecheck && npm test && npm run pack:dry-run',
        'guards': [
          'manifest compatibility fails closed',
          'release evidence stays metadata-only',
          'package dry run excludes generated WASM artifacts',
        ],
      },
    ],
    'candidate_thresholds': {
      'wasm_binary_max_bytes': 262144,
      'typescript_package_tarball_max_bytes': 65536,
      'p95_parse_validation_overhead_ms': 5,
      'ci_runtime_target_minutes': {
        'flutter_sdk_checks': 10,
        'rust_protocol_core_checks': 10,
        'ts_wasm_facade_checks': 5,
        'release_evidence_gate': 2,
      },
    },
    'local_ci_status_requirements': {
      'status_context': 'local-ci',
      'required_fields': [
        'head_sha',
        'commands',
        'result',
        'spec_snapshot_ref'
      ],
      'allowed_only_when': [
        'the recorded head_sha matches the PR head SHA',
        'commands cover the changed package surfaces',
        'the PR body or handoff records commands and success result',
      ],
    },
  };

  if (failures.isNotEmpty) {
    stderr.writeln('Release evidence gate failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  final encoded = const JsonEncoder.withIndent('  ').convert(evidence);
  if (outputPath == null) {
    stdout.writeln(encoded);
    return;
  }

  final output = File(outputPath);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync('$encoded\n');
}

String? _readOutputPath(List<String> args) {
  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    if (arg == '--output' && index + 1 < args.length) {
      return args[index + 1];
    }
    if (arg.startsWith('--output=')) {
      return arg.substring('--output='.length);
    }
  }
  return null;
}

Map<String, Object?> _readCargoPackage(File file) {
  final source = file.readAsStringSync();
  final packageSource = source.split(RegExp(r'\n\[')).first;
  return {
    'name': _readTomlString(packageSource, 'name'),
    'version': _readTomlString(packageSource, 'version'),
    'publish': _readTomlBool(packageSource, 'publish'),
  };
}

Map<String, Object?> _readJsonObject(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    throw FormatException('${file.path} must contain a JSON object.');
  }
  return decoded;
}

Map<String, Object?> _readTsConstants(File file) {
  final source = file.readAsStringSync();
  return {
    'abiVersion': _readTsNumber(source, 'HOURA_PROTOCOL_CORE_ABI_VERSION'),
    'manifestSchemaVersion': _readTsNumber(
      source,
      'HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION',
    ),
    'crateName': _readTsString(source, 'HOURA_PROTOCOL_CORE_CRATE_NAME'),
    'crateVersion': _readTsString(source, 'HOURA_PROTOCOL_CORE_CRATE_VERSION'),
    'protocolBoundary': _readTsString(
      source,
      'HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY',
    ),
    'wasmBindingKind': _readTsString(
      source,
      'HOURA_PROTOCOL_CORE_WASM_BINDING_KIND',
    ),
    'specIds': _readTsStringArray(source, 'HOURA_PROTOCOL_CORE_SPEC_IDS'),
  };
}

String _readTomlString(String source, String key) {
  final match = RegExp('^$key = "([^"]+)"', multiLine: true).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TOML string key: $key');
  }
  return match.group(1)!;
}

bool _readTomlBool(String source, String key) {
  final match =
      RegExp('^$key = (true|false)', multiLine: true).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TOML boolean key: $key');
  }
  return match.group(1) == 'true';
}

int _readTsNumber(String source, String name) {
  final match = RegExp('const $name = ([0-9]+);').firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript numeric constant: $name');
  }
  return int.parse(match.group(1)!);
}

String _readTsString(String source, String name) {
  final match = RegExp('const $name = "([^"]+)";').firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript string constant: $name');
  }
  return match.group(1)!;
}

List<String> _readTsStringArray(String source, String name) {
  final match = RegExp(
    'const $name = \\[(.*?)\\] as const;',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript string array constant: $name');
  }
  return RegExp('"([^"]+)"')
      .allMatches(match.group(1)!)
      .map((match) => match.group(1)!)
      .toList();
}

Directory _canonicalSpecRoot() {
  final fromEnv = Platform.environment['HOURA_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory('../houra-spec');
}

String? _gitRevParse(String workingDirectory) {
  final result = Process.runSync(
    'git',
    ['rev-parse', 'HEAD'],
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    return null;
  }
  return result.stdout.toString().trim();
}

void _expect(List<String> failures, bool condition, String message) {
  if (!condition) {
    failures.add(message);
  }
}

bool _listEquals(List<String> actual, List<String> expected) {
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
