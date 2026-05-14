# houra-protocol-core

Rust lab prototype for shared Houra protocol parsing and validation.

This crate is not published yet. It remains a lab-only implementation aid for
thin binding experiments until a separate publication issue removes
`publish = false`, confirms package ownership, and records release evidence.

## Boundary

Canonical behavior lives in `houra-spec` contracts and test vectors. This crate
only exposes parser, checker, ABI, and artifact manifest helpers that can be
checked against that source of truth. It must not claim Matrix compatibility,
server behavior, client behavior, storage ownership, crypto ownership, or
federation support.

The artifact manifest is implementation metadata for prebuilt artifacts and
thin bindings. It is not a behavior contract and does not replace the canonical
spec checkout.

## Publish Readiness

Before a publication PR, run from this directory with `houra-spec` available:

```bash
HOURA_SPEC_ROOT=../../houra-spec cargo fmt --check
HOURA_SPEC_ROOT=../../houra-spec cargo test --locked
cargo package --list
cargo publish --dry-run
```

Expected package contents are limited to crate metadata, this README, source
files, and Cargo lock metadata needed for reproducible checks. Test vectors and
contracts stay in `houra-spec`; they are not vendored into the crate package.

Publication remains blocked until:

- crate ownership and final package name are confirmed
- `publish = false` is removed in a focused release PR
- docs.rs API surface is reviewed against the lab boundary above
- `cargo package --list` and `cargo publish --dry-run` pass on the release head
- release evidence records the head SHA, spec snapshot, ABI version, artifact
  manifest schema, supported `SPEC-*` ids, and package dry-run result
