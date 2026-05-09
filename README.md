# houra-labs

`houra` is a Flutter SDK prototype for the Houra client API subset.
The name comes from horagai, a conch shell used to signal over distance.

## Status

Draft. The current implementation covers the MVP client profiles from
SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
SPEC-010, SPEC-011, and SPEC-020.

This repository also contains lab-only shared implementation experiments. The
`rust-protocol-core/` crate is the first Rust shared protocol core prototype. It
currently validates only the `SPEC-030` Matrix client versions vector and is not
published, canonical, or required by the Flutter SDK.

The Rust prototype exposes `abi_version()` and `artifact_manifest()` as
implementation metadata for future TS / Dart bindings. Bindings can use that
metadata to check the loaded artifact, manifest schema, crate version, ABI
version, and covered `SPEC-*` IDs before calling into the core. The manifest is
not a behavior contract and does not replace `houra-spec`; it is only a
compatibility aid for prebuilt artifacts and thin adapter packages. Binding
kinds remain empty until a WASM, N-API, Dart FFI, or Dart web adapter is added in
a focused follow-up.

The prototype also exposes a binding-safe JSON parse envelope for `SPEC-030`.
That API returns a single `ok` / `value` / `error` object so WASM, N-API, FFI,
and JS interop adapters can cross the language boundary once per parse instead
of bouncing through many small calls. The envelope carries stable Rust-side
error codes for adapter mapping, but it remains implementation metadata; public
behavior still comes from `houra-spec` contracts and test vectors.

`rust-protocol-core-wasm/` is the first thin binding prototype for browser,
Vue, and Next client experiments. It uses `wasm-bindgen` to export the manifest
and `SPEC-030` JSON parse envelope, but it does not own HTTP, retries,
cancellation, token storage, UI state, or framework lifecycle. Generated JS,
`.wasm` files, npm packaging, and Next server / Node bindings are intentionally
left out until a focused package issue exists.

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

For the Rust protocol core prototype, run:

```bash
cd rust-protocol-core
HOURA_SPEC_ROOT=../../houra-spec cargo fmt --check
HOURA_SPEC_ROOT=../../houra-spec cargo test
```

For the browser WASM wrapper prototype, run:

```bash
cd rust-protocol-core-wasm
cargo fmt --check
cargo test
rustup target add wasm32-unknown-unknown
cargo build --target wasm32-unknown-unknown
```

If Rust is not installed locally, the same checks can run in a Rust Docker image
with this repository and `houra-spec` mounted into the container. The official
Rust image may not include `cargo fmt`, so install `rustfmt` inside the
throwaway container and call it directly:

```bash
docker run --rm \
  -v "$PWD":/workspace/houra-labs \
  -v "$(cd ../houra-spec && pwd)":/workspace/houra-spec \
  -w /workspace/houra-labs/rust-protocol-core \
  -e HOURA_SPEC_ROOT=/workspace/houra-spec \
  rust:1 \
  sh -lc 'apt-get update >/tmp/apt-update.log && apt-get install -y rustfmt >/tmp/apt-install.log && rustfmt --check src/lib.rs && cargo test --locked'
```

For the WASM wrapper in the same Docker image, install the distro-provided
`wasm32-unknown-unknown` standard library package because the image does not
ship `rustup`:

```bash
docker run --rm \
  -v "$PWD":/workspace/houra-labs \
  -w /workspace/houra-labs/rust-protocol-core-wasm \
  rust:1 \
  sh -lc 'apt-get update >/tmp/apt-update.log && apt-get install -y rustfmt libstd-rust-dev-wasm32 >/tmp/apt-install.log && rustfmt --check src/lib.rs && cargo test --locked && cargo build --locked --target wasm32-unknown-unknown'
```

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
