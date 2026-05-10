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
  supported_specs: ["SPEC-030", "SPEC-031", "SPEC-032"],
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
    parseMatrixErrorEnvelopeJson() {
      return JSON.stringify(
        overrides.matrixErrorEnvelope ?? {
          ok: true,
          value: {
            errcode: "M_BAD_JSON",
            error: "Malformed JSON payload.",
            retry_after_ms: null,
          },
          error: null,
        },
      );
    },
    parseMatrixLoginFlowsJson() {
      return JSON.stringify(
        overrides.loginFlowsEnvelope ?? {
          ok: true,
          value: {
            flows: [{ type: "m.login.password" }],
          },
          error: null,
        },
      );
    },
    parseMatrixLoginSessionJson() {
      return JSON.stringify(
        overrides.loginSessionEnvelope ?? {
          ok: true,
          value: {
            user_id: "@alice:example.test",
            access_token: "token-1",
            device_id: "DEVICE1",
            home_server: "example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixWhoamiJson() {
      return JSON.stringify(
        overrides.whoamiEnvelope ?? {
          ok: true,
          value: {
            user_id: "@alice:example.test",
            device_id: "DEVICE1",
            is_guest: false,
          },
          error: null,
        },
      );
    },
    validateMatrixFoundationIdentifiersJson() {
      return JSON.stringify(
        overrides.foundationValidationEnvelope ?? {
          ok: true,
          value: {
            valid: true,
          },
          error: null,
        },
      );
    },
  };
}

test("validates manifest and maps successful versions parse envelopes", () => {
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

test("maps SPEC-031 Matrix error and foundation validation envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.parseMatrixErrorEnvelope('{"errcode":"M_BAD_JSON"}'), {
    ok: true,
    value: {
      errcode: "M_BAD_JSON",
      error: "Malformed JSON payload.",
    },
    error: null,
  });
  assert.deepEqual(core.validateMatrixFoundationIdentifiers("{}"), {
    ok: true,
    value: {
      valid: true,
    },
    error: null,
  });
});

test("maps SPEC-032 Matrix auth/session envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(
    core.parseMatrixLoginFlows('{"flows":[{"type":"m.login.password"}]}'),
    {
      ok: true,
      value: {
        flows: [{ type: "m.login.password" }],
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.parseMatrixLoginSession(
      '{"user_id":"@alice:example.test","access_token":"token-1"}',
    ),
    {
      ok: true,
      value: {
        user_id: "@alice:example.test",
        access_token: "token-1",
        device_id: "DEVICE1",
        home_server: "example.test",
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.parseMatrixWhoami('{"user_id":"@alice:example.test"}'),
    {
      ok: true,
      value: {
        user_id: "@alice:example.test",
        device_id: "DEVICE1",
        is_guest: false,
      },
      error: null,
    },
  );
});

test("omits null optional SPEC-032 Matrix auth/session fields", () => {
  const core = createHouraProtocolCore(
    binding({
      loginSessionEnvelope: {
        ok: true,
        value: {
          user_id: "@alice:example.test",
          access_token: "token-1",
          device_id: null,
          home_server: null,
        },
        error: null,
      },
      whoamiEnvelope: {
        ok: true,
        value: {
          user_id: "@alice:example.test",
          device_id: null,
          is_guest: null,
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(
    core.parseMatrixLoginSession(
      '{"user_id":"@alice:example.test","access_token":"token-1"}',
    ),
    {
      ok: true,
      value: {
        user_id: "@alice:example.test",
        access_token: "token-1",
      },
      error: null,
    },
  );
  assert.deepEqual(core.parseMatrixWhoami('{"user_id":"@alice:example.test"}'), {
    ok: true,
    value: {
      user_id: "@alice:example.test",
    },
    error: null,
  });
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
