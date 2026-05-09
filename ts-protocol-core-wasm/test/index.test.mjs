import assert from "node:assert/strict";
import test from "node:test";

import {
  HouraProtocolCoreFacadeError,
  createHouraProtocolCore,
} from "../dist/index.js";

const manifest = {
  manifest_schema_version: 1,
  crate_name: "houra-protocol-core",
  crate_version: "0.1.0",
  abi_version: 1,
  protocol_boundary: "pure-protocol-core",
  supported_specs: ["SPEC-030"],
  supported_binding_kinds: ["wasm"],
};

function binding(overrides = {}) {
  return {
    houraArtifactManifestJson() {
      return JSON.stringify(overrides.manifest ?? manifest);
    },
    parseMatrixClientVersionsResponseJson() {
      return JSON.stringify(
        overrides.parseEnvelope ?? {
          ok: true,
          value: {
            versions: ["v1.18"],
            unstable_features: {},
          },
          error: null,
        },
      );
    },
  };
}

test("validates manifest and maps successful parse envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.manifest.supported_binding_kinds, ["wasm"]);
  const result = core.parseMatrixClientVersionsResponse('{"versions":["v1.18"]}');

  assert.equal(result.ok, true);
  assert.deepEqual(result.value, {
    versions: ["v1.18"],
    unstable_features: {},
  });
  assert.equal(result.error, null);
});

test("returns protocol error envelopes without throwing", () => {
  const core = createHouraProtocolCore(
    binding({
      parseEnvelope: {
        ok: false,
        value: null,
        error: {
          code: "empty_versions",
          message: "versions must not be empty",
          details: {},
        },
      },
    }),
  );

  const result = core.parseMatrixClientVersionsResponse('{"versions":[]}');

  assert.equal(result.ok, false);
  assert.equal(result.value, null);
  assert.deepEqual(result.error, {
    code: "empty_versions",
    message: "versions must not be empty",
    details: {},
  });
});

test("rejects bindings with incompatible manifests", () => {
  assert.throws(
    () =>
      createHouraProtocolCore(
        binding({
          manifest: {
            ...manifest,
            supported_binding_kinds: [],
          },
        }),
      ),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_manifest" &&
      error.message.includes("supported_binding_kinds"),
  );
});

test("rejects malformed parse envelopes", () => {
  const core = createHouraProtocolCore(
    binding({
      parseEnvelope: {
        ok: true,
        value: null,
        error: null,
      },
    }),
  );

  assert.throws(
    () => core.parseMatrixClientVersionsResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope",
  );
});
