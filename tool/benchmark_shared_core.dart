import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final iterations = _readIntOption(args, '--iterations') ?? 200;
  if (iterations <= 0) {
    stderr.writeln('--iterations must be positive.');
    exitCode = 64;
    return;
  }
  final outputPath = _readStringOption(args, '--output');
  final includeExternal = !args.contains('--no-external');
  final specRoot = Platform.environment['HOURA_SPEC_ROOT'] ?? '../houra-spec';
  final childSpecRoot = Directory(specRoot).absolute.path;
  final vectorPath = _matrixClientVersionsVectorPath();
  final vectorFile = File('$specRoot/$vectorPath');
  if (!vectorFile.existsSync()) {
    stderr.writeln('Missing benchmark vector: ${vectorFile.path}');
    exitCode = 1;
    return;
  }

  final vector = jsonDecode(vectorFile.readAsStringSync());
  if (vector is! Map<String, Object?> || vector['contract'] != 'SPEC-030') {
    stderr.writeln('Benchmark vector must be a SPEC-030 JSON object.');
    exitCode = 1;
    return;
  }
  final expected = _requiredObject(vector, 'expected');
  final body = _requiredObject(expected, 'body_contains');
  final payload = jsonEncode(body);
  final payloadBytes = utf8.encode(payload).length;

  final results = <Map<String, Object?>>[
    _measureDartJsonBaseline(
      payload,
      iterations: iterations,
      payloadBytes: payloadBytes,
      vectorPath: vectorPath,
    ),
  ];
  if (includeExternal) {
    results.add(
      _runJsonBenchmark(
        surfaceKind: 'rust-native',
        command: [
          'cargo',
          'run',
          '--quiet',
          '--bin',
          'benchmark_shared_core',
          '--',
          '--iterations',
          '$iterations',
          '--json',
        ],
        workingDirectory: 'rust-protocol-core',
        environment: {'HOURA_SPEC_ROOT': childSpecRoot},
      ),
    );
    results.add(
      _runJsonBenchmark(
        surfaceKind: 'typescript-facade-baseline',
        command: [
          'npm',
          '--silent',
          'run',
          'benchmark',
          '--',
          '--iterations',
          '$iterations',
          '--json',
        ],
        workingDirectory: 'ts-protocol-core-wasm',
        environment: {'HOURA_SPEC_ROOT': childSpecRoot},
      ),
    );
    results.add(
      _runJsonBenchmark(
        surfaceKind: 'go-server-candidate',
        command: [
          'go',
          'run',
          './cmd/benchmark_shared_core',
          '--iterations',
          '$iterations',
          '--json',
        ],
        workingDirectory: 'go-protocol-core',
        environment: {'HOURA_SPEC_ROOT': childSpecRoot},
      ),
    );
  } else {
    results.addAll([
      _skippedSurface('rust-native', 'external command disabled'),
      _skippedSurface(
          'typescript-facade-baseline', 'external command disabled'),
      _skippedSurface('go-server-candidate', 'external command disabled'),
    ]);
  }

  final report = {
    'schema_version': 1,
    'evidence_kind': 'houra-labs-shared-core-benchmark',
    'redaction': 'metadata-only-no-raw-requests-or-secrets',
    'normative_source':
        '../houra-spec/contracts and ../houra-spec/test-vectors',
    'benchmark_vector': vectorPath,
    'iterations': iterations,
    'payload': {
      'bytes': payloadBytes,
      'json_top_level_keys': body.keys.toList()..sort(),
    },
    'results': results,
    'artifact_size_notes': [
      {
        'surface_kind': 'typescript-facade-baseline',
        'command': 'cd ts-protocol-core-wasm && npm run pack:dry-run',
        'output_policy': 'record package size metadata only',
      },
      {
        'surface_kind': 'rust-wasm-wrapper-exports',
        'command':
            'cd rust-protocol-core-wasm && cargo build --locked --release --target wasm32-unknown-unknown',
        'output_policy': 'record artifact size metadata only',
      },
    ],
    'out_of_scope': [
      'raw request bodies in benchmark reports',
      'prompt, token, or secret capture',
      'production TypeScript client/server shared-core adoption',
      'production Go server adoption',
      'public compatibility claim expansion',
    ],
  };

  final encoded = const JsonEncoder.withIndent('  ').convert(report);
  if (outputPath == null) {
    stdout.writeln(encoded);
    return;
  }
  final output = File(outputPath);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync('$encoded\n');
}

Map<String, Object?> _measureDartJsonBaseline(
  String payload, {
  required int iterations,
  required int payloadBytes,
  required String vectorPath,
}) {
  final samples = <int>[];
  for (var index = 0; index < iterations; index += 1) {
    final stopwatch = Stopwatch()..start();
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Expected Matrix versions object.');
    }
    _readMatrixVersions(decoded);
    stopwatch.stop();
    samples.add(stopwatch.elapsedMicroseconds);
  }
  return _timingResult(
    surfaceKind: 'dart-json-baseline',
    language: 'dart',
    supportClaimStatus: 'benchmark-baseline-only',
    vectorPath: vectorPath,
    payloadBytes: payloadBytes,
    samples: samples,
  );
}

Map<String, Object?> _runJsonBenchmark({
  required String surfaceKind,
  required List<String> command,
  required String workingDirectory,
  required Map<String, String> environment,
}) {
  try {
    final result = Process.runSync(
      command.first,
      command.skip(1).toList(growable: false),
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: true,
    );
    if (result.exitCode != 0) {
      return {
        'surface_kind': surfaceKind,
        'status': 'unavailable',
        'command': command.join(' '),
        'exit_code': result.exitCode,
        'stderr_summary': _summarize(result.stderr),
      };
    }
    final decoded = jsonDecode(result.stdout.toString());
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    return {
      'surface_kind': surfaceKind,
      'status': 'unavailable',
      'command': command.join(' '),
      'stderr_summary': 'benchmark did not return a JSON object',
    };
  } on ProcessException catch (error) {
    return {
      'surface_kind': surfaceKind,
      'status': 'unavailable',
      'command': command.join(' '),
      'stderr_summary': error.message,
    };
  } on FormatException catch (error) {
    return {
      'surface_kind': surfaceKind,
      'status': 'unavailable',
      'command': command.join(' '),
      'stderr_summary': error.message,
    };
  }
}

Map<String, Object?> _timingResult({
  required String surfaceKind,
  required String language,
  required String supportClaimStatus,
  required String vectorPath,
  required int payloadBytes,
  required List<int> samples,
}) {
  samples.sort();
  return {
    'surface_kind': surfaceKind,
    'language': language,
    'status': 'measured',
    'support_claim_status': supportClaimStatus,
    'benchmark_id': 'spec-030-versions-parse',
    'spec_id': 'SPEC-030',
    'vector': vectorPath,
    'payload_bytes': payloadBytes,
    'iterations': samples.length,
    'min_microseconds': samples.first,
    'median_microseconds': _percentile(samples, 0.50),
    'p95_microseconds': _percentile(samples, 0.95),
    'max_microseconds': samples.last,
  };
}

Map<String, Object?> _skippedSurface(String surfaceKind, String reason) {
  return {
    'surface_kind': surfaceKind,
    'status': 'skipped',
    'reason': reason,
  };
}

List<String> _readMatrixVersions(Map<String, Object?> json) {
  final value = json['versions'];
  if (value is! List || value.isEmpty) {
    throw const FormatException('Expected non-empty Matrix versions list.');
  }
  return [
    for (final item in value)
      if (item is String && item.isNotEmpty)
        item
      else
        throw const FormatException('Invalid Matrix version entry.'),
  ];
}

int _percentile(List<int> sortedSamples, double percentile) {
  if (sortedSamples.isEmpty) {
    return 0;
  }
  final index = ((sortedSamples.length - 1) * percentile).ceil();
  return sortedSamples[index];
}

Map<String, Object?> _requiredObject(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  throw FormatException('Expected object field "$key".');
}

String _summarize(Object? output) {
  final text = output?.toString().trim() ?? '';
  if (text.isEmpty) {
    return '';
  }
  return text.split('\n').take(6).join(' | ');
}

String _matrixClientVersionsVectorPath() {
  return ['test-vectors/core/matrix', 'client-versions-basic.json'].join('-');
}

int? _readIntOption(List<String> args, String name) {
  final value = _readStringOption(args, name);
  return value == null ? null : int.parse(value);
}

String? _readStringOption(List<String> args, String name) {
  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    if (arg == name && index + 1 < args.length) {
      return args[index + 1];
    }
    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }
  }
  return null;
}
