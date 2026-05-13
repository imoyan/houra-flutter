import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import test from "node:test";

import {
  HOURA_PROTOCOL_CORE_CRATE_NAME,
  HOURA_PROTOCOL_CORE_CRATE_VERSION,
  HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY,
  HOURA_PROTOCOL_CORE_SPEC_IDS,
  HouraProtocolCoreFacadeError,
  artifactReleaseEvidenceFromManifest,
  createHouraProtocolCore,
} from "../dist/index.js";

const manifest = {
  manifest_schema_version: 1,
  crate_name: HOURA_PROTOCOL_CORE_CRATE_NAME,
  crate_version: HOURA_PROTOCOL_CORE_CRATE_VERSION,
  abi_version: 1,
  protocol_boundary: HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY,
  supported_specs: [...HOURA_PROTOCOL_CORE_SPEC_IDS],
  supported_binding_kinds: ["wasm"],
};

const specRoot = process.env.HOURA_SPEC_ROOT ?? "../../houra-spec";

function readSpecVector(relativePath) {
  const path = join(specRoot, relativePath);
  return JSON.parse(readFileSync(path, "utf8"));
}

function binding(overrides = {}) {
  return {
    houraArtifactManifestJson() {
      return overrides.manifestJson ?? JSON.stringify(overrides.manifest ?? manifest);
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
    parseMatrixEventIdResponseJson() {
      return JSON.stringify(
        overrides.eventIdResponseEnvelope ?? {
          ok: true,
          value: {
            event_id: "$event1:example.test",
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
    parseMatrixMessagesResponseJson() {
      return JSON.stringify(
        overrides.messagesResponseEnvelope ?? {
          ok: true,
          value: {
            chunk: [
              {
                content: {
                  msgtype: "m.text",
                  body: "Hello Matrix",
                },
                event_id: "$event1:example.test",
                origin_server_ts: 1710000000000,
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                type: "m.room.message",
                unsigned: {
                  transaction_id: "txn-1",
                },
              },
            ],
            start: "t1",
            end: "t0",
          },
          error: null,
        },
      );
    },
    parseMatrixSyncResponseJson() {
      return JSON.stringify(
        overrides.syncResponseEnvelope ?? {
          ok: true,
          value: {
            next_batch: "s1",
            account_data: {
              events: [
                {
                  type: "m.push_rules",
                  content: {
                    global: {},
                  },
                },
              ],
            },
            rooms: {
              join: {
                "!room:example.test": {
                  state: {
                    events: [],
                  },
                  timeline: {
                    events: [
                      {
                        content: {
                          msgtype: "m.text",
                          body: "Hello Matrix",
                        },
                        event_id: "$event1:example.test",
                        origin_server_ts: 1710000000000,
                        sender: "@alice:example.test",
                        type: "m.room.message",
                      },
                    ],
                    limited: false,
                    prev_batch: "t0",
                  },
                  account_data: {
                    events: [{ type: "m.tag", content: { tags: {} } }],
                  },
                },
              },
              invite: {},
              leave: {},
            },
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
    parseMatrixMediaContentUriJson() {
      return JSON.stringify(
        overrides.mediaContentUriEnvelope ?? {
          ok: true,
          value: {
            server_name: "example.test",
            media_id: "media1",
          },
          error: null,
        },
      );
    },
    parseMatrixMediaUploadResponseJson() {
      return JSON.stringify(
        overrides.mediaUploadResponseEnvelope ?? {
          ok: true,
          value: {
            content_uri: "mxc://example.test/media1",
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

  assert.equal(core.manifest.crate_name, "houra-protocol-core");
  assert.deepEqual(core.manifest.supported_binding_kinds, ["wasm"]);
  const result = core.parseMatrixClientVersionsResponse('{"versions":["v1.18"]}');

  assert.equal(result.ok, true);
  assert.deepEqual(result.value, {
    versions: ["v1.18"],
    unstable_features: {},
  });
  assert.equal(result.error, null);
});

test("exposes metadata-only release evidence from the artifact manifest", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.releaseEvidence, {
    evidence_kind: "houra-protocol-core-artifact",
    redaction: "metadata-only-no-raw-requests-or-secrets",
    binding_kind: "wasm",
    manifest_schema_version: 1,
    crate_name: "houra-protocol-core",
    crate_version: "0.1.0",
    abi_version: 1,
    protocol_boundary: "pure-protocol-core",
    supported_specs: [...HOURA_PROTOCOL_CORE_SPEC_IDS],
    supported_binding_kinds: ["wasm"],
  });

  assert.deepEqual(
    artifactReleaseEvidenceFromManifest(manifest, {
      specSnapshotRef: "413a3025a32521e4a707d9dd890a10b56328154e",
    }),
    {
      ...core.releaseEvidence,
      spec_snapshot_ref: "413a3025a32521e4a707d9dd890a10b56328154e",
    },
  );
});

test("accepts SPEC-039 integration gate coverage over existing facade surfaces", () => {
  const core = createHouraProtocolCore(binding());
  const gateName = ["matrix", "client", "server", "mvp", "live", "e2e", "gate"].join(
    "-",
  );
  const vector = readSpecVector(`test-vectors/core/${gateName}.json`);

  assert.equal(vector.contract, "SPEC-039");
  assert.equal(
    vector.event.gate,
    ["matrix", "client", "server", "mvp", "live", "e2e"].join("-"),
  );
  assert.equal(vector.event.matrix_spec_version, "v1.18");
  assert.deepEqual(vector.event.conditional_repositories, ["houra-labs"]);
  assert.ok(core.manifest.supported_specs.includes("SPEC-039"));
  for (const contract of vector.event.required_contracts) {
    assert.ok(
      core.manifest.supported_specs.includes(contract),
      `manifest should include ${contract}`,
    );
  }
  assert.equal(vector.event.scenario_steps.length, 12);
  for (const step of vector.event.scenario_steps) {
    assert.ok(
      core.manifest.supported_specs.includes(step.contract),
      `manifest should cover ${step.contract}`,
    );
    for (const vectorPath of step.vectors) {
      assert.ok(
        existsSync(join(specRoot, vectorPath)),
        `canonical vector should exist: ${vectorPath}`,
      );
    }
  }
});

test("accepts SPEC-040 event DAG/auth event vector coverage", () => {
  const core = createHouraProtocolCore(binding());
  const valid = readSpecVector("test-vectors/events/matrix-event-dag-auth-events-basic.json");
  const invalid = readSpecVector(
    "test-vectors/events/matrix-event-dag-auth-events-invalid.json",
  );

  assert.equal(valid.contract, "SPEC-040");
  assert.equal(invalid.contract, "SPEC-040");
  assert.equal(valid.event.matrix_spec_version, "v1.18");
  assert.equal(valid.event.room_version, "12");
  assert.equal(invalid.event.matrix_spec_version, "v1.18");
  assert.ok(core.manifest.supported_specs.includes("SPEC-040"));
  assert.equal(valid.event.events.length, 3);
  assert.equal(valid.expected.candidate_event_id, valid.event.candidate_event_id);
  assert.deepEqual(valid.expected.candidate_prev_events, [
    "$memberAlice000000000000000000000000000000000001",
  ]);
  assert.deepEqual(valid.expected.candidate_auth_events, [
    "$memberAlice000000000000000000000000000000000001",
  ]);

  assert.equal(invalid.expected.error, "M_INVALID_PARAM");
  assert.equal(invalid.event.invalid_cases.length, invalid.expected.invalid_case_count);
  assert.deepEqual(
    invalid.event.invalid_cases.map((invalidCase) => invalidCase.expected_violation),
    [
      "missing_prev_event",
      "duplicate_auth_event",
      "self_prev_event",
      "auth_create_event_v12",
      "prev_event_cycle",
      "duplicate_auth_state_key",
    ],
  );
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

test("maps SPEC-036 Matrix event and messages envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.parseMatrixEventIdResponse('{"event_id":"$event1:example.test"}'), {
    ok: true,
    value: {
      event_id: "$event1:example.test",
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixMessagesResponse('{"chunk":[],"start":"t1"}'), {
    ok: true,
    value: {
      chunk: [
        {
          content: {
            msgtype: "m.text",
            body: "Hello Matrix",
          },
          event_id: "$event1:example.test",
          origin_server_ts: 1710000000000,
          room_id: "!room:example.test",
          sender: "@alice:example.test",
          type: "m.room.message",
          unsigned: {
            transaction_id: "txn-1",
          },
        },
      ],
      start: "t1",
      end: "t0",
    },
    error: null,
  });
});

test("omits absent optional SPEC-036 Matrix messages end token", () => {
  const core = createHouraProtocolCore(
    binding({
      messagesResponseEnvelope: {
        ok: true,
        value: {
          chunk: [],
          start: "t0",
          end: null,
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(core.parseMatrixMessagesResponse("{}"), {
    ok: true,
    value: {
      chunk: [],
      start: "t0",
    },
    error: null,
  });
});

test("maps SPEC-037 Matrix sync envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.parseMatrixSyncResponse("{}"), {
    ok: true,
    value: {
      next_batch: "s1",
      account_data: {
        events: [
          {
            type: "m.push_rules",
            content: {
              global: {},
            },
          },
        ],
      },
      rooms: {
        join: {
          "!room:example.test": {
            state: {
              events: [],
            },
            timeline: {
              events: [
                {
                  content: {
                    msgtype: "m.text",
                    body: "Hello Matrix",
                  },
                  event_id: "$event1:example.test",
                  origin_server_ts: 1710000000000,
                  sender: "@alice:example.test",
                  type: "m.room.message",
                },
              ],
              limited: false,
              prev_batch: "t0",
            },
            account_data: {
              events: [{ type: "m.tag", content: { tags: {} } }],
            },
          },
        },
        invite: {},
        leave: {},
      },
    },
    error: null,
  });
});

test("maps optional SPEC-037 Matrix sync presence and summary envelopes", () => {
  const core = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: {
        ok: true,
        value: {
          next_batch: "s2",
          account_data: { events: [] },
          presence: { events: [] },
          rooms: {
            join: {
              "!room:example.test": {
                state: { events: [] },
                timeline: { events: [], limited: false },
                account_data: { events: [] },
                summary: {
                  "m.joined_member_count": 1,
                  "m.invited_member_count": 0,
                },
                unread_notifications: {
                  notification_count: 0,
                  highlight_count: 0,
                },
              },
            },
            invite: {},
            leave: {},
          },
        },
        error: null,
      },
    }),
  );

  assert.deepEqual(core.parseMatrixSyncResponse("{}"), {
    ok: true,
    value: {
      next_batch: "s2",
      account_data: { events: [] },
      presence: { events: [] },
      rooms: {
        join: {
          "!room:example.test": {
            state: { events: [] },
            timeline: { events: [], limited: false },
            account_data: { events: [] },
            summary: {
              "m.joined_member_count": 1,
              "m.invited_member_count": 0,
            },
            unread_notifications: {
              notification_count: 0,
              highlight_count: 0,
            },
          },
        },
        invite: {},
        leave: {},
      },
    },
    error: null,
  });
});

test("reports joined room context for malformed SPEC-037 sync event lists", () => {
  const syncEnvelopeWithRoom = (joinedRoom) => ({
    ok: true,
    value: {
      next_batch: "s3",
      account_data: { events: [] },
      rooms: {
        join: {
          "!room:example.test": joinedRoom,
        },
        invite: {},
        leave: {},
      },
    },
    error: null,
  });
  const stateCore = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: syncEnvelopeWithRoom({
        state: { events: [null] },
        timeline: { events: [], limited: false },
        account_data: { events: [] },
      }),
    }),
  );

  assert.throws(
    () => stateCore.parseMatrixSyncResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope" &&
      error.message.includes("rooms.join.!room:example.test.state.events.0"),
  );

  const timelineCore = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: syncEnvelopeWithRoom({
        state: { events: [] },
        timeline: { events: [null], limited: false },
        account_data: { events: [] },
      }),
    }),
  );

  assert.throws(
    () => timelineCore.parseMatrixSyncResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope" &&
      error.message.includes("rooms.join.!room:example.test.timeline.events.0"),
  );

  const malformedStateCore = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: syncEnvelopeWithRoom({
        state: {
          events: [
            {
              content: {},
              event_id: null,
              origin_server_ts: 1,
              sender: "@alice:example.test",
              type: "m.room.message",
            },
          ],
        },
        timeline: { events: [], limited: false },
        account_data: { events: [] },
      }),
    }),
  );

  assert.throws(
    () => malformedStateCore.parseMatrixSyncResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope" &&
      error.message.includes(
        "rooms.join.!room:example.test.state.events.0.event_id",
      ),
  );

  const malformedTimelineCore = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: syncEnvelopeWithRoom({
        state: { events: [] },
        timeline: {
          events: [
            {
              content: {},
              event_id: "$event1:example.test",
              origin_server_ts: "1",
              sender: "@alice:example.test",
              type: "m.room.message",
            },
          ],
          limited: false,
        },
        account_data: { events: [] },
      }),
    }),
  );

  assert.throws(
    () => malformedTimelineCore.parseMatrixSyncResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope" &&
      error.message.includes(
        "rooms.join.!room:example.test.timeline.events.0.origin_server_ts",
      ),
  );
});

test("maps SPEC-038 Matrix media envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(core.parseMatrixMediaContentUri("mxc://example.test/media1"), {
    ok: true,
    value: {
      server_name: "example.test",
      media_id: "media1",
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixMediaUploadResponse("{}"), {
    ok: true,
    value: {
      content_uri: "mxc://example.test/media1",
    },
    error: null,
  });
});

test("maps SPEC-038 Matrix media parser failures", () => {
  const core = createHouraProtocolCore(
    binding({
      mediaUploadResponseEnvelope: {
        ok: false,
        value: null,
        error: {
          code: "invalid_media_field",
          message: "content_uri is not a valid Matrix media value",
          details: { field: "content_uri" },
        },
      },
    }),
  );

  assert.deepEqual(core.parseMatrixMediaUploadResponse("{}"), {
    ok: false,
    value: null,
    error: {
      code: "invalid_media_field",
      message: "content_uri is not a valid Matrix media value",
      details: { field: "content_uri" },
    },
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
  for (const [field, value] of [
    ["manifest_schema_version", 2],
    ["crate_name", "other-core"],
    ["crate_version", "9.9.9"],
    ["abi_version", 2],
    ["protocol_boundary", "host-owned-storage"],
    ["supported_specs", [...HOURA_PROTOCOL_CORE_SPEC_IDS].reverse()],
    ["supported_binding_kinds", []],
  ]) {
    assert.throws(
      () =>
        createHouraProtocolCore(
          binding({
            manifest: {
              ...manifest,
              [field]: value,
            },
          }),
        ),
      (error) =>
        error instanceof HouraProtocolCoreFacadeError &&
        error.code === "invalid_manifest" &&
        error.message.includes(field),
    );
  }
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

test("rejects parse envelopes with contradictory value and error fields", () => {
  const successWithError = createHouraProtocolCore(
    binding({
      parseEnvelope: {
        ok: true,
        value: {
          versions: ["v1.18"],
          unstable_features: {},
        },
        error: {
          code: "empty_versions",
          message: "versions must not be empty",
          details: {},
        },
      },
    }),
  );
  assert.throws(
    () => successWithError.parseMatrixClientVersionsResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope",
  );

  const failureWithValue = createHouraProtocolCore(
    binding({
      parseEnvelope: {
        ok: false,
        value: {
          versions: ["v1.18"],
          unstable_features: {},
        },
        error: {
          code: "empty_versions",
          message: "versions must not be empty",
          details: {},
        },
      },
    }),
  );
  assert.throws(
    () => failureWithValue.parseMatrixClientVersionsResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope",
  );
});

test("reports invalid manifest JSON as manifest validation failure", () => {
  assert.throws(
    () => createHouraProtocolCore(binding({ manifestJson: "not json" })),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_manifest" &&
      error.message.includes("artifact manifest"),
  );
});
