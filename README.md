# okaka

`okaka` is a Flutter SDK candidate for the Okomedev Chawan client API subset.

## Status

Draft. The current implementation covers the MVP client profiles from
SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
SPEC-010, SPEC-011, and SPEC-020.

Out of scope for this package version:

- end-to-end encryption
- federation
- server implementation behavior

## Features

- Discovery and error model
- Login flow discovery and password session calls
- Rooms, events, text messaging, room list, timeline, and basic sync
- Media metadata and base64 upload
- Shared theme token parsing and Flutter `ThemeData` mapping

## Install

```yaml
dependencies:
  okaka:
    path: .
```

## Usage

```dart
import 'package:okaka/okaka.dart';

Future<void> main() async {
  final client = OkakaClient(serverBaseUri: Uri.parse('https://example.test'));
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

## Themes

Shared visual themes live in `design/themes/*.json`.

Each theme file uses platform-neutral color tokens with `light` and `dark`
values. Flutter reads the same JSON and maps it to `ThemeData`; other client
implementations can map the same token file to their native theme systems.
The canonical copy is expected to live in `../chawan-product-spec/design`; this
package keeps bundled copies for Flutter asset loading and checks that they stay
in sync during local development.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okaka/okaka.dart';

Future<ThemeData> loadTheme() async {
  final source = await rootBundle.loadString(
    'packages/okaka/design/themes/smoke.json',
  );
  final tokens = OkakaThemeTokens.fromJsonString(source);
  return OkakaFlutterTheme.themeData(
    tokens.resolve(OkakaThemeVariant.light),
  );
}
```

## Source of Truth

Behavior is defined by Okomedev Chawan contracts and test vectors. Server
implementations are not canonical behavior sources.

When this package is developed next to `../chawan-product-spec`, contract and
theme checks read that sibling source directory directly.

## Local checks

```bash
flutter pub get
dart run tool/check_spec_sync.dart
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

`tool/check_spec_sync.dart` also runs `../chawan-product-spec/tool/check_spec.dart`
before checking bundled theme and vector references.

## Roadmap

The long-term path is spec root publication, Flutter SDK hardening, shared
theme adapter stability, conformance tooling, then pre-1.0 release prep. New
SDK surface should be added only after the matching `SPEC-*` contract and test
vector exist.
