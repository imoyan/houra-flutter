import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'vector_test_support.dart';

void main() {
  test('reports a descriptive failure when canonical spec root is missing', () {
    final missingRoot = Directory.systemTemp.createTempSync(
      'houra_missing_spec_root_',
    );
    missingRoot.deleteSync();

    expect(
      () => requireCanonicalSpecRoot(
        environment: const {},
        defaultPath: missingRoot.path,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          allOf(
            contains('Canonical houra-spec checkout not found'),
            contains('HOURA_SPEC_ROOT'),
          ),
        ),
      ),
    );
  });

  test('reports a descriptive failure when canonical vectors are missing', () {
    final root = Directory.systemTemp.createTempSync('houra_wrong_spec_root_');
    addTearDown(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    expect(
      () => requireCanonicalSpecRoot(
        environment: const {},
        defaultPath: root.path,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          allOf(contains('missing test-vectors/'), contains('HOURA_SPEC_ROOT')),
        ),
      ),
    );
  });

  test('required canonical spec files exist next to houra', () {
    final root = requireCanonicalSpecRoot();
    expect(root.existsSync(), isTrue);
    final requiredFiles = [
      'contracts/SPEC-001-discovery-versions.md',
      'contracts/SPEC-002-error-model.md',
      'contracts/SPEC-003-login-flow-discovery.md',
      'contracts/SPEC-004-login-session.md',
      'contracts/SPEC-006-room-model.md',
      'contracts/SPEC-007-event-model.md',
      'contracts/SPEC-008-send-message.md',
      'contracts/SPEC-009-room-list.md',
      'contracts/SPEC-010-timeline.md',
      'contracts/SPEC-011-basic-sync.md',
      'contracts/SPEC-020-media.md',
      'test-vectors/core/versions-basic.json',
      'test-vectors/core/error-basic.json',
      'test-vectors/auth/login-flows-basic.json',
      'test-vectors/auth/password-login-basic.json',
      'test-vectors/auth/whoami-basic.json',
      'test-vectors/auth/logout-basic.json',
      'test-vectors/auth/auth-error-basic.json',
      'test-vectors/rooms/create-room-basic.json',
      'test-vectors/rooms/join-room-basic.json',
      'test-vectors/rooms/leave-room-basic.json',
      'test-vectors/rooms/room-state-basic.json',
      'test-vectors/events/event-basic.json',
      'test-vectors/events/bad-event-payload.json',
      'test-vectors/messaging/send-text-basic.json',
      'test-vectors/sync/room-list-basic.json',
      'test-vectors/sync/timeline-basic.json',
      'test-vectors/sync/basic-sync.json',
      'test-vectors/media/upload-basic.json',
      'test-vectors/media/download-metadata-basic.json',
    ];
    for (final path in requiredFiles) {
      expect(File('${root.path}/$path').existsSync(), isTrue, reason: path);
    }
  });

  test('bundled theme files match canonical spec design files', () {
    final root = requireCanonicalSpecRoot();
    final pairs = {
      'design/theme.schema.json': '${root.path}/design/theme.schema.json',
      'design/themes/smoke.json': '${root.path}/design/themes/smoke.json',
    };

    for (final entry in pairs.entries) {
      expect(
        File(entry.key).readAsStringSync(),
        File(entry.value).readAsStringSync(),
        reason: '${entry.key} must match ${entry.value}',
      );
    }
  });
}
