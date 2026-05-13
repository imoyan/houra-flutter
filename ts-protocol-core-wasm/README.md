# @houra/protocol-core-wasm-facade

TypeScript lab facade for the Houra Rust WASM protocol core.

This package does not load or bundle a generated `.wasm` artifact. A host app
passes the generated `wasm-bindgen` module object into `createHouraProtocolCore`.
The host owns bundler choice, browser / Next / Vue lifecycle, HTTP transport,
retry policy, cancellation, and storage.

## Publish Gate

This package remains private. Do not remove `private: true` or publish to npm
until a dedicated publish PR confirms package ownership, registry metadata, and
the final artifact policy.

Before a publish PR, run:

```bash
npm ci
npm run typecheck
npm test
npm run pack:dry-run
```

The package artifact is expected to include only:

- `dist/index.js`
- `dist/index.d.ts`
- `package.json`
- this package README

Generated `wasm-bindgen` JavaScript and `.wasm` files are intentionally excluded
until a package artifact issue decides whether they belong in the package or in
a host app build step.

## Compatibility Gate

The facade fails closed when the Rust artifact manifest reports an unsupported
manifest schema version, crate name, crate version, ABI version, protocol
boundary, ordered `SPEC-*` coverage, or missing WASM binding kind.

Release evidence must stay metadata-only. It may include manifest schema,
crate, ABI, binding kind, protocol boundary, supported specs, and an optional
spec snapshot ref. It must not include raw requests, prompts, tokens, or
secrets.

## Runtime Matrix

- Browser ESM: supported when the host provides the generated WASM module.
- Next / Vue: supported at the facade boundary; framework lifecycle and bundler
  setup remain host-owned.
- Node.js: supported for tests and package validation only until a separate
  Node or N-API binding issue adopts a runtime package.
