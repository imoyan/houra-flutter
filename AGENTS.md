# AGENTS.md

## Scope

This repository is Houra labs. The current package is a Flutter SDK prototype,
not the production client implementation.

## Source of Truth

Use this priority order when implementing behavior:

1. `../houra-spec/contracts/`
2. `../houra-spec/test-vectors/`
3. `../houra-spec/design/`
4. Stable public specifications when a contract explicitly points to them
5. Official Dart and Flutter documentation

If the canonical spec checkout is not available at `../houra-spec`,
set `HOURA_SPEC_ROOT` to its absolute or relative path before running checks.

Do not treat any existing client or server implementation as canonical.

## Clean-Room Rule

Do not copy, translate, port, or derive implementation details from existing
client or server implementations. This includes the sibling Matrix client
workspace, even when it has useful Matrix-oriented code and active downstream
dependents. If behavior is unclear, stop at the contract boundary and request a
contract clarification.

## Repository Boundary

- This package follows `../houra-spec`.
- Do not move canonical behavior into this package.
- Do not treat lab code as canonical or production behavior.
- Keep this repository focused on public SDK, protocol-core, binding, and
  package-usage experiments.
- Do not add business adoption demos, customer proposal samples, legacy-system
  migration walkthroughs, or provider-key-based AI demos here. Keep those in
  separate private integration or adoption sample repositories until they are
  sanitized for publication.
- Keep `example/` limited to minimal SDK usage examples. It must not become a
  business application integration demo.
- Keep production React Native client work in `../houra-client`.
- Keep downstream product semantics outside this repository. Product-specific
  adapters, route names, room mapping, roles, audit metadata, and app policy
  belong in downstream repositories.
- Keep README user-facing and concise.
- Keep Codex-facing rules here.
- Do not add broad publication docs until publication is being prepared.

## Initial Surface

The current package implements:

- SPEC-001 Discovery / Versions
- SPEC-003 Login Flow Discovery
- SPEC-004 Login / Session
- SPEC-006 Room Model
- SPEC-007 Event Model
- SPEC-008 Send Message
- SPEC-009 Room List
- SPEC-010 Timeline
- SPEC-011 Basic Sync
- SPEC-020 Media

Do not add storage, encryption, federation, push gateway compatibility, or full
Matrix compatibility without a matching contract and test-vector update.

Token persistence is host-owned. SDK core may return and attach tokens, but must
not store them.

Sync token persistence is also host-owned and must stay behind an injected
interface.

## Theme Tokens

Shared theme files live under `design/themes/` and must remain platform-neutral.
Client implementations may map the same JSON tokens to native theme systems,
but the token names and light/dark values should remain shared.

The local bundled theme files must match `../houra-spec/design/`.
Run `dart run tool/check_spec_sync.dart` before SDK checks; it also runs the
sibling spec root consistency check.
CI uses `HOURA_SPEC_ROOT` after checking out the sibling
`houra-spec` repository next to this repository.

## Long-Term Guardrails

- Keep the Flutter package as a lab prototype, not the source of behavior.
- Add production React Native work in `../houra-client`, not in this repository.
- Add Go or Dart server prototypes here only after `../houra-spec` passes
  `dart tool/check_spec.dart`.
- Add conformance tooling around canonical vectors before pre-1.0 release prep.
- Run SDK hardening only after the sibling spec freeze checklist exists.
- Keep public API ergonomics, examples, theme adapter stability, and error
  handling docs tied to canonical contracts and vectors.
- Leave pub.dev publication, package name, and versioning for a separate release
  decision issue while `publish_to: none` remains set.
