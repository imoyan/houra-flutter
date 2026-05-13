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
vectors, `SPEC-038` Matrix media parser vectors, the `SPEC-039` integration
gate vector that ties those parser surfaces together, and the `SPEC-040` Matrix
event DAG/auth-event vectors. It is not published, canonical, or required by
the Flutter SDK.

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
`SPEC-037` / `SPEC-038`; `SPEC-039` and `SPEC-040` are exposed only as manifest
coverage and repo-local vector gates over those existing surfaces.
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
`SPEC-039` / `SPEC-040` manifest coverage, but it does not own HTTP, retries,
cancellation, token storage, UI state, or framework lifecycle.
Generated JS, `.wasm` files, generated-artifact packaging, and Next server /
Node bindings are intentionally left out until a focused package artifact issue
exists. The TypeScript facade metadata below only packages the compiled facade
that wraps a host-provided WASM module.

`ts-protocol-core-wasm/` is the matching TypeScript facade prototype for browser,
Vue, and Next client experiments. It does not load WASM by itself and does not
commit generated artifacts. Instead, a host app passes the generated
`wasm-bindgen` module object into `createHouraProtocolCore()`, and the facade
validates the manifest, ABI version, binding kind, and supported `SPEC-*` ids
before mapping the Rust JSON envelopes into TypeScript result types. This keeps
bundler choice, framework lifecycle, transport, and storage in the host layer.
The facade also validates the crate name, crate version, protocol boundary, and
ordered covered SPEC list before exposing a `releaseEvidence` metadata object.
That evidence is intentionally metadata-only: it records manifest schema,
crate, ABI, binding kind, protocol boundary, supported specs, and an optional
spec snapshot ref, but it must not contain raw requests, prompts, tokens, or
secrets.

WASM / TypeScript facade publish readiness for issue #75: generated
`wasm-bindgen` JavaScript and `.wasm` files stay out of the repository until a
focused package artifact issue decides otherwise. The TypeScript facade package
keeps `private: true`, but defines `exports`, `types`, `files`, `sideEffects`,
and a `prepack` build hook so `npm pack --dry-run` can validate package
contents before a future publish PR. The package artifact contains the compiled
TypeScript facade only; host applications still provide the generated WASM
module object and own bundler choice, browser / Next / Vue lifecycle, HTTP
transport, retry policy, and storage. Publish gates are `npm run typecheck`,
`npm test`, `npm run pack:dry-run`, the Rust/WASM wrapper checks, manifest
fail-closed compatibility, package size review, and follow-up p95 binding
overhead measurement before `private: true` is removed.

TypeScript / WASM npm publish gate for issue #80: the scoped package name stays
`@houra/protocol-core-wasm-facade`, with `exports`, `types`, `files`,
`sideEffects`, `license`, repository, bugs, keywords, and package README
metadata defined while `private: true` remains set. `npm run pack:dry-run` must
show only the compiled facade, package metadata, and package README. Generated
WASM artifacts stay excluded until a separate artifact issue decides whether
they are published or left to host app build steps. Browser ESM is the primary
runtime target; Next and Vue are supported at the facade boundary; Node remains
test/package-validation only until a separate Node or N-API binding issue
adopts a runtime package.

Shared-core parity / performance evidence gate for issue #81: CI keeps Flutter
SDK, Rust protocol core, WASM wrapper, and TypeScript facade checks separate,
then runs `dart run tool/generate_release_evidence.dart` after those gates pass.
The generated evidence records only metadata: head SHA, `houra-spec` snapshot,
covered `SPEC-*` IDs, crate/package versions, ABI and manifest schema versions,
binding kind, package artifact policy, candidate size/performance/runtime
thresholds, and `local-ci` status requirements. It must not store raw requests,
queries, prompts, tokens, or secrets. The gate fails if Rust crate metadata,
TypeScript facade constants, supported `SPEC-*` coverage, or private package
policy drift from the expected release boundary. Current candidate thresholds
are 256 KiB for a future generated WASM binary, 64 KiB for the TypeScript
package tarball, 5 ms p95 parse/validation overhead, and CI runtime targets of
10 minutes for Flutter, 10 minutes for Rust/WASM, 5 minutes for TypeScript, and
2 minutes for the release evidence job.

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
`houra-spec` snapshot `b174d1f4efff37902996d95122f1115e72284d75`
(`v0.2.0-pre.58-13-gb174d1f`) `SPEC-039` Matrix Client-Server MVP live e2e gate
vector as a repo-local integration gate over the existing `SPEC-030` through
`SPEC-038` parser and binding surfaces. CI pins the Flutter, Rust, and
TypeScript jobs to that same snapshot. The WASM wrapper and TypeScript facade
expose this as manifest coverage only; live server/client execution, host-owned
token and sync-token persistence, media transport, retries, storage, UI
behavior, and Matrix full compliance stay outside this repository.

SPEC-040 adoption record: the Rust prototype now consumes the
`houra-spec` snapshot `4b80ab451e43299ff075e352eaa3a512ef2ccee0`
(`v0.2.0-pre.58-16-g4b80ab4`) `SPEC-040` Matrix event DAG/auth-event vectors
as a repo-local vector gate over manifest coverage only. The WASM wrapper and
TypeScript facade expose this as metadata coverage; room storage, full
authorization decisions, state resolution, federation, event signing/hash
verification, host persistence, and Matrix full compliance stay outside this
repository.

Shared-core artifact gate adoption record for issue #74: the TypeScript facade
now fails closed when the Rust artifact manifest has an unexpected manifest
schema version, crate name, crate version, ABI version, protocol boundary,
ordered covered SPEC list, or missing WASM binding kind. The facade exposes
metadata-only release evidence from the validated manifest so release notes can
record artifact compatibility without storing raw query, prompt, request,
token, or secret values.

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
npm run pack:dry-run
```

For shared-core release evidence, run from the repository root after the local
checks above:

```bash
HOURA_SPEC_ROOT=../houra-spec dart run tool/generate_release_evidence.dart \
  --output build/release-evidence/houra-labs-release-evidence.json
```

Treat the generated JSON as CI/release metadata, not a behavior contract. When
using a `local-ci` status instead of repeating heavy GitHub checks, record the
exact head SHA, commands, success result, and spec snapshot in the PR body or
handoff.

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
- Repository metadata: keep `repository`, `issue_tracker`, and package `topics`
  in `pubspec.yaml` aligned with this GitHub repository.
- Publication: keep `publish_to: none`.
- Canonical source: continue reading contracts, vectors, and design tokens from
  `../houra-spec` or `HOURA_SPEC_ROOT`.
- Supported contract claim: keep the public Flutter SDK claim limited to
  SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
  SPEC-010, SPEC-011, and SPEC-020 until matching canonical contracts and
  vectors expand the SDK surface.

Before publishing to pub.dev, open a separate release PR that removes
`publish_to: none` only after package ownership, repository metadata,
versioning, and the final Houra freeze baseline are confirmed.

### Pub.dev Release Gate

Run the release gate from the repository root with the canonical spec checkout
available:

```bash
flutter pub get
HOURA_SPEC_ROOT=../houra-spec dart run tool/check_spec_sync.dart
dart format --set-exit-if-changed .
flutter analyze
HOURA_SPEC_ROOT=../houra-spec flutter test
flutter pub publish --dry-run
```

The current dry-run blocker found during issue #78 was the missing
`CHANGELOG.md`; the package now includes one. The dry run may still report
server-side policy checks after `publish_to: none` is removed in a separate
release PR.

Do not publish from this issue. The release PR must confirm:

- pub.dev package ownership for `houra`
- final package name and version
- repository, issue tracker, topics, license, and changelog metadata
- final `houra-spec` freeze baseline or explicit `HOURA_SPEC_ROOT` snapshot
- no business adoption demo, provider API-key/token example, or production
  client behavior has been added to this repository

## OSS Publication Readiness

Before treating this repository as externally ready, confirm this checklist:

- README, LICENSE, CHANGELOG, issue templates, PR template, and SECURITY policy
  are present and aligned with the lab boundary.
- GitHub repository description and topics identify this as Houra lab prototype
  work, not the canonical specification or production client.
- GitHub Releases are release anchors only. Release notes must record the head
  SHA, `houra-spec` snapshot, generated release evidence artifact, package
  dry-run results, and any known blockers.
- `houra-spec` contracts, test vectors, and design schemas remain the source of
  truth. GitHub Releases, Context7, OpenSSF Scorecard, Best Practices Badge,
  package registries, docs.rs, and other indexes are non-normative.
- Security contact and vulnerability handling stay in `SECURITY.md`; public
  issues must not contain tokens, API keys, raw prompts, private requests, or
  customer data.
- `example/` remains a minimal SDK usage example and does not include business
  adoption demos, provider API-key/token-based examples, customer material, or
  production application policy.

External registration order:

1. Keep `houra-spec` snapshot and release evidence gate passing on `main`.
2. Confirm repository metadata, topics, security policy, and release notes.
3. Add GitHub Release notes and attach release evidence for a tagged lab
   snapshot.
4. Register non-normative documentation indexes such as Context7 only after the
   release anchor exists.
5. Add OpenSSF Scorecard and Best Practices Badge after the security policy and
   release anchor are in place.
6. Handle pub.dev, npm, crates.io, docs.rs, and container registry publication
   through focused package-specific issues.

Current package-specific follow-ups:

- #79: Rust protocol-core crate publication readiness.
- #80: TypeScript / WASM facade npm publish gate. Completed.
- #81: shared-core parity / performance evidence gate. Completed.
- Future package publication issues must remove `publish_to: none`,
  `publish = false`, or `private: true` only after ownership, package name,
  version, artifact evidence, and registry metadata are confirmed.

## Roadmap

The long-term path for this lab package is Flutter SDK hardening, shared theme
adapter stability, and conformance tooling after the spec root is stable. New
SDK surface should be added only after the matching `SPEC-*` contract and test
vector exist.
