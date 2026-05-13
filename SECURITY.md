# Security Policy

## Supported Versions

`houra-labs` is a draft lab repository. Security fixes are handled on `main`
until a release branch policy exists.

No package in this repository is currently published:

- The Flutter package keeps `publish_to: none`.
- The Rust crates keep `publish = false`.
- The TypeScript facade keeps `private: true`.

## Reporting A Vulnerability

Report suspected vulnerabilities through GitHub Security Advisories for this
repository when available. If the advisory feature is unavailable, open a
private contact route with the repository owner before sharing exploit details
in a public issue.

Do not include access tokens, API keys, session values, raw prompts, private
requests, or customer data in public reports.

Public GitHub issues are appropriate for non-sensitive hardening requests,
dependency updates, documentation gaps, and validation failures that do not
expose a working exploit.

## Scope

Security scope is limited to this lab repository:

- Flutter SDK prototype behavior backed by `houra-spec` contracts and vectors.
- Rust protocol-core parser and validation helper experiments.
- Thin WASM and TypeScript facade prototypes.
- Repository checks, package metadata, and release evidence.

Out of scope:

- Production React Native client behavior.
- Production server behavior.
- Business adoption demos and customer integration samples.
- Storage, encryption, federation, and push gateway behavior until matching
  contracts and vectors are adopted here.

`houra-spec` remains the canonical source for behavior. This repository must not
turn artifact metadata, registry listings, GitHub Releases, or external indexes
into normative behavior sources.
