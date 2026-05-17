# houra-labs

`houra` is a Flutter SDK prototype for the Houra client API subset.
The name comes from horagai, a conch shell used to signal over distance.

## Status

Draft.

Public Flutter SDK claim: the current draft covers the MVP client profiles from
SPEC-001, SPEC-003, SPEC-004, SPEC-006, SPEC-007, SPEC-008, SPEC-009,
SPEC-010, SPEC-011, and SPEC-020. It also exposes parser-only request
descriptors, public response envelopes, or parser helpers for SPEC-051,
SPEC-052, SPEC-053, SPEC-054, SPEC-057, SPEC-058, SPEC-059, SPEC-069,
SPEC-075, SPEC-076, SPEC-078, SPEC-079, SPEC-083, SPEC-085, SPEC-090,
SPEC-093, SPEC-095, SPEC-097, SPEC-098, SPEC-099, and SPEC-100.

Claim scope rule: shared-core adoption records below do not extend the Flutter
SDK claim unless they explicitly say that the Dart SDK or Flutter SDK
prototype exposes the surface.

The package does not claim Matrix OAuth, E2EE, relation aggregation
correctness, thread ordering, sync long-poll runtime, token persistence,
fanout timing, media binary transfer, thumbnail generation, preview crawling,
remote fetch, range/resumable transfer, encrypted attachment behavior,
federation DNS/TLS runtime, notary fallback, request signature verification,
outbound federation execution, full Room Versions algorithms, Client-Server
support, or Server-Server API support.

## Repository Role

This public repository is for Houra implementation experiments:

- Flutter SDK prototype code.
- Optional Rust/WASM shared protocol-core experiments for benchmark and future
  commonization evidence.
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
- `houra-client` and `houra-server`: the production TypeScript client and server
  implementation path.
- `houra-labs`: optional shared-core and binding candidates kept for parity,
  packaging, startup, p95 benchmark, and rollback evidence.
- `houra-core`: a possible shared protocol / parser / state artifact promoted
  from lab work only after a focused adoption issue accepts the evidence.
- Other language bindings: thin adapters added by demand after the TypeScript
  production path and any adopted shared artifact are stable.
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
event DAG/auth-event vectors. It also parses the `SPEC-045` Matrix profile,
account-data, and room tag parser-only vectors, the `SPEC-046` Matrix receipts,
typing, and read marker parser-only vectors, the `SPEC-047` Matrix filters,
presence, and capabilities parser-only vectors, and the `SPEC-068` Matrix OAuth
account-management parser-only vectors, and the `SPEC-085` Matrix event
retrieval / membership history parser-only vector. It is not published,
canonical, or required by the Flutter SDK, `houra-client`, or `houra-server`.

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
`SPEC-037` / `SPEC-038` / `SPEC-045` / `SPEC-046` / `SPEC-047` / `SPEC-068`;
`SPEC-039` and `SPEC-040` are exposed only as manifest coverage and repo-local
vector gates over those existing surfaces.
Those APIs return a single `ok` / `value` / `error` object so WASM, N-API, FFI,
and JS interop adapters can cross the language boundary once per parse or
validation call instead of bouncing through many small calls. The envelope
carries stable Rust-side error codes for adapter mapping, but it remains
implementation metadata; public behavior still comes from `houra-spec`
contracts and test vectors.

`rust-protocol-core-wasm/` is the first thin binding prototype for browser,
Vue, and Next client experiments. It uses `wasm-bindgen` to export the manifest
and `SPEC-030` / `SPEC-031` / `SPEC-032` / `SPEC-033` / `SPEC-034` /
`SPEC-035` / `SPEC-036` / `SPEC-037` / `SPEC-038` / `SPEC-045` / `SPEC-046` /
`SPEC-047` / `SPEC-068` / `SPEC-085` / `SPEC-090` / `SPEC-093` / `SPEC-095` /
`SPEC-097` JSON envelopes plus `SPEC-039` / `SPEC-040` manifest coverage, but it does not own HTTP,
retries, cancellation, token storage, UI state, or framework lifecycle.
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
and a `prepack` build hook so `npm run pack:dry-run` can validate package
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

Dart FFI / Dart web binding candidate gate for issue #77: Dart native and Dart
web remain candidate adapter paths, not implemented package surfaces. Dart
native FFI is only a candidate for host apps that need a local Rust artifact on
iOS, Android, macOS, Windows, or Linux and can absorb native packaging,
signing, crash reporting, and binary-size review. Dart web JS interop / WASM is
only a candidate for browser-hosted Flutter or Dart web experiments that can
provide the generated WASM module and keep bundler, fetch, retry, cancellation,
and browser lifecycle ownership in the host. The Flutter SDK prototype must not
become the canonical behavior source, and token storage, sync-token persistence,
Flutter UI lifecycle, route policy, and secure storage stay host-owned.
Release evidence records this as `candidate-only-implementation-deferred` with
package publication blocked until platform matrix, artifact size, p95 overhead,
fallback behavior, and registry metadata are confirmed in a focused follow-up.

N-API / Node binding candidate gate for issue #76: a native Node binding remains
a candidate for server-side hosts that need lower overhead, synchronous local
artifact calls, or an operational reason that browser-style WASM cannot cover.
The existing TypeScript / WASM facade remains the fallback path for Next server
experiments, package validation, and hosts where a generated WASM module is
acceptable. N-API adoption is blocked until the platform matrix, prebuild
policy, rebuild trigger, binary-size threshold, p95 overhead threshold, CI
runtime impact, and fallback behavior are confirmed. Node server transport,
request lifecycle, retry policy, cancellation, tenant context, and storage
policy stay host-owned and outside the binding package.

Ecosystem service parser candidate gate for issue #73: SPEC-058, SPEC-059, and
SPEC-060 are service-boundary contracts, not production service implementations.
Labs may adopt parser-only helpers for Application Service registration,
namespace matching, transactions, and query request shapes; Identity Service
hash-details, lookup, validation, bind/unbind, and signed association shapes;
and Push Gateway notify, rejected pushkey, event-id-only, pusher data, and push
rule payload shapes. Service deployment, service tokens, network policy,
privacy enforcement, provider delivery, vendor credentials, and user-facing
consent or notification UI stay outside this repository. Implementation work
must be split into SPEC-sized follow-up issues and tied to the corresponding
`houra-spec/test-vectors/core/matrix-appservice-*`,
`matrix-identity-*`, and `matrix-push-*` vectors.

SPEC-058 Dart SDK adoption record for issue #126: the Flutter SDK prototype now
consumes the `houra-spec` snapshot `26a47461237d30efb2310bd688559b73d6dc998b`
Application Service registration, namespace ownership, transaction, and
user/room-alias query vectors. The Dart SDK exposes parser-only registration
descriptors, namespace regex descriptors, homeserver-to-application-service
request descriptors, transaction envelopes, query descriptors, and
privacy-sensitive redaction helpers. Delivery retry, bridge runtime, token
storage, server mutation, third-party network directories, ping/liveness,
Client-Server masquerading, and Application Service support advertisement remain
server/bridge-owned and fail-closed.

SPEC-075 Dart SDK adoption record for issue #126: the Flutter SDK prototype now
consumes the same `houra-spec` snapshot
`26a47461237d30efb2310bd688559b73d6dc998b` for the Application Service
full-breadth gap inventory vector. The Dart SDK exposes parser evidence and
fail-closed release-evidence checks for the inventory only; it does not claim
runtime ownership for third-party network lookup, ping/liveness, Client-Server
extension masquerading, bridge external URLs, observability, or Matrix
Application Service support advertisement.

SPEC-059 Dart SDK adoption record for issue #127: the Flutter SDK prototype now
consumes the `houra-spec` snapshot `26a47461237d30efb2310bd688559b73d6dc998b`
Identity Service boundary, lookup/hash-details, validation/bind/unbind,
public-key/signature, provider-delivery boundary, and `SPEC-076` full-breadth
gap inventory vectors. The Dart SDK exposes parser-only request descriptors,
public response parsers, Matrix error envelopes, lifecycle evidence cases, and
privacy-sensitive redaction helpers. Provider delivery, consent UI,
contact-upload UX, invitation storage, ephemeral invitation signing, production
key rotation, network lookup, and Identity Service support advertisement remain
host/service-owned and fail-closed. This adoption records representative parser
coverage only; it does not claim Matrix Identity Service full-breadth runtime
support.

SPEC-076 Dart SDK adoption record for issue #127: the Flutter SDK prototype now
consumes the same `houra-spec` snapshot
`26a47461237d30efb2310bd688559b73d6dc998b` for the Identity Service
full-breadth gap inventory vector. The Dart SDK exposes parser evidence and
fail-closed release-evidence checks for the inventory only; it does not claim
runtime ownership for provider delivery, consent UI, invitation storage,
ephemeral invitation signing, or Matrix Identity Service support advertisement.

Federation room-version/state algorithm candidate gate after issue #72 parser
adoption: SPEC-057 parser-only helpers are adopted below, but room-version /
state algorithm helpers remain a separate candidate path and still require
parity vectors, p95 runtime thresholds, payload size/depth limits, artifact
boundary review, and CI runtime impact review before implementation. Server
persistence, missing-event recovery policy, request authentication, federation
retry/backoff, remote trust policy, and full state-resolution correctness stay
server-owned and outside this repository.

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
ownership of crypto, transport, storage, retries, sync-token persistence, or UI
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
vector as a repo-local integration gate over the parser and binding surfaces
that existed at that point. CI pins the Flutter, Rust, and TypeScript jobs to
that same snapshot. The WASM wrapper and TypeScript facade expose SPEC-039
itself as manifest coverage only; live server/client execution, host-owned token
and sync-token persistence, media transport, retries, storage, UI behavior, and
Matrix full compliance stay outside this repository.

SPEC-040 adoption record: the Rust prototype now consumes the
`houra-spec` snapshot `4b80ab451e43299ff075e352eaa3a512ef2ccee0`
(`v0.2.0-pre.58-16-g4b80ab4`) `SPEC-040` Matrix event DAG/auth-event vectors
as a repo-local vector gate over manifest coverage only. The WASM wrapper and
TypeScript facade expose this as metadata coverage; room storage, full
authorization decisions, state resolution, federation, event signing/hash
verification, host persistence, and Matrix full compliance stay outside this
repository.

SPEC-045 shared-core adoption record for issue #60: the Rust prototype now
consumes the `houra-spec` snapshot `397ef7f09154cba053ef87981031ad18b3950dfc`
(`v0.2.0-pre.58-54-g397ef7f`) SPEC-045 profile get/update,
global account-data, room account-data, and room tags vectors for parser-only
profile/account-data/tag surface adoption. The WASM wrapper and TypeScript
facade expose profile response envelopes, profile field update request
descriptors, account-data content envelopes, room tag request descriptors, and
room tags response envelopes without taking ownership of profile storage,
account-data storage, sync-token persistence, authorization decisions, room tag
UI policy, token persistence, or Matrix profile/account-data/tag support
advertisement.

SPEC-046 shared-core adoption record for issue #61: the Rust prototype now
consumes the `houra-spec` snapshot `397ef7f09154cba053ef87981031ad18b3950dfc`
(`v0.2.0-pre.58-54-g397ef7f`) SPEC-046 receipts, invalid receipt thread,
typing, missing-token, read markers, and direct `m.fully_read` account-data
forbidden vectors for parser-only receipts/typing/read-marker surface adoption.
The WASM wrapper and TypeScript facade expose typing request descriptors,
typing ephemeral content envelopes, receipt request descriptors, receipt
ephemeral content envelopes, read markers request descriptors, and fully read
account-data content envelopes without taking ownership of typing delivery,
receipt delivery, unread UI policy, storage persistence, retry policy,
federation EDU delivery, token persistence, or Matrix receipts/typing/read
marker support advertisement.

SPEC-047 shared-core adoption record for issue #62: the Rust prototype now
consumes the `houra-spec` snapshot `397ef7f09154cba053ef87981031ad18b3950dfc`
(`v0.2.0-pre.58-54-g397ef7f`) SPEC-047 filter create/read, filter user
mismatch, presence set/get, presence user mismatch, capabilities, and missing
token vectors for parser-only filters/presence/capabilities surface adoption.
The WASM wrapper and TypeScript facade expose filter definition envelopes,
filter create response envelopes, presence request descriptors, presence
response content envelopes, presence sync event envelopes, and capabilities
response envelopes without taking ownership of server-side filter storage or
execution, presence propagation policy, presence privacy policy, capability
advertisement ownership, unstable MSC advertisement, sync pagination
completeness, or token persistence.

SPEC-048 shared-core adoption record for issue #63: the Rust prototype now
consumes the `houra-spec` snapshot `395c400ba6b025ed983dcf7fa10743b2deac928d`
(`v0.2.0-pre.58-43-g395c400`) SPEC-048 public room directory, filtered public
room search, directory visibility, alias list, invite, stripped invite state,
and representative forbidden-error vectors for parser-only room
directory/alias/invite surface adoption. The WASM wrapper and TypeScript facade
expose request descriptors, public response envelopes, stripped invite state,
and Matrix error JSON envelopes without taking ownership of directory storage,
visibility policy, federation invite signing, remote public room federation,
third-party invite behavior, spaces hierarchy traversal, token persistence, or
Matrix room directory support advertisement.

SPEC-049 shared-core adoption record for issue #64: the Rust prototype now
consumes the `houra-spec` snapshot `395c400ba6b025ed983dcf7fa10743b2deac928d`
(`v0.2.0-pre.58-43-g395c400`) SPEC-049 kick, ban, unban, redaction,
reporting, account moderation capability, admin lock/suspend, and representative
forbidden-error vectors for parser-only moderation/reporting/admin surface
adoption. The WASM wrapper and TypeScript facade expose request descriptors,
redaction response, capability/status envelopes, and Matrix error JSON
envelopes without taking ownership of authorization decisions, policy
enforcement, appeal processes, moderation queue UI, audit logging, federation
enforcement, token persistence, or Matrix moderation support advertisement.

SPEC-051 shared-core adoption record for issue #66: the Rust prototype now
consumes the `houra-spec` snapshot `395c400ba6b025ed983dcf7fa10743b2deac928d`
(`v0.2.0-pre.58-43-g395c400`) SPEC-051 device key upload, one-time key upload,
fallback key upload, one-time/fallback claim, malformed upload, and invalid
algorithm vectors for parser-only device key surface adoption. The WASM wrapper
and TypeScript facade expose key upload request/response, key claim
request/response, and Matrix error JSON envelopes without taking ownership of
Olm/Megolm key generation, private key storage, signature verification, trust
policy decisions, claim lifecycle enforcement, token persistence, or Matrix
E2EE support advertisement.

SPEC-069 shared-core adoption record for issue #65: the Rust prototype now
consumes the `houra-spec` snapshot `395c400ba6b025ed983dcf7fa10743b2deac928d`
(`v0.2.0-pre.58-43-g395c400`) SPEC-069 device key query, all-devices query,
unknown-device omission, missing-token, and malformed timeout vectors for
parser-only device key query adoption. The WASM wrapper and TypeScript facade
expose keys/query request descriptor, public response, and Matrix error JSON
envelopes without taking ownership of signature verification, device trust
decisions, secure storage, crypto verification, device list lifecycle, token
persistence, or Matrix E2EE support advertisement.

SPEC-068 shared-core adoption record for issue #118: the Rust prototype now
consumes the `houra-spec` snapshot `39a7989d32c41a6c1930fe2297ea5d22d13e4866`
(`v0.2.0-pre.58-58-g39a7989`) SPEC-068 Matrix OAuth generic account-management
fallback and device-delete return reconciliation vectors for parser-only account
management helper adoption. The WASM wrapper and TypeScript facade expose auth
metadata parsing, account-management redirect descriptors, generic fallback URL
selection, and post-return device-delete reconciliation signals without taking
ownership of token refresh endpoint execution, browser presentation, transport
retry policy, bearer-token storage, external account-management completion, or
Matrix OAuth support advertisement.

SPEC-085 shared-core adoption record for issue #119: the Rust prototype now
consumes the `houra-spec` snapshot `509f88fe61420c33235dd9e98995963f6cdc918e`
(`v0.2.0-pre.58-64-g509f88f`) SPEC-085 event retrieval / membership history
vector for parser-only Client-Server event retrieval adoption. The Dart SDK,
WASM wrapper, and TypeScript facade expose room event request descriptors,
joined_members response envelopes, members membership chunks, timestamp_to_event
responses, and explicit deprecated compatibility unsupported descriptors
without taking ownership of runtime route behavior, history visibility,
authorization, storage lookup, deprecated endpoint compatibility, token
persistence, or Matrix Client-Server support advertisement.

SPEC-090 shared-core adoption record for issue #120: the Rust prototype now
consumes the `houra-spec` snapshot `6175daf0ba5fa8b5b80f66a7942431e48bfb2a6b`
SPEC-090 relations / threads / reactions vector for parser-only Client-Server
relations adoption. The Dart SDK, WASM wrapper, and TypeScript facade expose
relation request descriptors, relation chunks, thread roots, reaction relation
content, edit relation content, reply relation content, and membership variant
failure envelopes without taking ownership of runtime route behavior, relation
aggregation correctness, thread ordering, fanout, authorization, knock runtime
behavior, restricted join runtime behavior, or Matrix Client-Server support
advertisement.

SPEC-093 shared-core adoption record for issue #121: the Rust prototype now
consumes the `houra-spec` snapshot `b2c4d9894ff9273bdf0c80e8c884c0f1dd8ee94e`
SPEC-093 sync breadth extension vector for parser-only Client-Server sync
extension adoption. The Dart SDK, WASM wrapper, and TypeScript facade expose
sync request descriptors, presence and to-device event snippets, device list
changes, one-time key counts, and invite / leave / knock room section maps
without taking ownership of sync long-poll runtime, sync token persistence,
fanout timing, authorization, filter storage, timeline ordering, device-list
freshness, or Matrix Client-Server support advertisement. The SPEC-093 parser
also treats omitted global and joined-room `account_data` sections as empty
event lists so broad sync extension samples can be inspected without requiring
every legacy SPEC-037 section to be present.

SPEC-095 shared-core adoption record for issue #122: the Rust prototype now
consumes the `houra-spec` snapshot `01f77b9d39275a2e907f0e58f38b7e8fbad57c3f`
SPEC-095 media repository breadth vector for parser-only Client-Server media
repository adoption. The Dart SDK, WASM wrapper, and TypeScript facade expose
media repository request descriptors, media config metadata, URL preview
metadata, thumbnail metadata, async upload metadata, safe
Content-Disposition filename extraction, and Matrix Content URI validation
without taking ownership of binary media transfer, cache persistence,
thumbnail generation, preview crawling, remote fetch, resumable upload runtime,
range requests, encrypted attachment behavior, or Matrix Client-Server support
advertisement.

SPEC-097 shared-core adoption record for issue #123: the Rust prototype now
consumes the `houra-spec` snapshot `e997f74d1ddf19770d45d98ae41c7965c51ba46a`
SPEC-097 federation version/key lifecycle request-auth vector for parser-only
Server-Server federation inspection. The Dart SDK, WASM wrapper, and TypeScript
facade expose federation version metadata, key query lifecycle metadata, server
signing key lifecycle metadata, and request-auth header descriptors without
taking ownership of DNS/TLS runtime, notary fallback, key-cache persistence,
request signature verification, private signing-key storage, outbound
federation execution, or Server-Server API support advertisement.

SPEC-098 Dart SDK adoption record for issue #128: the Flutter SDK prototype now
consumes the `houra-spec` snapshot `26a47461237d30efb2310bd688559b73d6dc998b`
SPEC-098 Push Gateway parser helper vector for parser-only Push Gateway
inspection. The Dart SDK exposes pusher descriptors, push-rule descriptors,
sync visibility evidence cases, malformed descriptor failures, and push
evidence redaction helpers without taking ownership of pusher persistence,
runtime destination lookups, retry queues, provider dispatch, client
notification UI, or Push Gateway support advertisement. Rust/WASM/TypeScript
facade adoption remains a follow-up unless a later shared-core PR explicitly
adds SPEC-098 to the protocol-core manifest.

SPEC-099 Dart SDK adoption record for issue #124: the Flutter SDK prototype now
consumes the `houra-spec` snapshot `26a47461237d30efb2310bd688559b73d6dc998b`
SPEC-099 federation transaction / PDU / EDU parser helper vector. The Dart SDK
exposes parser-only transaction envelopes, typed PDU / EDU envelopes, canonical
JSON input descriptors, and per-PDU response descriptors without taking
ownership of event auth, state resolution, hash calculation, signature
verification, storage mutation, soft-fail policy, outbound federation execution,
or Server-Server API support advertisement.

SPEC-100 Dart SDK adoption record for issue #125: the Flutter SDK prototype now
consumes the `houra-spec` snapshot `26a47461237d30efb2310bd688559b73d6dc998b`
SPEC-100 federation directory / query / OpenID parser helper vector. The Dart
SDK exposes parser-only public rooms, hierarchy, directory query, profile query,
generic query, and OpenID userinfo response descriptors without taking ownership
of remote network fetch, visibility decision, profile privacy policy, OpenID
token verification, trust decision, rate limiting, cache persistence, or
Server-Server API support advertisement.

SPEC-078 / SPEC-083 Dart SDK adoption record for issues #129, #130, and #131:
the Flutter SDK prototype now consumes the `houra-spec` snapshot
`26a47461237d30efb2310bd688559b73d6dc998b` Room Versions gap inventory and
event-decision artifact vectors. The Dart SDK exposes parser-only full-algorithm
gap lane evidence, bounded event-decision artifacts, auth-rule fixture inventory
results, and state-resolution fixture inventory results without taking
ownership of complete authorization algorithms, complete state-resolution
algorithms, event hash calculation, event signature verification, storage
mutation, network lookup, federation get-missing-events runtime, or Room
Versions support advertisement.

SPEC-083 Dart SDK adoption record for issue #129: the Flutter SDK prototype now
uses the bounded event-decision artifact vector as the concrete event-format
fixture surface under the SPEC-078 Room Versions gap inventory. This record is
parser-only and does not add hash calculation, signature verification, event
auth, storage mutation, federation fetch, or Room Versions support
advertisement.

SPEC-079 Dart SDK adoption record for issue #132: the Flutter SDK prototype now
consumes the `houra-spec` snapshot
`26a47461237d30efb2310bd688559b73d6dc998b` Olm/Megolm full E2EE gap inventory
vector. The Dart SDK exposes parser-only gap lane evidence for encrypted event
envelopes, key/backup/verification/cross-signing public payload helper lanes,
and secret/local-path redaction evidence without selecting a crypto stack,
implementing Olm/Megolm primitives, owning secure storage, changing device trust
decisions, or widening Matrix E2EE support advertisement.

SPEC-054 shared-core adoption record for issue #69: the Rust prototype now consumes the
`houra-spec` snapshot `395c400ba6b025ed983dcf7fa10743b2deac928d`
(`v0.2.0-pre.58-43-g395c400`) SPEC-054 SAS verification, cross-signing key
lifecycle, invalid-signature, missing-token, and wrong-device failure vectors
for parser-only verification envelope adoption. The WASM wrapper and TypeScript
facade expose SAS to-device flow, cancel, public cross-signing key upload,
signature upload, invalid-signature failure, missing-token gate, and
wrong-device failure JSON envelopes without taking ownership of local SAS
calculation, Ed25519 verification, Olm/Megolm sessions, cross-signing private
keys, trust decisions, QR verification, account recovery UI, token persistence,
or Matrix E2EE support advertisement.

SPEC-055 adoption record for issue #70: the Rust prototype now consumes the
`houra-spec` SPEC-055 Matrix federation discovery and signing-key vectors for
parser-only federation bootstrap adoption. The WASM wrapper and TypeScript
facade expose server-name, well-known server, signing-key, key-query request,
key-query response, and destination-resolution failure evidence JSON envelopes
without taking ownership of outbound network policy, DNS/SRV/CNAME resolution,
SSRF controls, redirect following, key cache lifecycle, notary trust policy,
request signing, private signing keys, or production federation behavior.

SPEC-056 adoption record for issue #71: the Rust prototype now consumes the
`houra-spec` SPEC-056 Matrix federation transaction, make/send join, and invite
vectors for parser-only federation envelope adoption. The WASM wrapper and
TypeScript facade expose transaction body, transaction response, make_join
response, send_join response, invite request, and invite response JSON
envelopes without taking ownership of request authentication, network send,
retry, storage, event acceptance policy, signing keys, room persistence, or
full federation behavior.

SPEC-057 shared-core adoption record for issue #72: the Rust prototype now
consumes the `houra-spec` SPEC-057 backfill, event_auth, state_ids, and
state-resolution interop vectors for parser-only federation recovery metadata
adoption. The representative state-resolution vector remains a parity anchor
only and does not widen room-version algorithm claims. The Dart SDK,
WASM wrapper, and TypeScript facade expose backfill request shapes, backfill
response PDUs, event-auth PDUs, state IDs responses, and state-resolution
interop records without taking ownership of server persistence, missing-event
recovery policy, request authentication, federation retry/backoff, remote
trust policy, room-version state-resolution algorithms, full state-resolution
correctness, or production federation behavior.

SPEC-069 Dart SDK adoption record for issue #99: the Flutter SDK prototype now
consumes the sibling `houra-spec` `SPEC-069` device key query vectors for
`POST /_matrix/client/v3/keys/query` request descriptor construction, public
device-key response parsing, remote-failure field preservation, unknown
user/device omission behavior, and Matrix `M_*` error-envelope mapping. This is
query-only parser coverage; access-token persistence, transport retry policy,
signature verification, trust UI, secure storage, Olm/Megolm sessions,
encrypted-room behavior, key backup, verification UX, and Matrix E2EE support
advertisement stay outside this repository.

SPEC-051 Dart SDK adoption record for issue #102: the Flutter SDK prototype now
consumes the sibling `houra-spec` `SPEC-051` key upload and claim vectors for
`POST /_matrix/client/v3/keys/upload` and
`POST /_matrix/client/v3/keys/claim` request descriptor construction, public
`one_time_key_counts` parsing, public one-time/fallback key response parsing,
remote-failure field preservation, and Matrix `M_*` error-envelope mapping.
This is parser-only coverage; key generation, key storage, claim lifecycle,
signature verification, trust UI, secure storage, Olm/Megolm sessions,
encrypted-room behavior, key backup, verification UX, and Matrix E2EE support
advertisement stay outside this repository.

SPEC-053 Dart SDK adoption record for issue #68: the Flutter SDK prototype now consumes the
sibling `houra-spec` `SPEC-053` key backup version lifecycle and room-key
session upload / restore vectors for
`POST|GET|PUT /_matrix/client/v3/room_keys/version...` and
`PUT|GET /_matrix/client/v3/room_keys/keys/{roomId}/{sessionId}` request
descriptor construction, public version metadata parsing, public backup-session
metadata parsing, upload response parsing, and Matrix `M_*` error-envelope
mapping. This is parser-only coverage; Megolm backup encryption/decryption,
recovery secret storage, backup ownership authorization policy,
logout/relogin UX, token persistence, and Matrix E2EE support advertisement
stay outside this repository.

SPEC-054 Dart SDK adoption record for issue #69: the Flutter SDK prototype now consumes the
sibling `houra-spec` `SPEC-054` cross-signing and verification vectors for
`POST /_matrix/client/v3/keys/device_signing/upload`,
`POST /_matrix/client/v3/keys/signatures/upload`, optional cross-signing maps
on `POST /_matrix/client/v3/keys/query`, and public SAS verification to-device
content envelope parsing, including cancel and invalid-signature / missing-token
Matrix `M_*` error-envelope mapping. This is parser-only coverage; local SAS
calculation, Ed25519 verification, trust decisions, QR verification, account
recovery UX, token persistence, and Matrix E2EE support advertisement stay
outside this repository.

SPEC-052 Dart SDK adoption record for issue #67: the Flutter SDK prototype now
consumes the sibling `houra-spec` `SPEC-052` to-device and encrypted-room
vectors for `PUT /_matrix/client/v3/sendToDevice/m.room.encrypted/{txnId}`,
`PUT /_matrix/client/v3/rooms/{roomId}/state/m.room.encryption/`,
`PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.encrypted/{txnId}`, and
`GET /_matrix/client/v3/sync` request descriptor / public envelope parsing.
This is envelope-only coverage; Olm/Megolm encryption or decryption, device
trust, key backup, verification UX, secret storage, room-session lifecycle,
federation to-device delivery, and Matrix E2EE support advertisement stay
outside this repository.

Shared-core artifact gate adoption record for issue #74: the TypeScript facade
now fails closed when the Rust artifact manifest has an unexpected manifest
schema version, crate name, crate version, ABI version, protocol boundary,
ordered covered SPEC list, or missing WASM binding kind. The facade exposes
metadata-only release evidence from the validated manifest so release notes can
record artifact compatibility without storing raw query, prompt, request,
token, or secret values.

Shared crypto evidence helper adoption record for issue #133: the release
evidence tool now records `SPEC-079` / `SPEC-081` as evidence-helper
coverage without adding them to the protocol artifact support list. The helper
captures crypto stack name/version/platform metadata when a host selects a
maintained stack, redacts secret-bearing keys and local secret paths, and keeps
Matrix `/versions` plus E2EE support advertisement fail-closed.

Rust protocol-core crate publish readiness for issue #79: the
`rust-protocol-core/` crate now has crates.io-facing package metadata,
docs.rs metadata, and a crate-local README while keeping `publish = false`.
The crate README is the docs.rs / package landing surface for its lab boundary:
the Rust core is a parser / validation helper checked against `houra-spec`, not
canonical behavior and not a Matrix, server, client, storage, crypto, or
federation support claim. Release evidence records this as
`checklist-only-publish-deferred` and keeps package publication blocked until a
focused release PR confirms ownership, removes `publish = false`, reviews the
docs.rs API surface, and passes `cargo package --list` plus
`cargo publish --dry-run` on the release head.

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
before checking bundled theme, vector references, README Status / Pre-1.0
Release Decision Flutter SDK support claims against Dart contract tests and
README adoption records, and the repo-local `SPEC-039` protocol-core
integration gate. If `HOURA_SPEC_ROOT` is set, that path is used instead of
`../houra-spec`.

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
cargo build --locked --release --target wasm32-unknown-unknown
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

For shared-core speed evidence, run the metadata-only benchmark harness:

```bash
HOURA_SPEC_ROOT=../houra-spec dart run tool/benchmark_shared_core.dart \
  --iterations 200 \
  --output build/benchmarks/shared-core-benchmark.json
```

The harness treats the TypeScript facade baseline as the current production-path
comparison point, Rust native as the shared-core candidate, and Dart JSON parsing
as a local runtime baseline. Go remains optional until a focused server-side
shared-core candidate issue adds a Go package. Benchmark output records p95 and
payload-size metadata only; it must not record raw requests, prompts, tokens, or
secrets.

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
  sh -lc 'apt-get update >/tmp/apt-update.log && apt-get install -y rustfmt libstd-rust-dev-wasm32 >/tmp/apt-install.log && rustfmt --check src/lib.rs && cargo test --locked && cargo build --locked --release --target wasm32-unknown-unknown'
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
  SPEC-010, SPEC-011, SPEC-020, SPEC-051, SPEC-052, SPEC-053, SPEC-054,
  SPEC-057, SPEC-058, SPEC-059, SPEC-069, SPEC-075, SPEC-076, SPEC-078,
  SPEC-079, SPEC-083, SPEC-085, SPEC-090, SPEC-093, SPEC-095, SPEC-097,
  SPEC-098, SPEC-099, and SPEC-100.
- Claim expansion rule: shared-core adoption records do not extend the Flutter
  SDK claim unless they explicitly say that the Dart SDK or Flutter SDK
  prototype exposes the surface and matching Dart contract tests plus README
  adoption records document the new surface.

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

The previous dry-run blocker found during issue #78 was the missing
`CHANGELOG.md`; the package now includes one. The dry run may still report
server-side policy checks after `publish_to: none` is removed in a separate
release PR.

Do not publish as part of issue #78 or this release-gate documentation update.
The release PR must confirm:

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

Issue #134 check result on 2026-05-15:

- Pass: README, root `LICENSE`, `CHANGELOG.md`, issue templates, PR template,
  and `SECURITY.md` are present.
- Pass: GitHub repository description identifies Houra lab prototypes for the
  Flutter SDK, Rust protocol core, and thin WASM/TypeScript bindings.
- Pass: package registry publication remains deferred by `publish_to: none`,
  Rust `publish = false`, and TypeScript `private: true`.
- Pass: package dry-run checks are documented and run locally for the
  TypeScript facade; generated package contents remain limited to
  `LICENSE`, `README.md`, `dist/`, and `package.json`.
- Deferred: GitHub Release anchor, Context7, OpenSSF Scorecard, Best Practices
  Badge, pub.dev, npm, crates.io, docs.rs, and container registry publication.
  These stay non-normative and must be handled after a release anchor or in
  focused package-specific issues.
- Fail: none found in this pass.

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

Completed shared-core history:

- #60, #61, #62, #63, and #64 completed SPEC-045 through SPEC-049
  Client-Server parser-only adoption.
- #65, #66, #68, #69, and #118 completed the current E2EE-adjacent and
  OAuth-adjacent parser-only adoption surface for SPEC-069, SPEC-051, SPEC-053,
  SPEC-054, and SPEC-068.
- #70, #71, #72, #123, #124, and #125 completed the current federation
  parser-only adoption surface for SPEC-055, SPEC-056, SPEC-057, SPEC-097,
  SPEC-099, and SPEC-100.
- #73 completed candidate criteria for SPEC-058 through SPEC-060;
  implementation is tracked by the deferred issues below.
- #74, #75, #76, #77, #79, #80, #81, and #82 completed artifact manifest,
  binding candidate, publish-readiness, parity/performance evidence, and OSS
  readiness planning gates.
- #135 completed the post-closeout roadmap split so closed parent tracking
  issues do not need to be reopened.

Deferred implementation backlog:

- #119, #120, #121, and #122 completed the Client-Server parser helper wave for
  event retrieval, relations, sync extensions, and media repository breadth.
- #123, #124, and #125 completed the federation parser helper wave for
  version/key lifecycle, PDU/EDU envelopes, and directory/query/OpenID helpers.
- #128 completed the Dart SDK Push Gateway parser helper surface for pusher,
  push-rule, sync-visibility, malformed descriptor, and redaction evidence.
- #126 completed the Dart SDK Application Service parser helper surface for
  registration descriptors, namespace regex descriptors, transaction envelopes,
  query descriptors, full-breadth gap inventory evidence, and redaction helpers.
- #127 completed the Dart SDK Identity Service parser helper surface for
  request descriptors, public response parsers, error envelopes, lifecycle
  evidence, and redaction helpers.
- #129, #130, and #131 completed the Dart SDK Room Versions parser helper and
  fixture-runner evidence surface for SPEC-078 / SPEC-083.
- #132 completed the Dart SDK E2EE full-breadth parser artifact evidence
  surface for SPEC-079.
- #133 tracks the adopted shared crypto metadata / redaction / release evidence
  helper; future work should extend it only with a focused spec/vector update.

External readiness backlog:

- #134 tracks the external publication checklist, repository metadata, release
  anchor, and non-normative index order.
- #136 tracks release evidence `spec_snapshot_ref` consistency before the next
  release anchor.

Future package publication issues must remove `publish_to: none`,
`publish = false`, or `private: true` only after ownership, package name,
version, artifact evidence, registry metadata, and release evidence are
confirmed.

## Roadmap

The long-term path for this lab package is Flutter SDK hardening, shared theme
adapter stability, and conformance tooling after the spec root is stable. New
SDK surface should be added only after the matching `SPEC-*` contract and test
vector exist.
