import 'dart:convert';
import 'dart:io';

import 'release_evidence_helpers.dart';

const expectedProtocolSpecIds = [
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

const expectedReleaseEvidenceSpecIds = [
  ...expectedProtocolSpecIds,
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

void main(List<String> args) {
  final outputPath = _readOutputPath(args);
  final failures = <String>[];

  final rustCore = _readCargoPackage(File('rust-protocol-core/Cargo.toml'));
  final rustWasm = _readCargoPackage(
    File('rust-protocol-core-wasm/Cargo.toml'),
  );
  final tsPackage = _readJsonObject(File('ts-protocol-core-wasm/package.json'));
  final tsConstants = _readTsConstants(
    File('ts-protocol-core-wasm/src/index.ts'),
  );

  _expect(
    failures,
    rustCore['name'] == tsConstants['crateName'],
    'Rust crate name and TypeScript facade crate constant differ.',
  );
  _expect(
    failures,
    rustCore['description'] ==
        'Rust lab prototype for shared Houra protocol parsing and validation.',
    'Rust crate description changed without updating release evidence.',
  );
  _expect(
    failures,
    rustCore['license'] == 'Apache-2.0',
    'Rust crate license must stay Apache-2.0.',
  );
  _expect(
    failures,
    rustCore['repository'] == 'https://github.com/imoyan/houra-labs',
    'Rust crate repository metadata must point at houra-labs.',
  );
  _expect(
    failures,
    rustCore['readme'] == 'README.md',
    'Rust crate readme metadata must point at the crate README.',
  );
  _expect(
    failures,
    rustCore['documentation'] == 'https://docs.rs/houra-protocol-core',
    'Rust crate docs.rs metadata must match the package name.',
  );
  _expect(
    failures,
    rustCore['version'] == tsConstants['crateVersion'],
    'Rust crate version and TypeScript facade crate version constant differ.',
  );
  _expect(
    failures,
    _listEquals(
      tsConstants['specIds'] as List<String>,
      expectedProtocolSpecIds,
    ),
    'TypeScript facade SPEC coverage must exactly match the protocol artifact list.',
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
  final tsScripts = tsPackage['scripts'];
  _expect(
    failures,
    tsScripts is Map &&
        tsScripts['benchmark'] == 'npm run build && node benchmark.mjs',
    'TypeScript package benchmark script changed without updating release evidence.',
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
    'spec_snapshot_policy': {
      'issue': 136,
      'status': 'current-generation-single-snapshot',
      'generated_snapshot_ref': specRef,
      'semantics': [
        'spec_snapshot_ref records the configured canonical spec checkout used when this evidence was generated',
        'README adoption records may include historical spec refs from the adoption PR that introduced the surface',
        'release notes must explain any intentional historical/current snapshot mix before using this artifact as a release anchor',
      ],
      'release_anchor_checks': [
        'rerun this script from the release head with the intended HOURA_SPEC_ROOT',
        'confirm covered_spec_ids and adoption blocks still match the intended spec snapshot',
        'split any snapshot drift into a dedicated revalidation issue before publication',
      ],
    },
    'covered_spec_ids': expectedReleaseEvidenceSpecIds,
    'protocol_core': {
      'crate_name': rustCore['name'],
      'crate_version': rustCore['version'],
      'description': rustCore['description'],
      'license': rustCore['license'],
      'repository': rustCore['repository'],
      'documentation': rustCore['documentation'],
      'readme': rustCore['readme'],
      'keywords': rustCore['keywords'],
      'categories': rustCore['categories'],
      'abi_version': tsConstants['abiVersion'],
      'manifest_schema_version': tsConstants['manifestSchemaVersion'],
      'protocol_boundary': tsConstants['protocolBoundary'],
      'binding_kinds': [tsConstants['wasmBindingKind']],
      'publish': rustCore['publish'],
      'docs_rs': rustCore['docs_rs'],
      'publish_readiness': {
        'issue': 79,
        'status': 'checklist-only-publish-deferred',
        'package_contents_check': 'cargo package --list',
        'dry_run_check': 'cargo publish --dry-run',
        'expected_contents': [
          'crate metadata',
          'rust-protocol-core README',
          'source files',
          'Cargo lock metadata needed for reproducible checks',
        ],
        'blocked_until': [
          'crate ownership and final package name are confirmed',
          'publish = false is removed in a focused release PR',
          'docs.rs API surface is reviewed against the lab boundary',
          'cargo package --list passes on the release head',
          'cargo publish --dry-run passes on the release head',
        ],
        'claim_boundaries': [
          'no Matrix compatibility claim',
          'no server or client behavior claim',
          'no storage, crypto, or federation ownership claim',
        ],
      },
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
    'shared_core_benchmark_harness': {
      'issue': 161,
      'status': 'candidate-evidence-harness-added',
      'redaction': 'metadata-only-no-raw-requests-or-secrets',
      'benchmark_command':
          'HOURA_SPEC_ROOT=../houra-spec dart run tool/benchmark_shared_core.dart --iterations 200 --output build/benchmarks/shared-core-benchmark.json',
      'benchmark_vector': 'SPEC-030 versions vector',
      'measured_surfaces': [
        {
          'surface_kind': 'typescript-facade-baseline',
          'role': 'current production path baseline',
          'command':
              'cd ts-protocol-core-wasm && HOURA_SPEC_ROOT=../../houra-spec npm --silent run benchmark -- --iterations 200 --json',
        },
        {
          'surface_kind': 'rust-native',
          'role': 'shared protocol core candidate',
          'command':
              'cd rust-protocol-core && HOURA_SPEC_ROOT=../../houra-spec cargo run --bin benchmark_shared_core -- --iterations 200 --json',
        },
        {
          'surface_kind': 'dart-json-baseline',
          'role': 'Dart runtime parsing baseline only',
          'command':
              'HOURA_SPEC_ROOT=../houra-spec dart run tool/benchmark_shared_core.dart --iterations 200 --no-external',
        },
      ],
      'size_evidence_commands': [
        'cd ts-protocol-core-wasm && npm run pack:dry-run',
        'cd rust-protocol-core-wasm && cargo build --locked --release --target wasm32-unknown-unknown',
      ],
      'optional_surfaces': [
        {
          'surface_kind': 'go-server-candidate',
          'status': 'optional_not_implemented',
          'reason':
              'No Go package is owned by houra-labs; measure Go only in a focused server-side shared-core candidate issue.',
        },
      ],
      'summary_fields': [
        'surface_kind',
        'benchmark_id',
        'spec_id',
        'payload_bytes',
        'iterations',
        'p95_microseconds',
        'max_microseconds',
      ],
      'claim_boundaries': [
        'candidate evidence only',
        'no production TypeScript client/server adoption',
        'no public compatibility claim expansion',
        'no raw request, prompt, token, or secret capture',
      ],
    },
    'profile_account_data_parser_adoption': {
      'issue': 60,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-045'],
      'parity_vectors': [
        'test-vectors/sync/matrix-profile-get-basic.json',
        'test-vectors/sync/matrix-profile-displayname-basic.json',
        'test-vectors/sync/matrix-account-data-global-basic.json',
        'test-vectors/sync/matrix-account-data-room-basic.json',
        'test-vectors/sync/matrix-room-tags-basic.json',
      ],
      'parser_only_surfaces': [
        'profile response envelope',
        'profile field update request descriptor',
        'global and room account-data content envelope',
        'room tag request descriptor',
        'room tags response envelope',
      ],
      'out_of_scope': [
        'profile storage',
        'account-data storage',
        'sync persistence',
        'authorization decisions',
        'room tag UI policy',
        'Matrix profile/account-data/tag support advertisement',
      ],
    },
    'receipts_typing_parser_adoption': {
      'issue': 61,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-046'],
      'parity_vectors': [
        'test-vectors/sync/matrix-receipt-basic.json',
        'test-vectors/sync/matrix-receipt-invalid-thread.json',
        'test-vectors/sync/matrix-typing-basic.json',
        'test-vectors/sync/matrix-typing-missing-token.json',
        'test-vectors/sync/matrix-read-markers-basic.json',
        'test-vectors/sync/matrix-read-marker-direct-account-data-forbidden.json',
      ],
      'parser_only_surfaces': [
        'typing request descriptor',
        'typing ephemeral content envelope',
        'receipt request descriptor',
        'receipt ephemeral content envelope',
        'read markers request descriptor',
        'fully read account-data content envelope',
      ],
      'out_of_scope': [
        'typing delivery',
        'receipt delivery',
        'unread UI policy',
        'storage persistence',
        'retry policy',
        'federation EDU delivery',
        'Matrix receipts/typing/read-marker support advertisement',
      ],
    },
    'filters_presence_capabilities_parser_adoption': {
      'issue': 62,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-047'],
      'parity_vectors': [
        'test-vectors/sync/matrix-filter-create-read-basic.json',
        'test-vectors/sync/matrix-filter-user-mismatch.json',
        'test-vectors/sync/matrix-presence-set-get-basic.json',
        'test-vectors/sync/matrix-presence-user-mismatch.json',
        'test-vectors/sync/matrix-capabilities-basic.json',
        'test-vectors/sync/matrix-capabilities-missing-token.json',
      ],
      'parser_only_surfaces': [
        'filter definition envelope',
        'filter create response envelope',
        'presence request descriptor',
        'presence response content envelope',
        'presence sync event envelope',
        'capabilities response envelope',
      ],
      'out_of_scope': [
        'server-side filter storage or execution',
        'presence propagation policy',
        'presence privacy policy',
        'capability advertisement ownership',
        'unstable MSC advertisement',
        'sync pagination completeness',
        'token persistence',
      ],
    },
    'room_directory_parser_adoption': {
      'issue': 63,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-048'],
      'parity_vectors': [
        'test-vectors/rooms/matrix-public-rooms-basic.json',
        'test-vectors/rooms/matrix-public-rooms-filter-basic.json',
        'test-vectors/rooms/matrix-room-directory-visibility-basic.json',
        'test-vectors/rooms/matrix-room-aliases-basic.json',
        'test-vectors/rooms/matrix-room-alias-update-forbidden.json',
        'test-vectors/rooms/matrix-room-invite-basic.json',
        'test-vectors/rooms/matrix-room-invite-forbidden.json',
      ],
      'parser_only_surfaces': [
        'public room directory request descriptor',
        'public room directory response envelope',
        'directory visibility envelope',
        'room alias list envelope',
        'invite request descriptor',
        'stripped invite state envelope',
        'room directory Matrix error envelope',
      ],
      'out_of_scope': [
        'directory storage',
        'visibility policy',
        'federation invite signing',
        'remote public room federation',
        'third-party invite behavior',
        'spaces hierarchy traversal',
        'Matrix room directory support advertisement',
      ],
    },
    'moderation_reporting_parser_adoption': {
      'issue': 64,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-049'],
      'parity_vectors': [
        'test-vectors/rooms/matrix-room-moderation-kick-ban-unban.json',
        'test-vectors/rooms/matrix-room-moderation-permission-denied.json',
        'test-vectors/rooms/matrix-room-redaction-basic.json',
        'test-vectors/rooms/matrix-room-redaction-forbidden.json',
        'test-vectors/rooms/matrix-room-reporting-basic.json',
        'test-vectors/rooms/matrix-admin-account-moderation-basic.json',
        'test-vectors/rooms/matrix-admin-account-moderation-forbidden.json',
      ],
      'parser_only_surfaces': [
        'kick/ban/unban request descriptor',
        'redaction request descriptor',
        'redaction response envelope',
        'room/event/user report request descriptor',
        'account moderation capability envelope',
        'admin lock/suspend request and status envelope',
        'moderation Matrix error envelope',
      ],
      'out_of_scope': [
        'authorization decisions',
        'policy enforcement',
        'appeal process',
        'moderation queue UI',
        'audit logging',
        'federation enforcement',
        'Matrix moderation support advertisement',
      ],
    },
    'device_key_parser_adoption': {
      'issue': 66,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-051'],
      'parity_vectors': [
        'test-vectors/auth/matrix-keys-upload-device-one-time-fallback-basic.json',
        'test-vectors/auth/matrix-keys-upload-malformed-device-keys.json',
        'test-vectors/auth/matrix-keys-claim-one-time-fallback-basic.json',
        'test-vectors/auth/matrix-keys-claim-invalid-algorithm.json',
      ],
      'parser_only_surfaces': [
        'device key upload request',
        'one-time key upload request',
        'fallback key upload request',
        'one-time key count upload response',
        'one-time/fallback key claim request',
        'one-time/fallback key claim response',
        'device-key Matrix error envelope',
      ],
      'out_of_scope': [
        'Olm or Megolm key generation',
        'private key storage',
        'signature verification',
        'trust policy decisions',
        'claim lifecycle enforcement',
        'Matrix E2EE support advertisement',
      ],
    },
    'device_key_query_parser_adoption': {
      'issue': 65,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-069'],
      'parity_vectors': [
        'test-vectors/auth/matrix-keys-query-basic.json',
        'test-vectors/auth/matrix-keys-query-all-devices.json',
        'test-vectors/auth/matrix-keys-query-unknown-device-omitted.json',
        'test-vectors/auth/matrix-keys-query-missing-token.json',
        'test-vectors/auth/matrix-keys-query-timeout-not-integer.json',
      ],
      'parser_only_surfaces': [
        'device key query request descriptor',
        'all-devices query selector',
        'public device-key query response',
        'unknown-device omission response',
        'device-key query Matrix error envelope',
      ],
      'out_of_scope': [
        'signature verification',
        'device trust decisions',
        'secure storage',
        'crypto verification',
        'device list lifecycle',
        'Matrix E2EE support advertisement',
      ],
    },
    'event_retrieval_membership_parser_adoption': {
      'issue': 119,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-085'],
      'parity_vectors': [
        'test-vectors/core/'
            'matrix-'
            'client-server-event-retrieval-membership-history.json',
      ],
      'parser_only_surfaces': [
        'event retrieval request descriptor',
        'Matrix ClientEvent response envelope',
        'joined_members response envelope',
        'members membership chunk envelope',
        'timestamp_to_event response envelope',
        'deprecated compatibility unsupported descriptor',
      ],
      'out_of_scope': [
        'runtime route behavior',
        'history visibility',
        'authorization',
        'storage lookup',
        'deprecated endpoint compatibility',
        'Matrix Client-Server support advertisement',
      ],
    },
    'relations_threads_reactions_parser_adoption': {
      'issue': 120,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-090'],
      'parity_vectors': [
        'test-vectors/core/'
            'matrix-'
            'client-server-relations-threads-reactions.json',
      ],
      'parser_only_surfaces': [
        'relations request descriptor',
        'relation chunk response envelope',
        'thread roots response envelope',
        'reaction event relation content',
        'edit relation content',
        'reply relation content',
        'membership variant failure envelope',
      ],
      'out_of_scope': [
        'runtime route behavior',
        'relation aggregation correctness',
        'thread ordering',
        'fanout',
        'authorization',
        'knock runtime behavior',
        'restricted join runtime behavior',
        'Matrix Client-Server support advertisement',
      ],
    },
    'sync_breadth_extensions_parser_adoption': {
      'issue': 121,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-093'],
      'parity_vectors': [
        'test-vectors/sync/matrix-sync-breadth-extensions.json',
      ],
      'parser_only_surfaces': [
        'sync request descriptor',
        'presence event snippets',
        'to-device event snippets',
        'device list changes',
        'one-time key counts',
        'invite room section map',
        'leave room section map',
        'knock room section map',
      ],
      'out_of_scope': [
        'sync long-poll runtime',
        'sync token persistence',
        'fanout timing',
        'authorization',
        'filter storage',
        'timeline ordering',
        'device-list freshness',
        'Matrix Client-Server support advertisement',
      ],
    },
    'media_repository_breadth_parser_adoption': {
      'issue': 122,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-095'],
      'parity_vectors': [
        'test-vectors/media/matrix-media-repository-breadth.json',
      ],
      'parser_only_surfaces': [
        'media repository request descriptor',
        'media config metadata',
        'URL preview metadata',
        'thumbnail metadata',
        'async upload metadata',
        'Content-Disposition filename helper',
        'Matrix Content URI validation',
      ],
      'out_of_scope': [
        'binary media transfer',
        'thumbnail generation',
        'preview crawling',
        'remote media fetch',
        'resumable upload runtime',
        'range requests',
        'encrypted attachment behavior',
        'Matrix Client-Server support advertisement',
      ],
    },
    'federation_version_key_lifecycle_request_auth_parser_adoption': {
      'issue': 123,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-097'],
      'parity_vectors': [
        'test-vectors/core/matrix-federation-version-key-lifecycle-request-auth.json',
      ],
      'parser_only_surfaces': [
        'federation version metadata',
        'federation key query lifecycle metadata',
        'server signing key lifecycle metadata',
        'request-auth header descriptor',
      ],
      'out_of_scope': [
        'DNS/TLS runtime',
        'notary fallback',
        'key-cache persistence',
        'request signature verification',
        'private signing-key storage',
        'outbound federation execution',
        'Server-Server API support advertisement',
      ],
    },
    'push_gateway_parser_helper_dart_adoption': {
      'issue': 128,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-098'],
      'parity_vectors': [
        'test-vectors/core/matrix-push-parser-helper-breadth.json',
      ],
      'parser_only_surfaces': [
        'pusher descriptor',
        'push-rule descriptor',
        'sync visibility evidence case',
        'malformed descriptor failure',
        'redaction helper',
      ],
      'out_of_scope': [
        'pusher persistence',
        'runtime destination lookup',
        'retry queue',
        'provider dispatch',
        'client notification UI',
        'Push Gateway support advertisement',
        'Rust/WASM/TypeScript protocol-core manifest coverage',
      ],
    },
    'federation_pdu_edu_parser_adoption': {
      'issue': 124,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-099'],
      'parity_vectors': [
        'test-vectors/events/matrix-federation-pdu-edu-parser-helpers.json',
      ],
      'parser_only_surfaces': [
        'federation transaction envelope',
        'typed PDU envelope',
        'typed EDU envelope',
        'canonical JSON input descriptor',
        'per-PDU response descriptor',
      ],
      'out_of_scope': [
        'event auth',
        'state resolution',
        'hash calculation',
        'signature verification',
        'storage mutation',
        'soft-fail policy',
        'outbound federation execution',
        'Server-Server API support advertisement',
      ],
    },
    'federation_directory_query_openid_parser_adoption': {
      'issue': 125,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-100'],
      'parity_vectors': [
        'test-vectors/core/matrix-federation-directory-query-openid-parser-helpers.json',
      ],
      'parser_only_surfaces': [
        'federation public rooms response',
        'federation hierarchy response',
        'federation directory query response',
        'federation profile query response',
        'federation generic query response',
        'federation OpenID userinfo response',
      ],
      'out_of_scope': [
        'remote network fetch',
        'visibility decision',
        'profile privacy policy',
        'OpenID token verification',
        'trust decision',
        'rate limiting',
        'cache persistence',
        'Server-Server API support advertisement',
      ],
    },
    'room_version_parser_fixture_adoption': {
      'issues': [129, 130, 131],
      'status': 'parser-fixture-adopted',
      'spec_ids': ['SPEC-078', 'SPEC-083'],
      'parity_vectors': [
        'test-vectors/rooms/matrix-room-versions-full-algorithm-gap-inventory.json',
        'test-vectors/events/matrix-room-version-event-decision-artifacts.json',
      ],
      'parser_only_surfaces': [
        'Room Versions full-algorithm gap lane parser',
        'event format / canonical JSON / hash-signature lane evidence parser',
        'bounded event-decision artifact parser',
        'auth-rule fixture inventory runner',
        'state-resolution fixture inventory runner',
      ],
      'fail_closed_claims': [
        'Room Versions full-algorithm support is not claimed',
        'Matrix versions advertisement is not widened',
        'federation get-missing-events support is not claimed',
        'resource bounds reject unbounded graph, network, and database work',
      ],
      'out_of_scope': [
        'complete room-version authorization algorithms',
        'complete state-resolution algorithms',
        'event hash calculation',
        'event signature verification',
        'storage mutation',
        'network lookup',
        'Room Versions support advertisement',
      ],
    },
    'e2ee_parser_artifact_adoption': {
      'issue': 132,
      'status': 'parser-fixture-adopted',
      'spec_ids': ['SPEC-079'],
      'parity_vectors': [
        'test-vectors/messaging/matrix-olm-megolm-full-e2ee-gap-inventory.json',
      ],
      'parser_only_surfaces': [
        'Olm/Megolm full-breadth gap lane parser',
        'encrypted event envelope parser evidence lane',
        'key, backup, verification, and cross-signing public payload helper lane',
        'secret/local-path redaction evidence lane',
      ],
      'fail_closed_claims': [
        'Olm/Megolm full E2EE support is not claimed',
        'Matrix versions advertisement is not widened',
        'local cryptographic primitive implementation is not introduced',
      ],
      'out_of_scope': [
        'crypto stack selection',
        'Olm/Megolm encryption or decryption',
        'secure storage',
        'device trust decisions',
        'verification UX',
        'key backup recovery UX',
        'Matrix E2EE support advertisement',
      ],
    },
    'oauth_account_management_parser_adoption': {
      'issue': 118,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-068'],
      'parity_vectors': [
        'test-vectors/auth/matrix-oauth-generic-account-management-fallback.json',
        'test-vectors/auth/matrix-oauth-device-delete-return-refresh-complete.json',
      ],
      'parser_only_surfaces': [
        'auth metadata response envelope',
        'account-management redirect descriptor',
        'generic account-management fallback redirect',
        'post-return device-delete reconciliation signal',
      ],
      'out_of_scope': [
        'token refresh endpoint execution',
        'fallback HTML or browser presentation',
        'transport retry policy',
        'bearer-token storage',
        'account-management completion without post-return API evidence',
        'Matrix OAuth support advertisement',
      ],
    },
    'key_backup_parser_adoption': {
      'issue': 68,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-053'],
      'parity_vectors': [
        'test-vectors/messaging/matrix-key-backup-version-lifecycle.json',
        'test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json',
        'test-vectors/messaging/matrix-key-backup-wrong-version.json',
        'test-vectors/messaging/matrix-key-backup-restore-missing-session.json',
        'test-vectors/messaging/matrix-key-backup-owner-scope.json',
        'test-vectors/messaging/matrix-key-backup-logout-relogin-recovery-gate.json',
      ],
      'parser_only_surfaces': [
        'key backup version create response',
        'key backup version metadata',
        'room key backup session metadata',
        'room key backup upload response',
        'wrong-version and missing-session errors',
        'owner-scope protection gate',
        'logout/relogin recovery evidence gate',
      ],
      'out_of_scope': [
        'Megolm backup encryption or decryption',
        'room key storage',
        'recovery secret storage',
        'backup ownership authorization policy',
        'logout/relogin UX',
        'Matrix E2EE support advertisement',
      ],
    },
    'verification_cross_signing_parser_adoption': {
      'issue': 69,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-054'],
      'parity_vectors': [
        'test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json',
        'test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json',
        'test-vectors/messaging/matrix-cross-signing-key-lifecycle.json',
        'test-vectors/messaging/matrix-cross-signing-invalid-signature.json',
        'test-vectors/messaging/matrix-cross-signing-missing-token.json',
        'test-vectors/messaging/matrix-wrong-device-failure-gate.json',
      ],
      'parser_only_surfaces': [
        'SAS to-device message flow envelope',
        'verification cancel envelope',
        'cross-signing public key upload envelope',
        'signature upload envelope',
        'invalid signature failure envelope',
        'missing-token gate envelope',
        'wrong-device failure gate envelope',
      ],
      'out_of_scope': [
        'local SAS calculation',
        'Ed25519 verification',
        'Olm or Megolm session handling',
        'cross-signing private key storage',
        'trust policy decisions',
        'QR verification or account recovery UI',
      ],
    },
    'crypto_evidence_helper_adoption': buildCryptoEvidenceHelper(
      artifactMetadata: {
        'contract_boundary': 'parser-only-and-redacted-release-evidence',
        'raw_requests_or_secrets': false,
        'release_note_helper': 'metadata-only',
      },
    ),
    'dart_binding_candidate': {
      'issue': 77,
      'status': 'candidate-only-implementation-deferred',
      'native_ffi_use_cases': [
        'Flutter or Dart host apps that need a local Rust artifact',
        'iOS, Android, macOS, Windows, or Linux hosts with native package ownership',
      ],
      'web_js_wasm_use_cases': [
        'Flutter web or Dart web hosts that provide the generated WASM module',
        'browser-hosted experiments that keep bundler and fetch ownership in the host',
      ],
      'host_owned_boundaries': [
        'token storage',
        'sync-token persistence',
        'Flutter UI lifecycle',
        'route policy',
        'secure storage',
        'fetch, retry, and cancellation policy',
      ],
      'blocked_until': [
        'platform matrix is confirmed',
        'native and web artifact packaging policy is confirmed',
        'binary size threshold is confirmed per target family',
        'p95 binding overhead threshold is measured',
        'fallback behavior is decided for hosts without native or WASM artifacts',
        'package registry metadata is confirmed in a focused publish issue',
      ],
      'out_of_scope': [
        'making the Flutter SDK prototype the canonical behavior source',
        'publishing a Dart FFI or Dart web package from this issue',
        'moving token or sync-token persistence into the SDK core',
        'owning production client UI lifecycle or secure storage policy',
      ],
    },
    'node_napi_binding_candidate': {
      'issue': 76,
      'status': 'candidate-only-implementation-deferred',
      'napi_use_cases': [
        'Node or Next server hosts that need lower overhead than WASM',
        'server hosts that need synchronous local artifact calls',
        'deployment targets where native artifact operations are acceptable',
      ],
      'wasm_fallback_use_cases': [
        'Next server experiments that can use the existing TypeScript facade',
        'package validation and tests that do not need a native artifact',
        'hosts where generated WASM module loading is operationally simpler',
      ],
      'host_owned_boundaries': [
        'Node server transport',
        'request lifecycle',
        'retry and cancellation policy',
        'tenant context',
        'storage policy',
        'secret redaction and logging policy',
      ],
      'blocked_until': [
        'platform matrix is confirmed',
        'prebuild policy is confirmed',
        'native rebuild trigger is defined',
        'binary size threshold is confirmed per target family',
        'p95 binding overhead threshold is measured against WASM fallback',
        'CI runtime impact is measured',
        'fallback behavior is decided for hosts without native artifacts',
      ],
      'out_of_scope': [
        'publishing a N-API package from this issue',
        'moving Node transport or request lifecycle into the binding',
        'owning host storage or tenant policy',
        'claiming server behavior or Matrix compatibility from the binding',
      ],
    },
    'ecosystem_service_parser_candidates': {
      'issue': 73,
      'status':
          'application-and-identity-parser-adopted-push-candidate-remains',
      'spec_ids': ['SPEC-058', 'SPEC-059', 'SPEC-060'],
      'labs_owned_candidates': {
        'SPEC-058': [
          'Application Service registration shape parser',
          'namespace matching helper candidate',
          'transaction payload parser',
          'user and room alias query request shape parser',
        ],
        'SPEC-059': [
          'Identity Service hash details parser',
          'lookup request and response shape parser',
          'validation session shape parser',
          'bind and unbind request/response shape parser',
          'signed association metadata parser candidate',
        ],
        'SPEC-060': [
          'Push Gateway notify payload parser',
          'rejected pushkey response parser',
          'event-id-only notification shape parser',
          'pusher data validation helper candidate',
          'push rule payload shape parser candidate',
        ],
      },
      'parity_vector_globs': [
        'test-vectors/core/matrix-appservice-*.json',
        'test-vectors/core/matrix-identity-*.json',
        'test-vectors/core/matrix-push-*.json',
      ],
      'host_or_service_owned_boundaries': [
        'service deployment',
        'service token storage',
        'network policy enforcement',
        'privacy enforcement',
        'provider delivery',
        'vendor credentials',
        'user-facing consent UI',
        'notification rendering UI',
      ],
      'follow_up_split': [
        'SPEC-058 Application Service parser-only helpers',
        'SPEC-059 Identity Service parser-only helpers',
        'SPEC-060 Push Gateway parser-only helpers',
      ],
      'out_of_scope': [
        'claiming production service behavior from labs helpers',
        'owning application service deployment or bridge protocol behavior',
        'owning identity provider delivery or consent policy',
        'owning APNS, FCM, Web Push, or vendor credential handling',
      ],
    },
    'application_service_parser_helper_dart_adoption': {
      'issue': 126,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-058', 'SPEC-075'],
      'spec_snapshot': '26a47461237d30efb2310bd688559b73d6dc998b',
      'vectors': [
        'test-vectors/core/matrix-appservice-registration-basic.json',
        'test-vectors/core/matrix-appservice-namespace-ownership.json',
        'test-vectors/core/matrix-appservice-transaction-basic.json',
        'test-vectors/core/matrix-appservice-query-user-room-basic.json',
        'test-vectors/core/matrix-application-service-full-breadth-gap-inventory.json',
      ],
      'implemented_surface': [
        'Application Service registration descriptors',
        'namespace regex descriptors',
        'homeserver-to-appservice request descriptors',
        'transaction envelopes',
        'user and room-alias query descriptors',
        'full-breadth gap lane parser evidence',
        'privacy-sensitive redaction helper',
      ],
      'fail_closed_claims': [
        'Application Service full-breadth runtime support is not claimed',
        'Matrix versions advertisement is not widened',
        'delivery retry, bridge runtime, token storage, and server mutation remain server-owned',
        'third-party network, ping/liveness, and Client-Server extension support remain out of scope',
      ],
      'out_of_scope': [
        'owning application service deployment',
        'storing application service tokens',
        'performing delivery retry or bridge runtime behavior',
        'mutating homeserver state',
        'claiming third-party network directory or ping support',
        'claiming Client-Server masquerading or bridge external URL support',
      ],
    },
    'identity_service_parser_helper_dart_adoption': {
      'issue': 127,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-059', 'SPEC-076'],
      'spec_snapshot': '26a47461237d30efb2310bd688559b73d6dc998b',
      'vectors': [
        'test-vectors/core/matrix-identity-service-boundary-basic.json',
        'test-vectors/core/matrix-identity-lookup-hash-details-basic.json',
        'test-vectors/core/matrix-identity-validation-bind-basic.json',
        'test-vectors/core/matrix-identity-unbind-auth-failures.json',
        'test-vectors/core/matrix-identity-bind-unbind-lifecycle-boundary.json',
        'test-vectors/core/matrix-identity-validation-provider-delivery-boundary.json',
        'test-vectors/core/matrix-identity-public-key-signature-boundary.json',
        'test-vectors/core/matrix-identity-service-full-breadth-gap-inventory.json',
      ],
      'implemented_surface': [
        'Identity Service request descriptors',
        'hash details and lookup response parsers',
        'validation session and validated 3PID parsers',
        'signed association parser',
        'Matrix error envelope parser',
        'lifecycle evidence case parser',
        'privacy-sensitive redaction helper',
      ],
      'fail_closed_claims': [
        'Identity Service full-breadth runtime support is not claimed',
        'Matrix versions advertisement is not widened',
        'provider delivery and consent UI remain host/service-owned',
        'invitation storage and ephemeral invitation signing remain out of scope',
      ],
      'out_of_scope': [
        'owning Identity Service deployment',
        'storing Identity Service tokens or validation secrets',
        'performing network lookup or provider delivery',
        'owning contact upload UX or consent UI',
        'claiming production key rotation or invitation signing support',
      ],
    },
    'federation_backfill_auth_state_parser_adoption': {
      'issue': 72,
      'status': 'parser-only-adopted',
      'spec_ids': ['SPEC-057'],
      'parser_only_surfaces': [
        'backfill request shape',
        'backfill response PDUs',
        'event auth PDUs',
        'state IDs response',
        'state-resolution interop record',
      ],
      'parity_vectors': [
        'test-vectors/events/matrix-federation-backfill-basic.json',
        'test-vectors/events/matrix-federation-event-auth-basic.json',
        'test-vectors/events/matrix-federation-state-ids-basic.json',
        'test-vectors/events/matrix-federation-state-resolution-interop-gate.json',
        'test-vectors/events/matrix-state-resolution-representative.json',
      ],
      'out_of_scope': [
        'server persistence',
        'missing-event recovery policy',
        'federation request authentication',
        'federation retry and backoff',
        'remote trust policy',
        'room-version state-resolution algorithms',
        'full state-resolution correctness',
        'Server-Server API support advertisement',
      ],
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
          'protocol artifact supported SPEC ids include SPEC-030 through SPEC-040, SPEC-045, SPEC-046, SPEC-047, SPEC-048, SPEC-049, SPEC-051, SPEC-053 through SPEC-056, SPEC-068, SPEC-069, SPEC-085, SPEC-090, SPEC-093, SPEC-095, and SPEC-097',
          'release evidence helper SPEC ids include SPEC-079 and SPEC-081 without widening protocol artifact support',
        ],
      },
      {
        'name': 'wasm-wrapper',
        'command':
            'cd rust-protocol-core-wasm && cargo build --locked --release --target wasm32-unknown-unknown',
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
        'spec_snapshot_ref',
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
    'description': _readTomlStringOrNull(packageSource, 'description'),
    'license': _readTomlStringOrNull(packageSource, 'license'),
    'repository': _readTomlStringOrNull(packageSource, 'repository'),
    'documentation': _readTomlStringOrNull(packageSource, 'documentation'),
    'readme': _readTomlStringOrNull(packageSource, 'readme'),
    'keywords': _readTomlStringListOrEmpty(packageSource, 'keywords'),
    'categories': _readTomlStringListOrEmpty(packageSource, 'categories'),
    'publish': _readTomlBool(packageSource, 'publish'),
    'docs_rs': {
      'all_features': _readTomlBoolOrNull(source, 'all-features'),
      'no_default_features': _readTomlBoolOrNull(source, 'no-default-features'),
      'rustdoc_args': _readTomlStringListOrEmpty(source, 'rustdoc-args'),
    },
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

String? _readTomlStringOrNull(String source, String key) {
  final match = RegExp('^$key = "([^"]+)"', multiLine: true).firstMatch(source);
  return match?.group(1);
}

List<String> _readTomlStringListOrEmpty(String source, String key) {
  final match = RegExp(
    '^$key = \\[(.*?)\\]',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) {
    return [];
  }
  return RegExp(
    '"([^"]+)"',
  ).allMatches(match.group(1)!).map((match) => match.group(1)!).toList();
}

bool _readTomlBool(String source, String key) {
  final match = RegExp(
    '^$key = (true|false)',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TOML boolean key: $key');
  }
  return match.group(1) == 'true';
}

bool? _readTomlBoolOrNull(String source, String key) {
  final match = RegExp(
    '^$key = (true|false)',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) {
    return null;
  }
  return match.group(1) == 'true';
}

int _readTsNumber(String source, String name) {
  final match = RegExp(
    '(?:export\\s+)?const $name = ([0-9]+);',
  ).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript numeric constant: $name');
  }
  return int.parse(match.group(1)!);
}

String _readTsString(String source, String name) {
  final match = RegExp(
    '(?:export\\s+)?const $name = "([^"]+)";',
  ).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript string constant: $name');
  }
  return match.group(1)!;
}

List<String> _readTsStringArray(String source, String name) {
  final match = RegExp(
    '(?:export\\s+)?const $name = \\[(.*?)\\] as const;',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) {
    throw FormatException('Missing TypeScript string array constant: $name');
  }
  return RegExp(
    '"([^"]+)"',
  ).allMatches(match.group(1)!).map((match) => match.group(1)!).toList();
}

Directory _canonicalSpecRoot() {
  final fromEnv = Platform.environment['HOURA_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory('../houra-spec');
}

String? _gitRevParse(String workingDirectory) {
  const gitCandidates = ['git', '/opt/homebrew/bin/git', '/usr/bin/git'];
  for (final git in gitCandidates) {
    try {
      final result = Process.runSync(
          git,
          [
            'rev-parse',
            'HEAD',
          ],
          workingDirectory: workingDirectory);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } on ProcessException {
      continue;
    }
  }
  return null;
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
