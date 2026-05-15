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
}
