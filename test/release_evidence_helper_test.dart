import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/release_evidence_helpers.dart';

void main() {
  test('crypto evidence helper redacts secret-bearing metadata', () {
    final evidence = buildCryptoEvidenceHelper(
      stackName: 'matrix-sdk-crypto',
      stackVersion: '0.0.0-test',
      platforms: ['ios', 'android'],
      artifactMetadata: {
        'private_key': 'do-not-emit',
        'nested': {
          'backup_secret': 'do-not-emit',
          'safe_label': 'kept',
        },
        'local_path': '/Users/example/Library/Keychains/private.key',
        'provider_token': 'do-not-emit',
      },
    );

    expect(evidence['spec_ids'], ['SPEC-079', 'SPEC-081']);
    expect(
      (evidence['redaction_policy']! as Map)['raw_secret_values_allowed'],
      isFalse,
    );
    expect(
      (evidence['artifact_metadata']! as Map)['private_key'],
      cryptoEvidenceRedactionMarker,
    );
    expect(
      ((evidence['artifact_metadata']! as Map)['nested']!
          as Map)['backup_secret'],
      cryptoEvidenceRedactionMarker,
    );
    expect(
      ((evidence['artifact_metadata']! as Map)['nested']! as Map)['safe_label'],
      'kept',
    );
    expect(
      (evidence['artifact_metadata']! as Map)['local_path'],
      cryptoEvidenceRedactionMarker,
    );
    expect(
      (evidence['artifact_metadata']! as Map)['provider_token'],
      cryptoEvidenceRedactionMarker,
    );
  });

  test('release evidence generation includes fail-closed crypto helper', () {
    final result = Process.runSync('dart', [
      'run',
      'tool/generate_release_evidence.dart',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final decoded =
        jsonDecode(result.stdout.toString()) as Map<String, Object?>;
    final adoption =
        decoded['crypto_evidence_helper_adoption']! as Map<String, Object?>;

    expect(adoption['issue'], 133);
    expect(adoption['spec_ids'], ['SPEC-079', 'SPEC-081']);
    expect(
      (adoption['advertisement']! as Map)['e2ee_support_widened'],
      isFalse,
    );
    expect(
      (adoption['redaction_policy']! as Map)['local_secret_paths_allowed'],
      isFalse,
    );
  });

  test('release evidence generation includes benchmark harness metadata', () {
    final result = Process.runSync('dart', [
      'run',
      'tool/generate_release_evidence.dart',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final decoded =
        jsonDecode(result.stdout.toString()) as Map<String, Object?>;
    final benchmark =
        decoded['shared_core_benchmark_harness']! as Map<String, Object?>;

    expect(benchmark['issue'], 161);
    expect(benchmark['redaction'], 'metadata-only-no-raw-requests-or-secrets');
    expect(benchmark['summary_fields'], contains('p95_microseconds'));
    expect(
      benchmark['claim_boundaries'],
      contains('no production TypeScript client/server adoption'),
    );
    expect(
      benchmark['measured_surfaces'],
      contains(
        isA<Map>().having(
          (surface) => surface['surface_kind'],
          'surface_kind',
          'typescript-facade-baseline',
        ),
      ),
    );
    expect(
      benchmark['measured_surfaces'],
      contains(
        isA<Map>()
            .having(
              (surface) => surface['surface_kind'],
              'surface_kind',
              'typescript-facade-baseline',
            )
            .having(
              (surface) => surface['command'].toString(),
              'command',
              contains('npm --silent run benchmark'),
            ),
      ),
    );
    expect(
      benchmark['optional_surfaces'],
      contains(
        isA<Map>()
            .having(
              (surface) => surface['surface_kind'],
              'surface_kind',
              'go-server-candidate',
            )
            .having(
              (surface) => surface['status'],
              'status',
              'optional_not_implemented',
            ),
      ),
    );
  });

  test('benchmark harness can emit Dart-only metadata without raw payloads',
      () {
    final result = Process.runSync('dart', [
      'run',
      'tool/benchmark_shared_core.dart',
      '--iterations',
      '5',
      '--no-external',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final decoded =
        jsonDecode(result.stdout.toString()) as Map<String, Object?>;
    final results = decoded['results']! as List;

    expect(decoded['redaction'], 'metadata-only-no-raw-requests-or-secrets');
    expect(decoded.containsKey('raw_request'), isFalse);
    expect(decoded.containsKey('prompt'), isFalse);
    expect(decoded.containsKey('token'), isFalse);
    expect(
      results,
      contains(
        isA<Map>()
            .having(
              (surface) => surface['surface_kind'],
              'surface_kind',
              'dart-json-baseline',
            )
            .having((surface) => surface['status'], 'status', 'measured')
            .having(
              (surface) => surface['p95_microseconds'],
              'p95_microseconds',
              isA<int>(),
            ),
      ),
    );
    expect(
      results,
      contains(
        isA<Map>().having(
          (surface) => surface['surface_kind'],
          'surface_kind',
          'go-server-candidate',
        ),
      ),
    );
  });

  test('benchmark harness rejects non-positive iteration counts', () {
    final result = Process.runSync('dart', [
      'run',
      'tool/benchmark_shared_core.dart',
      '--iterations',
      '0',
      '--no-external',
    ]);

    expect(result.exitCode, isNot(0));
    expect(result.stderr.toString(), contains('--iterations must be positive'));
  });
}
