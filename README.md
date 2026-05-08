# houra-labs

`houra` is a Flutter SDK prototype for the Houra client API subset.
The name comes from horagai, a conch shell used to signal over distance.

## Status

Draft. The current implementation covers the MVP client profiles from
SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
SPEC-010, SPEC-011, and SPEC-020.

Out of scope for this package version:

- end-to-end encryption
- federation
- production React Native client behavior
- production TypeScript server behavior
- server implementation behavior

## Features

- Discovery and error model
- Login flow discovery and password session calls
- Rooms, events, text messaging, room list, timeline, and basic sync
- Media metadata and base64 upload
- Shared theme token parsing and Flutter `ThemeData` mapping

## Install

This package is not published to pub.dev yet. Use a local checkout while it is
in draft:

```yaml
dependencies:
  houra:
    path: ../houra-labs
```

Keep `../houra-spec` checked out next to this repository for local
contract and design-token validation.

## Usage

```dart
import 'package:houra/houra.dart';

Future<void> main() async {
  final client = HouraClient(serverBaseUri: Uri.parse('https://example.test'));
  try {
    final versions = await client.discovery.fetchVersions();
    final flows = await client.auth.fetchLoginFlows();
    final rooms = await client.sync.listRooms(accessToken: 'token-1');
    print(versions.apiVersion);
    print(flows.flows.map((flow) => flow.type).join(', '));
    print(rooms.rooms.map((room) => room.roomId).join(', '));
  } finally {
    client.close();
  }
}
```

See `example/main.dart` for a minimal command-line usage example backed by the
current contract surface.

## Themes

Shared visual themes live in `design/themes/*.json`.

Each theme file uses platform-neutral color tokens with `light` and `dark`
values. Flutter reads the same JSON and maps it to `ThemeData`; other client
implementations can map the same token file to their native theme systems.
The canonical copy is expected to live in `../houra-spec/design`; this
package keeps bundled copies for Flutter asset loading and checks that they stay
in sync during local development.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houra/houra.dart';

Future<ThemeData> loadTheme() async {
  final source = await rootBundle.loadString(
    'packages/houra/design/themes/smoke.json',
  );
  final tokens = HouraThemeTokens.fromJsonString(source);
  return HouraFlutterTheme.themeData(
    tokens.resolve(HouraThemeVariant.light),
  );
}
```

## Source of Truth

Behavior is defined by Houra contracts and test vectors. Server
implementations are not canonical behavior sources.

When this package is developed next to `../houra-spec`, contract and
theme checks read that sibling source directory directly.
Set `HOURA_SPEC_ROOT` when the canonical spec checkout lives somewhere else,
such as in GitHub Actions.

## Local checks

```bash
flutter pub get
dart run tool/check_spec_sync.dart
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

`tool/check_spec_sync.dart` also runs `../houra-spec/tool/check_spec.dart`
before checking bundled theme and vector references. If `HOURA_SPEC_ROOT` is
set, that path is used instead of `../houra-spec`.

## Pre-1.0 SDK Hardening Checklist

Before a pre-1.0 release decision, verify:

- Public API names, constructor parameters, and return models are small,
  profile-oriented, and covered by canonical contract tests.
- Examples show only behavior backed by `../houra-spec` contracts and
  vectors.
- Theme adapter behavior remains limited to bundled design assets that are
  checked against `../houra-spec/design`.
- Error handling docs and examples use typed SDK errors without inventing
  server-specific behavior.
- `publish_to: none` remains in place until a separate release decision issue
  covers pub.dev publication, package name, and versioning.

This package must not copy canonical contracts or test vectors. It should read
them from the sibling spec checkout or `HOURA_SPEC_ROOT`.

## Pre-1.0 Release Decision

Current decision: keep this package unpublished while the SDK remains a draft.

- Package name: keep `houra`.
- Version: keep `0.1.0` until the first release candidate is cut.
- License: Apache-2.0, as declared in `LICENSE`.
- Publication: keep `publish_to: none`.
- Canonical source: continue reading contracts, vectors, and design tokens from
  `../houra-spec` or `HOURA_SPEC_ROOT`.

Before publishing to pub.dev, open a separate release PR that removes
`publish_to: none` only after package ownership, repository metadata,
versioning, and the final Houra freeze baseline are confirmed.

## Roadmap

The long-term path for this lab package is Flutter SDK hardening, shared theme
adapter stability, and conformance tooling after the spec root is stable. New
SDK surface should be added only after the matching `SPEC-*` contract and test
vector exist.
