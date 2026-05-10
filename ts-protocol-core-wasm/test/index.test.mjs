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
  supported_specs: [
    "SPEC-030",
    "SPEC-031",
    "SPEC-032",
    "SPEC-033",
    "SPEC-034",
    "SPEC-035",
  ],
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
    parseMatrixClientEventJson() {
      return JSON.stringify(
        overrides.clientEventEnvelope ?? {
          ok: true,
          value: {
            content: {
              name: "General",
            },
            event_id: "$name:example.test",
            origin_server_ts: 1710000000000,
            room_id: "!room:example.test",
            sender: "@alice:example.test",
            state_key: "",
            type: "m.room.name",
          },
          error: null,
        },
      );
    },
    parseMatrixDeviceJson() {
      return JSON.stringify(
        overrides.deviceEnvelope ?? {
          ok: true,
          value: {
            device_id: "DEVICE1",
            display_name: "Alice phone",
            last_seen_ip: "203.0.113.10",
            last_seen_ts: 1710000000000,
          },
          error: null,
        },
      );
    },
    parseMatrixDevicesJson() {
      return JSON.stringify(
        overrides.devicesEnvelope ?? {
          ok: true,
          value: {
            devices: [
              {
                device_id: "DEVICE1",
                display_name: "Alice phone",
                last_seen_ip: "203.0.113.10",
                last_seen_ts: 1710000000000,
              },
            ],
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
    parseMatrixRegistrationAvailabilityJson() {
      return JSON.stringify(
        overrides.registrationAvailabilityEnvelope ?? {
          ok: true,
          value: {
            available: true,
          },
          error: null,
        },
      );
    },
    parseMatrixRegistrationSessionJson() {
      return JSON.stringify(
        overrides.registrationSessionEnvelope ?? {
          ok: true,
          value: {
            user_id: "@charlie:example.test",
            access_token: "token-register",
            device_id: "DEVICE2",
            home_server: "example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixRegistrationTokenValidityJson() {
      return JSON.stringify(
        overrides.registrationTokenValidityEnvelope ?? {
          ok: true,
          value: {
            valid: false,
          },
          error: null,
        },
      );
    },
    parseMatrixRoomIdResponseJson() {
      return JSON.stringify(
        overrides.roomIdResponseEnvelope ?? {
          ok: true,
          value: {
            room_id: "!room:example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixRoomStateJson() {
      return JSON.stringify(
        overrides.roomStateEnvelope ?? {
          ok: true,
          value: {
            events: [
              {
                content: {
                  name: "General",
                },
                event_id: "$name:example.test",
                origin_server_ts: 1710000000000,
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                state_key: "",
                type: "m.room.name",
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixUserInteractiveAuthRequiredJson() {
      return JSON.stringify(
        overrides.userInteractiveAuthRequiredEnvelope ?? {
          ok: true,
          value: {
            completed: [],
            flows: [{ stages: ["m.login.dummy"] }],
            params: {},
            session: "reg-session-1",
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

test("maps SPEC-033 Matrix registration envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(
    core.parseMatrixRegistrationAvailability('{"available":true}'),
    {
      ok: true,
      value: {
        available: true,
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.parseMatrixRegistrationSession(
      '{"user_id":"@charlie:example.test","access_token":"token-register"}',
    ),
    {
      ok: true,
      value: {
        user_id: "@charlie:example.test",
        access_token: "token-register",
        device_id: "DEVICE2",
        home_server: "example.test",
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.parseMatrixUserInteractiveAuthRequired(
      '{"completed":[],"flows":[{"stages":["m.login.dummy"]}],"params":{},"session":"reg-session-1"}',
    ),
    {
      ok: true,
      value: {
        completed: [],
        flows: [{ stages: ["m.login.dummy"] }],
        params: {},
        session: "reg-session-1",
      },
      error: null,
    },
  );
  assert.deepEqual(core.parseMatrixRegistrationTokenValidity('{"valid":false}'), {
    ok: true,
    value: {
      valid: false,
    },
    error: null,
  });
});

test("maps optional Matrix user-interactive auth session", () => {
  const core = createHouraProtocolCore(
    binding({
      userInteractiveAuthRequiredEnvelope: {
        ok: true,
        value: {
          completed: [],
          flows: [{ stages: ["m.login.dummy"] }],
          params: {},
          session: null,
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(
    core.parseMatrixUserInteractiveAuthRequired(
      '{"completed":[],"flows":[{"stages":["m.login.dummy"]}],"params":{}}',
    ),
    {
      ok: true,
      value: {
        completed: [],
        flows: [{ stages: ["m.login.dummy"] }],
        params: {},
      },
      error: null,
    },
  );
});

test("maps SPEC-034 Matrix device envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.parseMatrixDevice('{"device_id":"DEVICE1"}'), {
    ok: true,
    value: {
      device_id: "DEVICE1",
      display_name: "Alice phone",
      last_seen_ip: "203.0.113.10",
      last_seen_ts: 1710000000000,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixDevices('{"devices":[]}'), {
    ok: true,
    value: {
      devices: [
        {
          device_id: "DEVICE1",
          display_name: "Alice phone",
          last_seen_ip: "203.0.113.10",
          last_seen_ts: 1710000000000,
        },
      ],
    },
    error: null,
  });
});

test("omits null optional SPEC-034 Matrix device fields", () => {
  const core = createHouraProtocolCore(
    binding({
      deviceEnvelope: {
        ok: true,
        value: {
          device_id: "DEVICE1",
          display_name: null,
          last_seen_ip: null,
          last_seen_ts: null,
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(core.parseMatrixDevice('{"device_id":"DEVICE1"}'), {
    ok: true,
    value: {
      device_id: "DEVICE1",
    },
    error: null,
  });
});

test("maps SPEC-035 Matrix room envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(
    core.parseMatrixRoomIdResponse('{"room_id":"!room:example.test"}'),
    {
      ok: true,
      value: {
        room_id: "!room:example.test",
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.parseMatrixClientEvent(
      '{"event_id":"$name:example.test","room_id":"!room:example.test"}',
    ),
    {
      ok: true,
      value: {
        content: {
          name: "General",
        },
        event_id: "$name:example.test",
        origin_server_ts: 1710000000000,
        room_id: "!room:example.test",
        sender: "@alice:example.test",
        state_key: "",
        type: "m.room.name",
      },
      error: null,
    },
  );
  assert.deepEqual(core.parseMatrixRoomState("[]"), {
    ok: true,
    value: {
      events: [
        {
          content: {
            name: "General",
          },
          event_id: "$name:example.test",
          origin_server_ts: 1710000000000,
          room_id: "!room:example.test",
          sender: "@alice:example.test",
          state_key: "",
          type: "m.room.name",
        },
      ],
    },
    error: null,
  });
});

test("omits null optional SPEC-035 Matrix room event fields", () => {
  const core = createHouraProtocolCore(
    binding({
      clientEventEnvelope: {
        ok: true,
        value: {
          content: {},
          event_id: "$message:example.test",
          origin_server_ts: 1710000000000,
          room_id: "!room:example.test",
          sender: "@alice:example.test",
          state_key: null,
          type: "m.room.message",
          unsigned: null,
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(core.parseMatrixClientEvent("{}"), {
    ok: true,
    value: {
      content: {},
      event_id: "$message:example.test",
      origin_server_ts: 1710000000000,
      room_id: "!room:example.test",
      sender: "@alice:example.test",
      type: "m.room.message",
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
