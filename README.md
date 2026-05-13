# houra-labs

`houra` is a Flutter SDK prototype for the Houra client API subset.
The name comes from horagai, a conch shell used to signal over distance.

## Status

Draft. The current implementation covers the MVP client profiles from
SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
SPEC-010, SPEC-011, and SPEC-020.

## Repository Role

This public repository is for Houra implementation experiments:

- Flutter SDK prototype code.
- Rust-first shared protocol-core experiments.
- WASM, TypeScript, Dart FFI, or other thin binding prototypes.
- Minimal SDK usage examples that exercise the public API surface.

It is not the place for business adoption demos, customer proposal material,
legacy-system migration walkthroughs, or samples that require provider API keys
or tokens, such as Local LLM gateway tokens, Gemini API keys, or other model
credentials. Those belong in separate private integration or adoption sample
repositories until they are sanitized for publication.

`example/` is a package usage example for this SDK prototype, not a business
application replacement or integration demo.

The expected long-term shape is:

- `houra-spec`: canonical contracts, vectors, and design.
- `houra-core`: a thin Rust protocol / parser / state core promoted from
  `rust-protocol-core/` when it is ready.
- `houra-ts`: the representative TypeScript SDK or binding promoted from the
  TypeScript facade work when it is ready.
- Other language bindings: thin adapters added by demand after the Rust core
  and TypeScript representative path are stable.
- Private integration sample repositories: Gennai OSS, Java MVC, SPA, Local
  LLM, Gemini, and business process integration demos.

This repository also contains lab-only shared implementation experiments. The
`rust-protocol-core/` crate is the first Rust shared protocol core prototype. It
currently validates the `SPEC-030` Matrix client versions vector and the
`SPEC-031` Matrix foundation vectors. It parses the `SPEC-032` Matrix auth /
session vectors, `SPEC-033` Matrix registration vectors, `SPEC-034` Matrix
device/session vectors, `SPEC-035` Matrix room membership/state MVP vectors,
`SPEC-036` Matrix event/messages vectors, `SPEC-037` Matrix sync response
vectors, `SPEC-038` Matrix media parser vectors, and the `SPEC-039`
integration gate vector that ties those parser surfaces together. It is not
published, canonical, or required by the Flutter SDK.

The Rust prototype exposes `abi_version()` and `artifact_manifest()` as
implementation metadata for future TS / Dart bindings. Bindings can use that
metadata to check the loaded artifact, manifest schema, crate version, ABI
version, and covered `SPEC-*` IDs before calling into the core. The manifest is
not a behavior contract and does not replace `houra-spec`; it is only a
compatibility aid for prebuilt artifacts and thin adapter packages. Binding
kinds remain empty until a WASM, N-API, Dart FFI, or Dart web adapter is added in
a focused follow-up.

The prototype also exposes binding-safe JSON envelopes for `SPEC-030`,
`SPEC-031`, `SPEC-032`, `SPEC-033`, `SPEC-034`, `SPEC-035`, `SPEC-036`, and
`SPEC-037` / `SPEC-038`; `SPEC-039` is exposed only as manifest coverage and a
repo-local integration gate over those existing surfaces.
Those APIs return a single `ok` / `value` / `error` object so WASM, N-API, FFI,
and JS interop adapters can cross the language boundary once per parse or
validation call instead of bouncing through many small calls. The envelope
carries stable Rust-side error codes for adapter mapping, but it remains
implementation metadata; public behavior still comes from `houra-spec`
contracts and test vectors.

`rust-protocol-core-wasm/` is the first thin binding prototype for browser,
Vue, and Next client experiments. It uses `wasm-bindgen` to export the manifest
and `SPEC-030` / `SPEC-031` / `SPEC-032` / `SPEC-033` / `SPEC-034` /
`SPEC-035` / `SPEC-036` / `SPEC-037` / `SPEC-038` JSON envelopes plus
`SPEC-039` manifest coverage, but it does not own HTTP, retries, cancellation,
token storage, UI state, or framework lifecycle.
Generated JS, `.wasm` files, npm packaging, and Next server / Node bindings are
intentionally left out until a focused package issue exists.

`ts-protocol-core-wasm/` is the matching TypeScript facade prototype for browser,
Vue, and Next client experiments. It does not load WASM by itself and does not
commit generated artifacts. Instead, a host app passes the generated
`wasm-bindgen` module object into `createHouraProtocolCore()`, and the facade
validates the manifest, ABI version, binding kind, and supported `SPEC-*` ids
before mapping the Rust JSON envelopes into TypeScript result types. This keeps
bundler choice, framework lifecycle, transport, and storage in the host layer.

SPEC-031 adoption record for issue #31: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.23` Matrix foundation vectors for Matrix error
envelope parsing and identifier validation only. The WASM wrapper and
TypeScript facade expose those envelopes without taking ownership of crypto,
transport, storage, retries, or UI behavior.

SPEC-032 adoption record for issue #33: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.24` Matrix auth/session vectors for login-flow,
password-login session, and whoami response parsing only. The WASM wrapper and
TypeScript facade expose those envelopes without taking ownership of crypto,
transport, storage, retries, or UI behavior.

SPEC-033 adoption record for issue #35: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.25` Matrix registration vectors for username
availability, registration success session, user-interactive auth required
response, and registration-token validity parsing only. The WASM wrapper and
TypeScript facade expose those envelopes without taking ownership of crypto,
transport, storage, retries, or UI behavior.

SPEC-034 adoption record for issue #37: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.26` Matrix device/session vectors for device detail,
device list, user-interactive auth required response, and token invalidation
Matrix error parsing only. The WASM wrapper and TypeScript facade expose those
envelopes without taking ownership of crypto, transport, storage, retries, or UI
behavior.

SPEC-035 adoption record for issue #40: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.27` Matrix room membership/state MVP vectors for room
ID response, Matrix client event, state event array, and Matrix error envelope
parsing only. The WASM wrapper and TypeScript facade expose those envelopes
without taking ownership of crypto, transport, storage, retries, or UI behavior.

SPEC-036 adoption record for issue #42: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.28` Matrix event/messages vectors for event ID
response, Matrix client event, messages pagination response, and Matrix error
envelope parsing only. The WASM wrapper and TypeScript facade expose those
envelopes without taking ownership of crypto, transport, storage, retries, or
UI behavior.

SPEC-037 adoption record for issue #44: the Rust prototype now consumes the
`houra-spec` `v0.2.0-pre.29` Matrix sync response vectors for initial,
incremental, empty incremental, room state/timeline, account data, summary,
unread notification, presence envelope, and Matrix error envelope parsing only.
The WASM wrapper and TypeScript facade expose those envelopes without taking
ownership of crypto, transport, storage, retries, sync token persistence, or UI
behavior.

SPEC-038 adoption record for issue #47: the Rust prototype now consumes the
`houra-spec` snapshot `d05eca9afebf9d166a7a8a7def326ddc616a0190`
(`v0.2.0-pre.58-2-gd05eca9`) Matrix media vectors for Matrix Content URI
validation and media upload response parsing only. The WASM wrapper and
TypeScript facade expose those envelopes without taking ownership of media
transport, media storage, persistence, crypto, retries, secure storage, or UI
behavior.

SPEC-039 adoption record: the Rust prototype now consumes the
`houra-spec` snapshot `413a3025a32521e4a707d9dd890a10b56328154e`
(`v0.2.0-pre.58-3-g413a302`) `SPEC-039` Matrix Client-Server MVP live e2e gate
vector as a repo-local integration gate over the existing `SPEC-030` through
`SPEC-038` parser and binding surfaces. CI pins the Flutter, Rust, and
TypeScript jobs to that same snapshot. The WASM wrapper and TypeScript facade
expose this as manifest coverage only; live server/client execution, host-owned
token and sync-token persistence, media transport, retries, storage, UI
behavior, and Matrix full compliance stay outside this repository.

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

Product-specific adapters and policy stay outside this package. Downstream apps
own their route names, room mapping, roles, audit metadata, and integration
glue.

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

### API ownership boundaries

`HouraClient` accepts a `serverBaseUri`, an optional host-owned `http.Client`,
and a per-request timeout. If no HTTP client is passed, `HouraClient.close()`
closes the SDK-created client. If a host passes its own HTTP client, the host
keeps lifecycle ownership.

Authentication calls return tokens and authenticated APIs accept tokens, but the
SDK does not persist access tokens. Sync-token persistence is also host-owned:
call `sync.sync()` with a host-stored `since` value, or inject a
`HouraSyncTokenStore` into `sync.pollOnce()` when a small adapter is useful.

SDK failures are typed as `HouraException` subclasses:

- `HouraTransportException`: request setup, network, timeout, or unsupported
  HTTP method failures before a usable response is available.
- `HouraHttpException`: non-2xx HTTP responses, including parsed contract error
  code and message when the server provides them.
- `HouraResponseFormatException`: successful responses that do not match the
  expected contract shape.
- `HouraThemeFormatException`: malformed shared theme token files.

Media helpers map SPEC-020 metadata and base64 upload shapes only. Hosts still
own media transport policy, storage, retry behavior, cancellation, and UI.

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

Behavior is defined by Houra contracts and test vectors. Existing client and
server implementations are not canonical behavior sources. In particular, the
sibling Matrix client workspace must not be used as a source to copy, translate,
port, or derive Houra behavior while downstream integrations still depend on it.

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

Run these checks before sending SDK-facing changes for review. The same sequence
is the expected local verification for example and API documentation updates.

`tool/check_spec_sync.dart` also runs `../houra-spec/tool/check_spec.dart`
before checking bundled theme, vector references, and the repo-local `SPEC-039`
protocol-core integration gate. If `HOURA_SPEC_ROOT` is set, that path is used
instead of `../houra-spec`.

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

For the TypeScript WASM facade prototype, run:

```bash
cd ts-protocol-core-wasm
npm ci
npm run typecheck
npm test
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
