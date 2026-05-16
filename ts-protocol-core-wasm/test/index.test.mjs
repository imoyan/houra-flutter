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
    parseMatrixFederationInviteRequestJson() {
      return JSON.stringify(
        overrides.federationInviteRequestEnvelope ?? {
          ok: true,
          value: {
            room_version: "12",
            event: {
              type: "m.room.member",
              content: { membership: "invite" },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationInviteResponseJson() {
      return JSON.stringify(
        overrides.federationInviteResponseEnvelope ?? {
          ok: true,
          value: {
            event: {
              type: "m.room.member",
              content: { membership: "invite" },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationDestinationResolutionFailureJson() {
      return JSON.stringify(
        overrides.federationDestinationResolutionFailureEnvelope ?? {
          ok: true,
          value: {
            server_name: "broken.example.test",
            stages: [
              "well_known",
              "srv_matrix_fed",
              "srv_matrix_deprecated",
              "address_records",
              "failure_cache",
            ],
            destination_resolved: false,
            federation_request_sent: false,
            backoff_recorded: true,
          },
          error: null,
        },
      );
    },
    parseMatrixFederationKeyQueryRequestJson() {
      return JSON.stringify(
        overrides.federationKeyQueryRequestEnvelope ?? {
          ok: true,
          value: {
            server_keys: {
              "example.test": {
                "ed25519:auto1": {
                  minimum_valid_until_ts: 1779011408000,
                },
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationKeyQueryResponseJson() {
      return JSON.stringify(
        overrides.federationKeyQueryResponseEnvelope ?? {
          ok: true,
          value: {
            server_keys: [
              {
                server_name: "example.test",
                verify_keys: {
                  "ed25519:auto1": {
                    key: "public",
                  },
                },
                old_verify_keys: {},
                valid_until_ts: 1779011408000,
                signatures: {
                  "example.test": {
                    "ed25519:auto1": "signature",
                  },
                },
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationVersionJson() {
      return JSON.stringify(
        overrides.federationVersionEnvelope ?? {
          ok: true,
          value: {
            server: {
              name: "Houra",
              version: "0.1.0",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationRequestAuthDescriptorJson() {
      return JSON.stringify(
        overrides.federationRequestAuthDescriptorEnvelope ?? {
          ok: true,
          value: {
            scheme: "X-Matrix",
            origin: "example.test",
            destination: "remote.example.test",
            key: "ed25519:auto1",
            sig: "signature",
            signed_json_fields: ["method", "uri"],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationBackfillRequestJson() {
      return JSON.stringify(
        overrides.federationBackfillRequestEnvelope ?? {
          ok: true,
          value: {
            method: "GET",
            path: "/_matrix/federation/v1/backfill/!room:example.test",
            from_event_ids: ["$event3:example.test"],
            limit: 2,
            authorization: {
              scheme: "X-Matrix",
              origin: "remote.example.test",
              destination: "example.test",
              key: "ed25519:auto1",
              signed_json: true,
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationBackfillResponseJson() {
      return JSON.stringify(
        overrides.federationBackfillResponseEnvelope ?? {
          ok: true,
          value: {
            origin: "example.test",
            origin_server_ts: 1778409314000,
            pdus: [
              {
                event_id: "$event2:example.test",
                type: "m.room.message",
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                origin_server_ts: 1778409300000,
                depth: 2,
                prev_events: ["$event1:example.test"],
                auth_events: ["$auth:example.test"],
                content: {
                  msgtype: "m.text",
                  body: "older message",
                },
                hashes: {
                  sha256: "base64-event-content-hash",
                },
                signatures: {
                  "example.test": {
                    "ed25519:auto1": "base64-event-signature",
                  },
                },
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationEventAuthResponseJson() {
      return JSON.stringify(
        overrides.federationEventAuthResponseEnvelope ?? {
          ok: true,
          value: {
            auth_chain: [
              {
                event_id: "$create:example.test",
                type: "m.room.create",
                room_id: "!room:example.test",
                sender: "@creator:example.test",
                origin_server_ts: 1778409000000,
                depth: 1,
                prev_events: [],
                auth_events: [],
                content: {
                  room_version: "12",
                },
                hashes: {
                  sha256: "base64-create-hash",
                },
                signatures: {
                  "example.test": {
                    "ed25519:auto1": "base64-create-signature",
                  },
                },
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationMakeJoinResponseJson() {
      return JSON.stringify(
        overrides.federationMakeJoinResponseEnvelope ?? {
          ok: true,
          value: {
            room_version: "12",
            event: {
              type: "m.room.member",
              content: { membership: "join" },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationStateIdsResponseJson() {
      return JSON.stringify(
        overrides.federationStateIdsResponseEnvelope ?? {
          ok: true,
          value: {
            pdu_ids: [
              "$create:example.test",
              "$auth:example.test",
              "$member:example.test",
            ],
            auth_chain_ids: [
              "$create:example.test",
              "$auth:example.test",
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationStateResolutionInteropRecordJson() {
      return JSON.stringify(
        overrides.federationStateResolutionInteropRecordEnvelope ?? {
          ok: true,
          value: {
            matrix_spec_version: "v1.18",
            matrix_spec_source:
              "https://spec.matrix.org/v1.18/server-server-api/#room-state-resolution",
            checked_at: "2026-05-10T20:55:14+09:00",
            required_contracts: [
              "SPEC-040",
              "SPEC-041",
              "SPEC-043",
              "SPEC-055",
              "SPEC-056",
              "SPEC-057",
            ],
            local_server: "local.example.test",
            remote_server: "remote.example.test",
            room_id: "!room:example.test",
            room_version: "12",
            target_event_id: "$event3:example.test",
            steps: [
              {
                id: "record-event-decision",
                contract: "SPEC-057",
                required: true,
                allowed_results: ["accepted", "soft_failed", "rejected"],
              },
            ],
            required_evidence: [
              "houra_spec_ref",
              "houra_server_ref",
              "local_server",
              "remote_server",
              "room_version",
              "commands",
              "per_step_pass_fail",
              "event_decision",
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationServerNameJson() {
      return JSON.stringify(
        overrides.federationServerNameEnvelope ?? {
          ok: true,
          value: {
            server_name: "delegated.example.test:8448",
            host: "delegated.example.test",
            port: 8448,
          },
          error: null,
        },
      );
    },
    parseMatrixFederationSendJoinResponseJson() {
      return JSON.stringify(
        overrides.federationSendJoinResponseEnvelope ?? {
          ok: true,
          value: {
            origin: "example.test",
            state: [],
            auth_chain: [],
            event: {
              type: "m.room.member",
              content: { membership: "join" },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationSigningKeyJson() {
      return JSON.stringify(
        overrides.federationSigningKeyEnvelope ?? {
          ok: true,
          value: {
            server_name: "example.test",
            verify_keys: {
              "ed25519:auto1": {
                key: "public",
              },
            },
            old_verify_keys: {
              "ed25519:old1": {
                expired_ts: 1777801808000,
                key: "old-public",
              },
            },
            valid_until_ts: 1779011408000,
            signatures: {
              "example.test": {
                "ed25519:auto1": "signature",
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationTransactionJson() {
      return JSON.stringify(
        overrides.federationTransactionEnvelope ?? {
          ok: true,
          value: {
            origin: "remote.example.test",
            origin_server_ts: 1778408851000,
            pdus: [],
            edus: [],
          },
          error: null,
        },
      );
    },
    parseMatrixFederationTransactionResponseJson() {
      return JSON.stringify(
        overrides.federationTransactionResponseEnvelope ?? {
          ok: true,
          value: {
            pdus: {
              "$event1:remote.example.test": {},
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFederationWellKnownServerJson() {
      return JSON.stringify(
        overrides.federationWellKnownServerEnvelope ?? {
          ok: true,
          value: {
            delegated_server_name: "delegated.example.test:8448",
            host: "delegated.example.test",
            port: 8448,
          },
          error: null,
        },
      );
    },
    parseMatrixVerificationSasFlowJson() {
      return JSON.stringify(
        overrides.verificationSasFlowEnvelope ?? {
          ok: true,
          value: {
            transaction_id: "verif-txn-1",
            transport: "to_device",
            event_types: [
              "m.key.verification.request",
              "m.key.verification.ready",
              "m.key.verification.start",
              "m.key.verification.accept",
              "m.key.verification.key",
              "m.key.verification.mac",
            ],
            verified: true,
            local_sas_allowed: false,
            versions_advertisement_widened: false,
          },
          error: null,
        },
      );
    },
    parseMatrixVerificationCancelJson() {
      return JSON.stringify(
        overrides.verificationCancelEnvelope ?? {
          ok: true,
          value: {
            transaction_id: "verif-txn-mismatch",
            code: "m.mismatched_sas",
            reason: "Short authentication string did not match",
            verified: false,
            versions_advertisement_widened: false,
          },
          error: null,
        },
      );
    },
    parseMatrixCrossSigningDeviceSigningUploadJson() {
      return JSON.stringify(
        overrides.crossSigningDeviceSigningUploadEnvelope ?? {
          ok: true,
          value: {
            master_key: {
              user_id: "@alice:example.test",
              usage: ["master"],
              keys: {
                "ed25519:master-public": "master-public",
              },
              signatures: {
                "@alice:example.test": {
                  "ed25519:ALICE1": "signature-of-master-by-device",
                },
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixCrossSigningSignatureUploadJson() {
      return JSON.stringify(
        overrides.crossSigningSignatureUploadEnvelope ?? {
          ok: true,
          value: {
            signed_objects: {
              "@alice:example.test": {
                ALICE2: {
                  user_id: "@alice:example.test",
                  device_id: "ALICE2",
                },
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixCrossSigningInvalidSignatureFailureJson() {
      return JSON.stringify(
        overrides.crossSigningInvalidSignatureFailureEnvelope ?? {
          ok: true,
          value: {
            status: 400,
            errcode: "M_INVALID_SIGNATURE",
            error: "Invalid signature",
          },
          error: null,
        },
      );
    },
    parseMatrixCrossSigningMissingTokenGateJson() {
      return JSON.stringify(
        overrides.crossSigningMissingTokenGateEnvelope ?? {
          ok: true,
          value: {
            protected_key_operations_require_token: true,
            semantic_errors_suppressed_until_authenticated: true,
            auth_precedes_signature_validation: true,
            operations: [
              "missing-token-device-signing-upload",
              "missing-token-keys-query",
              "missing-token-signatures-upload",
            ],
            errcode: "M_MISSING_TOKEN",
          },
          error: null,
        },
      );
    },
    parseMatrixWrongDeviceFailureGateJson() {
      return JSON.stringify(
        overrides.wrongDeviceFailureGateEnvelope ?? {
          ok: true,
          value: {
            trusted_identity: {
              user_id: "@bob:example.test",
              device_id: "BOB1",
              master_key: "trusted-master-public",
              device_key: "trusted-ed25519-device-public",
            },
            observed_identity: {
              user_id: "@bob:example.test",
              device_id: "BOB1",
              master_key: "unexpected-master-public",
              device_key: "unexpected-ed25519-device-public",
            },
            required_steps: [
              "load-established-trust-chain",
              "observe-device-or-master-key-mismatch",
              "refuse-to-mark-device-verified",
              "refuse-outbound-session-share",
              "record-verification-failure",
            ],
            required_evidence: ["trusted_fingerprint", "observed_fingerprint"],
            cancel_code: "m.key_mismatch",
            device_verified: false,
            outbound_session_shared: false,
            requires_user_reverification: true,
            versions_advertisement_widened: false,
          },
          error: null,
        },
      );
    },
    parseMatrixKeysUploadRequestJson() {
      return JSON.stringify(
        overrides.keysUploadRequestEnvelope ?? {
          ok: true,
          value: {
            device_keys: {
              user_id: "@alice:example.test",
              device_id: "DEVICE1",
              algorithms: [
                "m.olm.v1.curve25519-aes-sha2",
                "m.megolm.v1.aes-sha2",
              ],
              keys: {
                "curve25519:DEVICE1": "curve25519-public-device1",
                "ed25519:DEVICE1": "ed25519-public-device1",
              },
              signatures: {
                "@alice:example.test": {
                  "ed25519:DEVICE1": "signature-device1",
                },
              },
            },
            one_time_keys: {
              "signed_curve25519:otk1": {
                key: "one-time-public-key-1",
                fallback: false,
                signatures: {
                  "@alice:example.test": {
                    "ed25519:DEVICE1": "signature-otk1",
                  },
                },
              },
            },
            fallback_keys: {
              "signed_curve25519:fb1": {
                key: "fallback-public-key-1",
                fallback: true,
                signatures: {
                  "@alice:example.test": {
                    "ed25519:DEVICE1": "signature-fb1",
                  },
                },
              },
            },
            private_key_material_returned: false,
          },
          error: null,
        },
      );
    },
    parseMatrixKeysUploadResponseJson() {
      return JSON.stringify(
        overrides.keysUploadResponseEnvelope ?? {
          ok: true,
          value: {
            one_time_key_counts: {
              signed_curve25519: 1,
            },
            private_key_material_returned: false,
          },
          error: null,
        },
      );
    },
    parseMatrixKeysClaimRequestJson() {
      return JSON.stringify(
        overrides.keysClaimRequestEnvelope ?? {
          ok: true,
          value: {
            one_time_keys: {
              "@alice:example.test": {
                DEVICE1: "signed_curve25519",
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixKeysClaimResponseJson() {
      return JSON.stringify(
        overrides.keysClaimResponseEnvelope ?? {
          ok: true,
          value: {
            failures: {},
            one_time_keys: {
              "@alice:example.test": {
                DEVICE1: {
                  "signed_curve25519:fb1": {
                    key: "fallback-public-key-1",
                    fallback: true,
                    signatures: {
                      "@alice:example.test": {
                        "ed25519:DEVICE1": "signature-fb1",
                      },
                    },
                  },
                },
              },
            },
            fallback_key_returned: true,
          },
          error: null,
        },
      );
    },
    parseMatrixDeviceKeyErrorJson() {
      return JSON.stringify(
        overrides.deviceKeyErrorEnvelope ?? {
          ok: true,
          value: {
            status: 400,
            errcode: "M_INVALID_PARAM",
            error: "Unsupported one-time key algorithm.",
          },
          error: null,
        },
      );
    },
    parseMatrixDeviceKeyQueryRequestJson() {
      return JSON.stringify(
        overrides.deviceKeyQueryRequestEnvelope ?? {
          ok: true,
          value: {
            device_keys: {
              "@alice:example.test": ["DEVICE1"],
            },
            timeout: 10000,
          },
          error: null,
        },
      );
    },
    parseMatrixDeviceKeyQueryResponseJson() {
      return JSON.stringify(
        overrides.deviceKeyQueryResponseEnvelope ?? {
          ok: true,
          value: {
            failures: {},
            device_keys: {
              "@alice:example.test": {
                DEVICE1: {
                  user_id: "@alice:example.test",
                  device_id: "DEVICE1",
                  algorithms: [
                    "m.olm.v1.curve25519-aes-sha2",
                    "m.megolm.v1.aes-sha2",
                  ],
                  keys: {
                    "curve25519:DEVICE1": "curve25519-public-device1",
                    "ed25519:DEVICE1": "ed25519-public-device1",
                  },
                  signatures: {
                    "@alice:example.test": {
                      "ed25519:DEVICE1": "signature-device1",
                    },
                  },
                },
              },
            },
            private_key_material_returned: false,
            trust_decision_made: false,
          },
          error: null,
        },
      );
    },
    parseMatrixPublicRoomsRequestJson() {
      return JSON.stringify(
        overrides.publicRoomsRequestEnvelope ?? {
          ok: true,
          value: {
            limit: 10,
            generic_search_term: "project",
            include_all_networks: false,
          },
          error: null,
        },
      );
    },
    parseMatrixPublicRoomsResponseJson() {
      return JSON.stringify(
        overrides.publicRoomsResponseEnvelope ?? {
          ok: true,
          value: {
            chunk: [
              {
                room_id: "!room:example.test",
                num_joined_members: 2,
                world_readable: false,
                guest_can_join: false,
                canonical_alias: "#project:example.test",
                join_rule: "public",
              },
            ],
            total_room_count_estimate: 1,
          },
          error: null,
        },
      );
    },
    parseMatrixDirectoryVisibilityJson() {
      return JSON.stringify(
        overrides.directoryVisibilityEnvelope ?? {
          ok: true,
          value: {
            visibility: "public",
          },
          error: null,
        },
      );
    },
    parseMatrixRoomAliasesJson() {
      return JSON.stringify(
        overrides.roomAliasesEnvelope ?? {
          ok: true,
          value: {
            aliases: ["#project:example.test", "#project-alt:example.test"],
          },
          error: null,
        },
      );
    },
    parseMatrixInviteRequestJson() {
      return JSON.stringify(
        overrides.inviteRequestEnvelope ?? {
          ok: true,
          value: {
            user_id: "@bob:example.test",
            reason: "Join the project room",
          },
          error: null,
        },
      );
    },
    parseMatrixInviteRoomJson() {
      return JSON.stringify(
        overrides.inviteRoomEnvelope ?? {
          ok: true,
          value: {
            room_id: "!room:example.test",
            events: [
              {
                type: "m.room.member",
                sender: "@alice:example.test",
                state_key: "@bob:example.test",
                content: {
                  membership: "invite",
                },
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixRoomDirectoryErrorJson() {
      return JSON.stringify(
        overrides.roomDirectoryErrorEnvelope ?? {
          ok: true,
          value: {
            status: 403,
            errcode: "M_FORBIDDEN",
            error: "User cannot invite others to this room.",
          },
          error: null,
        },
      );
    },
    parseMatrixModerationRequestJson() {
      return JSON.stringify(
        overrides.moderationRequestEnvelope ?? {
          ok: true,
          value: {
            user_id: "@bob:example.test",
            reason: "Off topic",
          },
          error: null,
        },
      );
    },
    parseMatrixRedactionRequestJson() {
      return JSON.stringify(
        overrides.redactionRequestEnvelope ?? {
          ok: true,
          value: {
            reason: "Remove spam",
          },
          error: null,
        },
      );
    },
    parseMatrixRedactionResponseJson() {
      return JSON.stringify(
        overrides.redactionResponseEnvelope ?? {
          ok: true,
          value: {
            event_id: "$redaction1:example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixReportRequestJson() {
      return JSON.stringify(
        overrides.reportRequestEnvelope ?? {
          ok: true,
          value: {
            reason: "Room contains spam",
          },
          error: null,
        },
      );
    },
    parseMatrixAccountModerationCapabilityJson() {
      return JSON.stringify(
        overrides.accountModerationCapabilityEnvelope ?? {
          ok: true,
          value: {
            lock: true,
            suspend: true,
          },
          error: null,
        },
      );
    },
    parseMatrixAdminAccountModerationStatusJson() {
      return JSON.stringify(
        overrides.adminAccountModerationStatusEnvelope ?? {
          ok: true,
          value: {
            locked: true,
          },
          error: null,
        },
      );
    },
    parseMatrixModerationErrorJson() {
      return JSON.stringify(
        overrides.moderationErrorEnvelope ?? {
          ok: true,
          value: {
            status: 403,
            errcode: "M_FORBIDDEN",
            error: "No permission.",
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupVersionCreateResponseJson() {
      return JSON.stringify(
        overrides.keyBackupVersionCreateResponseEnvelope ?? {
          ok: true,
          value: {
            version: "1",
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupVersionJson() {
      return JSON.stringify(
        overrides.keyBackupVersionEnvelope ?? {
          ok: true,
          value: {
            version: "1",
            algorithm: "m.megolm_backup.v1.curve25519-aes-sha2",
            auth_data: {
              public_key: "curve25519-public",
              signatures: {
                "@alice:example.test": {
                  "ed25519:ALICE1": "signature",
                },
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupSessionJson() {
      return JSON.stringify(
        overrides.keyBackupSessionEnvelope ?? {
          ok: true,
          value: {
            first_message_index: 1,
            forwarded_count: 0,
            is_verified: true,
            session_data: {
              ephemeral: "ephemeral",
              ciphertext: "ciphertext",
              mac: "mac",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupSessionUploadResponseJson() {
      return JSON.stringify(
        overrides.keyBackupSessionUploadResponseEnvelope ?? {
          ok: true,
          value: {
            etag: "etag-1",
            count: 1,
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupErrorJson() {
      return JSON.stringify(
        overrides.keyBackupErrorEnvelope ?? {
          ok: true,
          value: {
            status: 403,
            errcode: "M_WRONG_ROOM_KEYS_VERSION",
            error: "Wrong room keys version.",
            current_version: "1",
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupOwnerScopeGateJson() {
      return JSON.stringify(
        overrides.keyBackupOwnerScopeGateEnvelope ?? {
          ok: true,
          value: {
            owner_scope_enforced: true,
            protected_backup_unchanged: true,
            checked_steps: [
              "alice-read-own-backup",
              "bob-read-alice-backup",
              "bob-overwrite-alice-backup",
              "alice-read-backup-after-bob-attempt",
            ],
            versions_advertisement_widened: false,
          },
          error: null,
        },
      );
    },
    parseMatrixKeyBackupRecoveryGateJson() {
      return JSON.stringify(
        overrides.keyBackupRecoveryGateEnvelope ?? {
          ok: true,
          value: {
            logout_relogin_restore: true,
            crypto_stack_required: true,
            local_olm_megolm_allowed: false,
            required_contracts: ["SPEC-050", "SPEC-052", "SPEC-053"],
            required_evidence: [
              "backup_version_created_before_logout",
              "session_uploaded_before_logout",
              "fresh_device_has_no_local_room_key_before_restore",
              "restore_uses_backup_version_with_recovery_secret",
              "decrypted_event_matches_pre_logout_plaintext",
              "versions_advertisement_unchanged",
            ],
            versions_advertisement_widened: false,
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
    parseMatrixEventRetrievalRequestDescriptorJson() {
      return JSON.stringify(
        overrides.eventRetrievalDescriptorEnvelope ?? {
          ok: true,
          value: {
            method: "GET",
            path: "/_matrix/client/v3/rooms/{roomId}/event/{eventId}",
            requires_auth: true,
            response_parser: "client_event",
            adopted_runtime_behavior: true,
          },
          error: null,
        },
      );
    },
    parseMatrixJoinedMembersResponseJson() {
      return JSON.stringify(
        overrides.joinedMembersResponseEnvelope ?? {
          ok: true,
          value: {
            joined: {
              "@alice:example.test": {
                display_name: "Alice",
                avatar_url: "mxc://example.test/alice",
              },
              "@bob:example.test": {},
            },
          },
          error: null,
        },
      );
    },
    parseMatrixMembersResponseJson() {
      return JSON.stringify(
        overrides.membersResponseEnvelope ?? {
          ok: true,
          value: {
            chunk: [
              {
                content: {
                  membership: "join",
                },
                event_id: "$join:example.test",
                origin_server_ts: 1715754500000,
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                state_key: "@alice:example.test",
                type: "m.room.member",
              },
            ],
          },
          error: null,
        },
      );
    },
    parseMatrixTimestampToEventResponseJson() {
      return JSON.stringify(
        overrides.timestampToEventResponseEnvelope ?? {
          ok: true,
          value: {
            event_id: "$event:example.test",
            origin_server_ts: 1715754600000,
          },
          error: null,
        },
      );
    },
    parseMatrixRelationsRequestDescriptorJson() {
      return JSON.stringify(
        overrides.relationsDescriptorEnvelope ?? {
          ok: true,
          value: {
            method: "GET",
            path: "/_matrix/client/v1/rooms/{roomId}/relations/{eventId}",
            requires_auth: true,
            response_parser: "relation_chunk",
            adopted_runtime_behavior: true,
          },
          error: null,
        },
      );
    },
    parseMatrixSyncRequestDescriptorJson() {
      return JSON.stringify(
        overrides.syncDescriptorEnvelope ?? {
          ok: true,
          value: {
            method: "GET",
            path: "/_matrix/client/v3/sync",
            requires_auth: true,
            query_params: {
              filter: "filter-1",
              full_state: true,
              set_presence: "online",
              since: "s1",
              timeout: 0,
              use_state_after: true,
            },
            response_parser: "sync_extensions",
            adopted_runtime_behavior: false,
          },
          error: null,
        },
      );
    },
    parseMatrixRelationChunkResponseJson() {
      return JSON.stringify(
        overrides.relationChunkResponseEnvelope ?? {
          ok: true,
          value: {
            chunk: [
              {
                content: {
                  "m.relates_to": {
                    event_id: "$parent:example.test",
                    key: "+1",
                    rel_type: "m.annotation",
                  },
                },
                event_id: "$reaction:example.test",
                origin_server_ts: 1715754650000,
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                type: "m.reaction",
              },
            ],
            next_batch: "rel_2",
            prev_batch: "rel_0",
          },
          error: null,
        },
      );
    },
    parseMatrixThreadRootsResponseJson() {
      return JSON.stringify(
        overrides.threadRootsResponseEnvelope ?? {
          ok: true,
          value: {
            chunk: [
              {
                content: {
                  body: "Thread root",
                  msgtype: "m.text",
                },
                event_id: "$thread-root:example.test",
                origin_server_ts: 1715754600000,
                room_id: "!room:example.test",
                sender: "@alice:example.test",
                type: "m.room.message",
                unsigned: {
                  "m.relations": {
                    "m.thread": {
                      count: 2,
                      current_user_participated: true,
                      latest_event: {
                        content: {
                          body: "Thread reply",
                          msgtype: "m.text",
                        },
                        event_id: "$thread-reply:example.test",
                        origin_server_ts: 1715754700000,
                        room_id: "!room:example.test",
                        sender: "@bob:example.test",
                        type: "m.room.message",
                      },
                    },
                  },
                },
              },
            ],
            next_batch: "thread_2",
          },
          error: null,
        },
      );
    },
    parseMatrixReactionEventJson() {
      return JSON.stringify(
        overrides.reactionEventEnvelope ?? {
          ok: true,
          value: {
            content: {
              "m.relates_to": {
                event_id: "$parent:example.test",
                key: "+1",
                rel_type: "m.annotation",
              },
            },
            event_id: "$reaction:example.test",
            origin_server_ts: 1715754650000,
            room_id: "!room:example.test",
            sender: "@alice:example.test",
            type: "m.reaction",
          },
          error: null,
        },
      );
    },
    parseMatrixEditEventJson() {
      return JSON.stringify(
        overrides.editEventEnvelope ?? {
          ok: true,
          value: {
            content: {
              body: " * Edited",
              "m.new_content": {
                body: "Edited",
                msgtype: "m.text",
              },
              "m.relates_to": {
                event_id: "$parent:example.test",
                rel_type: "m.replace",
              },
              msgtype: "m.text",
            },
            event_id: "$edit:example.test",
            origin_server_ts: 1715754750000,
            room_id: "!room:example.test",
            sender: "@alice:example.test",
            type: "m.room.message",
          },
          error: null,
        },
      );
    },
    parseMatrixReplyEventJson() {
      return JSON.stringify(
        overrides.replyEventEnvelope ?? {
          ok: true,
          value: {
            content: {
              body: "> <@alice:example.test> Parent\n\nReply",
              "m.relates_to": {
                "m.in_reply_to": {
                  event_id: "$parent:example.test",
                },
              },
              msgtype: "m.text",
            },
            event_id: "$reply:example.test",
            origin_server_ts: 1715754800000,
            room_id: "!room:example.test",
            sender: "@bob:example.test",
            type: "m.room.message",
          },
          error: null,
        },
      );
    },
    parseMatrixProfileResponseJson() {
      return JSON.stringify(
        overrides.profileResponseEnvelope ?? {
          ok: true,
          value: {
            fields: {
              displayname: "Alice",
              avatar_url: "mxc://example.test/avatar-alice",
              "m.tz": "Asia/Tokyo",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixProfileFieldUpdateRequestJson() {
      return JSON.stringify(
        overrides.profileFieldUpdateRequestEnvelope ?? {
          ok: true,
          value: {
            key_name: "displayname",
            value: "Alice Example",
          },
          error: null,
        },
      );
    },
    parseMatrixAccountDataContentJson() {
      return JSON.stringify(
        overrides.accountDataContentEnvelope ?? {
          ok: true,
          value: {
            content: {
              theme: "dark",
              density: "compact",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixRoomTagJson() {
      return JSON.stringify(
        overrides.roomTagEnvelope ?? {
          ok: true,
          value: {
            order: 0.25,
          },
          error: null,
        },
      );
    },
    parseMatrixRoomTagsJson() {
      return JSON.stringify(
        overrides.roomTagsEnvelope ?? {
          ok: true,
          value: {
            tags: {
              "m.favourite": {
                order: 0.25,
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixTypingRequestJson() {
      return JSON.stringify(
        overrides.typingRequestEnvelope ?? {
          ok: true,
          value: {
            typing: true,
            timeout: 30000,
          },
          error: null,
        },
      );
    },
    parseMatrixTypingContentJson() {
      return JSON.stringify(
        overrides.typingContentEnvelope ?? {
          ok: true,
          value: {
            user_ids: ["@alice:example.test"],
          },
          error: null,
        },
      );
    },
    parseMatrixReceiptRequestJson() {
      return JSON.stringify(
        overrides.receiptRequestEnvelope ?? {
          ok: true,
          value: {
            thread_id: "main",
          },
          error: null,
        },
      );
    },
    parseMatrixReceiptContentJson() {
      return JSON.stringify(
        overrides.receiptContentEnvelope ?? {
          ok: true,
          value: {
            receipts: {
              "$event1:example.test": {
                "m.read": {
                  "@alice:example.test": {
                    ts: 1710000001000,
                    thread_id: "main",
                  },
                },
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixReadMarkersRequestJson() {
      return JSON.stringify(
        overrides.readMarkersRequestEnvelope ?? {
          ok: true,
          value: {
            "m.fully_read": "$event1:example.test",
            "m.read": "$event2:example.test",
            "m.read.private": "$event2:example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixFullyReadContentJson() {
      return JSON.stringify(
        overrides.fullyReadContentEnvelope ?? {
          ok: true,
          value: {
            event_id: "$event1:example.test",
          },
          error: null,
        },
      );
    },
    parseMatrixFilterDefinitionJson() {
      return JSON.stringify(
        overrides.filterDefinitionEnvelope ?? {
          ok: true,
          value: {
            event_fields: ["type", "content", "sender"],
            event_format: "client",
            presence: {
              types: ["m.presence"],
            },
            room: {
              timeline: {
                limit: 20,
                types: ["m.room.message"],
              },
              ephemeral: {
                types: ["m.receipt", "m.typing"],
              },
              account_data: {
                types: ["m.tag", "m.fully_read"],
              },
            },
          },
          error: null,
        },
      );
    },
    parseMatrixFilterCreateResponseJson() {
      return JSON.stringify(
        overrides.filterCreateResponseEnvelope ?? {
          ok: true,
          value: {
            filter_id: "filter1",
          },
          error: null,
        },
      );
    },
    parseMatrixPresenceRequestJson() {
      return JSON.stringify(
        overrides.presenceRequestEnvelope ?? {
          ok: true,
          value: {
            presence: "online",
            status_msg: "Available",
          },
          error: null,
        },
      );
    },
    parseMatrixPresenceContentJson() {
      return JSON.stringify(
        overrides.presenceContentEnvelope ?? {
          ok: true,
          value: {
            presence: "online",
            currently_active: true,
            status_msg: "Available",
          },
          error: null,
        },
      );
    },
    parseMatrixPresenceEventJson() {
      return JSON.stringify(
        overrides.presenceEventEnvelope ?? {
          ok: true,
          value: {
            sender: "@alice:example.test",
            type: "m.presence",
            content: {
              presence: "online",
              currently_active: true,
              status_msg: "Available",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixCapabilitiesResponseJson() {
      return JSON.stringify(
        overrides.capabilitiesResponseEnvelope ?? {
          ok: true,
          value: {
            capabilities: {
              "m.change_password": {
                enabled: true,
              },
              "m.forget_forced_upon_leave": {
                enabled: false,
              },
              "m.room_versions": {
                default: "12",
                available: {
                  "12": "stable",
                },
              },
              "m.profile_fields": {
                enabled: true,
                allowed: ["displayname", "avatar_url", "m.tz"],
              },
              "m.set_displayname": {
                enabled: true,
              },
              "m.set_avatar_url": {
                enabled: true,
              },
            },
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
    parseMatrixAuthMetadataJson() {
      return JSON.stringify(
        overrides.authMetadataEnvelope ?? {
          ok: true,
          value: {
            issuer: "https://account.example.test/",
            account_management_uri: "https://account.example.test/manage",
            account_management_actions_supported: [
              "org.matrix.device_delete",
              "org.matrix.account_deactivate",
            ],
          },
          error: null,
        },
      );
    },
    buildMatrixAccountManagementRedirectJson() {
      return JSON.stringify(
        overrides.accountManagementRedirectEnvelope ?? {
          ok: true,
          value: {
            uri: "https://account.example.test/manage?action=org.matrix.device_delete&device_id=DEVICE2",
            action: "org.matrix.device_delete",
            device_id: "DEVICE2",
            generic_fallback: false,
          },
          error: null,
        },
      );
    },
    reconcileMatrixAccountManagementDeviceDeleteJson() {
      return JSON.stringify(
        overrides.accountManagementReconciliationEnvelope ?? {
          ok: true,
          value: {
            deleted_device_id: "DEVICE2",
            missing_device_id: true,
            mark_delete_complete: true,
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
    parseMatrixMediaRepositoryRequestDescriptorJson() {
      return JSON.stringify(
        overrides.mediaRepositoryRequestDescriptorEnvelope ??
          overrides.mediaRepositoryDescriptorEnvelope ?? {
          ok: true,
          value: {
            id: "media-thumbnail",
            method: "GET",
            path: "/_matrix/client/v1/media/thumbnail/{serverName}/{mediaId}",
            path_params: {
              serverName: "example.test",
              mediaId: "media1",
            },
            query_params: {
              width: 64,
              height: 64,
              method: "scale",
              timeout_ms: 0,
              allow_remote: false,
              animated: false,
            },
            requires_auth: true,
            adopted_runtime_behavior: false,
            response_parser: "media_thumbnail_metadata",
          },
          error: null,
        },
      );
    },
    parseMatrixMediaConfigResponseJson() {
      return JSON.stringify(
        overrides.mediaConfigResponseEnvelope ?? overrides.mediaConfigEnvelope ?? {
          ok: true,
          value: {
            "m.upload.size": 10485760,
          },
          error: null,
        },
      );
    },
    parseMatrixMediaPreviewUrlResponseJson() {
      return JSON.stringify(
        overrides.mediaPreviewUrlResponseEnvelope ?? overrides.mediaPreviewEnvelope ?? {
          ok: true,
          value: {
            fields: {
              "og:title": "Example article",
              "og:image": "mxc://example.test/preview1",
            },
          },
          error: null,
        },
      );
    },
    parseMatrixMediaThumbnailMetadataJson() {
      return JSON.stringify(
        overrides.mediaThumbnailMetadataEnvelope ?? overrides.mediaThumbnailEnvelope ?? {
          ok: true,
          value: {
            content_uri: "mxc://example.test/thumb1",
            content_type: "image/png",
            width: 64,
            height: 64,
            method: "scale",
            animated: false,
          },
          error: null,
        },
      );
    },
    parseMatrixMediaUploadCreateResponseJson() {
      return JSON.stringify(
        overrides.mediaUploadCreateResponseEnvelope ?? overrides.mediaUploadCreateEnvelope ?? {
          ok: true,
          value: {
            content_uri: "mxc://example.test/media1",
            unused_expires_at: 1710003600000,
          },
          error: null,
        },
      );
    },
    parseMatrixMediaContentDispositionFilenameJson() {
      return JSON.stringify(
        overrides.mediaContentDispositionFilenameEnvelope ?? overrides.mediaFilenameEnvelope ?? {
          ok: true,
          value: {
            filename: "avatar.png",
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

test("maps SPEC-055 federation discovery and signing-key envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const wellKnown = readSpecVector(
    "test-vectors/core/matrix-federation-well-known-server-basic.json",
  );
  const signingKey = readSpecVector(
    "test-vectors/core/matrix-federation-signing-key-basic.json",
  );
  const keyQuery = readSpecVector(
    "test-vectors/core/matrix-federation-key-query-basic.json",
  );
  const failure = readSpecVector(
    "test-vectors/core/matrix-federation-destination-resolution-failure.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-055"));
  assert.equal(wellKnown.contract, "SPEC-055");
  assert.equal(signingKey.contract, "SPEC-055");
  assert.equal(keyQuery.contract, "SPEC-055");
  assert.equal(failure.contract, "SPEC-055");
  assert.deepEqual(core.parseMatrixFederationServerName("ignored"), {
    ok: true,
    value: {
      server_name: "delegated.example.test:8448",
      host: "delegated.example.test",
      port: 8448,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationWellKnownServer("{}"), {
    ok: true,
    value: {
      delegated_server_name: "delegated.example.test:8448",
      host: "delegated.example.test",
      port: 8448,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationSigningKey("{}"), {
    ok: true,
    value: {
      server_name: "example.test",
      verify_keys: {
        "ed25519:auto1": { key: "public" },
      },
      old_verify_keys: {
        "ed25519:old1": {
          expired_ts: 1777801808000,
          key: "old-public",
        },
      },
      valid_until_ts: 1779011408000,
      signatures: {
        "example.test": { "ed25519:auto1": "signature" },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationKeyQueryRequest("{}"), {
    ok: true,
    value: {
      server_keys: {
        "example.test": {
          "ed25519:auto1": {
            minimum_valid_until_ts: 1779011408000,
          },
        },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationKeyQueryResponse("{}"), {
    ok: true,
    value: {
      server_keys: [
        {
          server_name: "example.test",
          verify_keys: {
            "ed25519:auto1": { key: "public" },
          },
          old_verify_keys: {},
          valid_until_ts: 1779011408000,
          signatures: {
            "example.test": { "ed25519:auto1": "signature" },
          },
        },
      ],
    },
    error: null,
  });
  assert.deepEqual(
    core.parseMatrixFederationDestinationResolutionFailure("{}"),
    {
      ok: true,
      value: {
        server_name: "broken.example.test",
        stages: [
          "well_known",
          "srv_matrix_fed",
          "srv_matrix_deprecated",
          "address_records",
          "failure_cache",
        ],
        destination_resolved: false,
        federation_request_sent: false,
        backoff_recorded: true,
      },
      error: null,
    },
  );
});

test("maps SPEC-097 federation version key lifecycle request-auth envelopes", () => {
  const vector = readSpecVector(
    "test-vectors/core/matrix-federation-version-key-lifecycle-request-auth.json",
  );
  const responses = vector.event.sample_responses;
  const core = createHouraProtocolCore(
    binding({
      federationVersionEnvelope: {
        ok: true,
        value: responses.version,
        error: null,
      },
      federationKeyQueryResponseEnvelope: {
        ok: true,
        value: responses.key_query,
        error: null,
      },
      federationRequestAuthDescriptorEnvelope: {
        ok: true,
        value: responses.request_auth,
        error: null,
      },
    }),
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-097"));
  assert.equal(vector.contract, "SPEC-097");
  assert.equal(vector.expected.descriptor_count, vector.event.request_descriptors.length);
  assert.deepEqual(core.parseMatrixFederationVersion("").value, responses.version);
  assert.deepEqual(
    core.parseMatrixFederationKeyQueryResponse("").value,
    responses.key_query,
  );
  assert.deepEqual(
    core.parseMatrixFederationRequestAuthDescriptor("").value,
    responses.request_auth,
  );
  assert.equal(
    core.parseMatrixFederationKeyQueryResponse("").value.server_keys[0].verify_keys[
      "ed25519:auto2"
    ].key,
    "VGhpcyBpcyBhbm90aGVyIHRlc3QgcHVibGljIGtleQ",
  );
});

test("maps SPEC-057 federation backfill, event auth, and state envelopes", () => {
  const backfill = readSpecVector(
    "test-vectors/events/matrix-federation-backfill-basic.json",
  );
  const eventAuth = readSpecVector(
    "test-vectors/events/matrix-federation-event-auth-basic.json",
  );
  const stateIds = readSpecVector(
    "test-vectors/events/matrix-federation-state-ids-basic.json",
  );
  const interop = readSpecVector(
    "test-vectors/events/matrix-federation-state-resolution-interop-gate.json",
  );
  const representative = readSpecVector(
    "test-vectors/events/matrix-state-resolution-representative.json",
  );
  const core = createHouraProtocolCore(
    binding({
      federationBackfillRequestEnvelope: {
        ok: true,
        value: {
          method: backfill.request.method,
          path: backfill.request.path,
          from_event_ids: backfill.request.query.v,
          limit: backfill.request.query.limit,
          authorization: {
            scheme: backfill.request.authorization.scheme,
            origin: backfill.request.authorization.origin,
            destination: backfill.request.authorization.destination,
            key: backfill.request.authorization.key,
            signed_json: backfill.request.authorization.signed_json,
          },
        },
        error: null,
      },
      federationBackfillResponseEnvelope: {
        ok: true,
        value: backfill.response.body,
        error: null,
      },
      federationEventAuthResponseEnvelope: {
        ok: true,
        value: eventAuth.response.body,
        error: null,
      },
      federationStateIdsResponseEnvelope: {
        ok: true,
        value: stateIds.response.body,
        error: null,
      },
      federationStateResolutionInteropRecordEnvelope: {
        ok: true,
        value: interop.event,
        error: null,
      },
    }),
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-057"));
  assert.equal(backfill.contract, "SPEC-057");
  assert.equal(eventAuth.contract, "SPEC-057");
  assert.equal(stateIds.contract, "SPEC-057");
  assert.equal(interop.contract, "SPEC-057");
  assert.equal(representative.contract, "SPEC-041");
  assert.equal(representative.expected.case_count, 2);
  assert.equal(core.parseMatrixFederationBackfillRequest("").value.limit, 2);
  assert.deepEqual(core.parseMatrixFederationBackfillResponse("").value, backfill.response.body);
  assert.deepEqual(
    core.parseMatrixFederationEventAuthResponse("").value,
    eventAuth.response.body,
  );
  assert.deepEqual(
    core.parseMatrixFederationStateIdsResponse("").value,
    stateIds.response.body,
  );
  assert.equal(
    core.parseMatrixFederationStateResolutionInteropRecord("").value.steps.length,
    interop.event.steps.length,
  );
  assert.deepEqual(
    core.parseMatrixFederationStateResolutionInteropRecord("").value.required_evidence,
    interop.event.required_evidence,
  );
});

test("maps SPEC-054 verification and cross-signing envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const sas = readSpecVector(
    "test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json",
  );
  const cancel = readSpecVector(
    "test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json",
  );
  const lifecycle = readSpecVector(
    "test-vectors/messaging/matrix-cross-signing-key-lifecycle.json",
  );
  const invalidSignature = readSpecVector(
    "test-vectors/messaging/matrix-cross-signing-invalid-signature.json",
  );
  const missingToken = readSpecVector(
    "test-vectors/messaging/matrix-cross-signing-missing-token.json",
  );
  const wrongDevice = readSpecVector(
    "test-vectors/messaging/matrix-wrong-device-failure-gate.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-054"));
  assert.equal(sas.contract, "SPEC-054");
  assert.equal(cancel.contract, "SPEC-054");
  assert.equal(lifecycle.contract, "SPEC-054");
  assert.equal(invalidSignature.contract, "SPEC-054");
  assert.equal(missingToken.contract, "SPEC-054");
  assert.equal(wrongDevice.contract, "SPEC-054");
  assert.deepEqual(core.parseMatrixVerificationSasFlow("{}"), {
    ok: true,
    value: {
      transaction_id: "verif-txn-1",
      transport: "to_device",
      event_types: [
        "m.key.verification.request",
        "m.key.verification.ready",
        "m.key.verification.start",
        "m.key.verification.accept",
        "m.key.verification.key",
        "m.key.verification.mac",
      ],
      verified: true,
      local_sas_allowed: false,
      versions_advertisement_widened: false,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixVerificationCancel("{}"), {
    ok: true,
    value: {
      transaction_id: "verif-txn-mismatch",
      code: "m.mismatched_sas",
      reason: "Short authentication string did not match",
      verified: false,
      versions_advertisement_widened: false,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixCrossSigningDeviceSigningUpload("{}"), {
    ok: true,
    value: {
      master_key: {
        user_id: "@alice:example.test",
        usage: ["master"],
        keys: {
          "ed25519:master-public": "master-public",
        },
        signatures: {
          "@alice:example.test": {
            "ed25519:ALICE1": "signature-of-master-by-device",
          },
        },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixCrossSigningSignatureUpload("{}"), {
    ok: true,
    value: {
      signed_objects: {
        "@alice:example.test": {
          ALICE2: {
            user_id: "@alice:example.test",
            device_id: "ALICE2",
          },
        },
      },
    },
    error: null,
  });
  assert.deepEqual(
    core.parseMatrixCrossSigningInvalidSignatureFailure("{}"),
    {
      ok: true,
      value: {
        status: 400,
        errcode: "M_INVALID_SIGNATURE",
        error: "Invalid signature",
      },
      error: null,
    },
  );
  assert.equal(
    core.parseMatrixCrossSigningMissingTokenGate("{}").value.errcode,
    "M_MISSING_TOKEN",
  );
  const parsedWrongDevice = core.parseMatrixWrongDeviceFailureGate("{}");
  assert.equal(parsedWrongDevice.value.device_verified, false);
  assert.equal(parsedWrongDevice.value.outbound_session_shared, false);
  assert.equal(parsedWrongDevice.value.requires_user_reverification, true);

  const protoKeyCore = createHouraProtocolCore(
    binding({
      crossSigningDeviceSigningUploadEnvelope: {
        ok: true,
        value: {
          master_key: {
            user_id: "@alice:example.test",
            usage: ["master"],
            keys: {
              ["__proto__"]: "master-public",
            },
            signatures: {
              ["__proto__"]: {
                ["__proto__"]: "signature",
              },
            },
          },
        },
        error: null,
      },
      crossSigningSignatureUploadEnvelope: {
        ok: true,
        value: {
          signed_objects: {
            ["__proto__"]: {
              ["__proto__"]: {
                user_id: "@alice:example.test",
              },
            },
          },
        },
        error: null,
      },
    }),
  );
  const protoKeyUpload =
    protoKeyCore.parseMatrixCrossSigningDeviceSigningUpload("{}");
  assert.equal(
    Object.prototype.hasOwnProperty.call(protoKeyUpload.value.master_key.keys, "__proto__"),
    true,
  );
  assert.equal(protoKeyUpload.value.master_key.keys["__proto__"], "master-public");
  assert.equal(
    protoKeyUpload.value.master_key.signatures["__proto__"]["__proto__"],
    "signature",
  );
  const protoSignatureUpload =
    protoKeyCore.parseMatrixCrossSigningSignatureUpload("{}");
  assert.equal(
    protoSignatureUpload.value.signed_objects["__proto__"]["__proto__"].user_id,
    "@alice:example.test",
  );
});

test("maps SPEC-051 device, one-time, and fallback key envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const upload = readSpecVector(
    "test-vectors/auth/matrix-keys-upload-device-one-time-fallback-basic.json",
  );
  const claim = readSpecVector(
    "test-vectors/auth/matrix-keys-claim-one-time-fallback-basic.json",
  );
  const malformedUpload = readSpecVector(
    "test-vectors/auth/matrix-keys-upload-malformed-device-keys.json",
  );
  const invalidClaim = readSpecVector(
    "test-vectors/auth/matrix-keys-claim-invalid-algorithm.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-051"));
  for (const vector of [upload, claim, malformedUpload, invalidClaim]) {
    assert.equal(vector.contract, "SPEC-051");
  }
  assert.deepEqual(core.parseMatrixKeysUploadRequest("{}"), {
    ok: true,
    value: {
      device_keys: {
        user_id: "@alice:example.test",
        device_id: "DEVICE1",
        algorithms: [
          "m.olm.v1.curve25519-aes-sha2",
          "m.megolm.v1.aes-sha2",
        ],
        keys: {
          "curve25519:DEVICE1": "curve25519-public-device1",
          "ed25519:DEVICE1": "ed25519-public-device1",
        },
        signatures: {
          "@alice:example.test": {
            "ed25519:DEVICE1": "signature-device1",
          },
        },
      },
      one_time_keys: {
        "signed_curve25519:otk1": {
          key: "one-time-public-key-1",
          fallback: false,
          signatures: {
            "@alice:example.test": {
              "ed25519:DEVICE1": "signature-otk1",
            },
          },
        },
      },
      fallback_keys: {
        "signed_curve25519:fb1": {
          key: "fallback-public-key-1",
          fallback: true,
          signatures: {
            "@alice:example.test": {
              "ed25519:DEVICE1": "signature-fb1",
            },
          },
        },
      },
      private_key_material_returned: false,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixKeysUploadResponse("{}"), {
    ok: true,
    value: {
      one_time_key_counts: {
        signed_curve25519: 1,
      },
      private_key_material_returned: false,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixKeysClaimRequest("{}"), {
    ok: true,
    value: {
      one_time_keys: {
        "@alice:example.test": {
          DEVICE1: "signed_curve25519",
        },
      },
    },
    error: null,
  });
  assert.equal(
    core.parseMatrixKeysClaimResponse("{}").value.fallback_key_returned,
    true,
  );
  assert.equal(core.parseMatrixDeviceKeyError("{}").value.errcode, "M_INVALID_PARAM");

  const protoKeyCore = createHouraProtocolCore(
    binding({
      keysUploadRequestEnvelope: {
        ok: true,
        value: {
          one_time_keys: {
            ["__proto__"]: {
              key: "one-time-public-key-1",
              fallback: false,
              signatures: {
                ["__proto__"]: {
                  ["__proto__"]: "signature",
                },
              },
            },
          },
          fallback_keys: {},
          private_key_material_returned: false,
        },
        error: null,
      },
    }),
  );
  assert.equal(
    protoKeyCore.parseMatrixKeysUploadRequest("{}").value.one_time_keys["__proto__"]
      .signatures["__proto__"]["__proto__"],
    "signature",
  );
});

test("maps SPEC-069 device key query envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const basic = readSpecVector("test-vectors/auth/matrix-keys-query-basic.json");
  const allDevices = readSpecVector(
    "test-vectors/auth/matrix-keys-query-all-devices.json",
  );
  const unknownDevice = readSpecVector(
    "test-vectors/auth/matrix-keys-query-unknown-device-omitted.json",
  );
  const timeoutNotInteger = readSpecVector(
    "test-vectors/auth/matrix-keys-query-timeout-not-integer.json",
  );
  const missingToken = readSpecVector(
    "test-vectors/auth/matrix-keys-query-missing-token.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-069"));
  for (const vector of [basic, allDevices, unknownDevice, timeoutNotInteger, missingToken]) {
    assert.equal(vector.contract, "SPEC-069");
  }
  assert.deepEqual(core.parseMatrixDeviceKeyQueryRequest("{}"), {
    ok: true,
    value: {
      device_keys: {
        "@alice:example.test": ["DEVICE1"],
      },
      timeout: 10000,
    },
    error: null,
  });
  const response = core.parseMatrixDeviceKeyQueryResponse("{}");
  assert.equal(
    response.value.device_keys["@alice:example.test"].DEVICE1.keys[
      "ed25519:DEVICE1"
    ],
    "ed25519-public-device1",
  );
  assert.equal(response.value.private_key_material_returned, false);
  assert.equal(response.value.trust_decision_made, false);
  assert.equal(
    createHouraProtocolCore(
      binding({
        deviceKeyErrorEnvelope: {
          ok: true,
          value: {
            status: 401,
            errcode: "M_MISSING_TOKEN",
            error: "Missing access token.",
          },
          error: null,
        },
      }),
    ).parseMatrixDeviceKeyError("{}").value.errcode,
    "M_MISSING_TOKEN",
  );
});

test("maps SPEC-045 profile, account data, and room tag envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const profile = readSpecVector("test-vectors/sync/matrix-profile-get-basic.json");
  const profileUpdate = readSpecVector(
    "test-vectors/sync/matrix-profile-displayname-basic.json",
  );
  const globalAccountData = readSpecVector(
    "test-vectors/sync/matrix-account-data-global-basic.json",
  );
  const roomAccountData = readSpecVector(
    "test-vectors/sync/matrix-account-data-room-basic.json",
  );
  const roomTags = readSpecVector("test-vectors/sync/matrix-room-tags-basic.json");

  assert.ok(core.manifest.supported_specs.includes("SPEC-045"));
  for (const vector of [
    profile,
    profileUpdate,
    globalAccountData,
    roomAccountData,
    roomTags,
  ]) {
    assert.equal(vector.contract, "SPEC-045");
  }

  assert.equal(core.parseMatrixProfileResponse("{}").value.fields.displayname, "Alice");
  assert.deepEqual(core.parseMatrixProfileFieldUpdateRequest("{}"), {
    ok: true,
    value: {
      key_name: "displayname",
      value: "Alice Example",
    },
    error: null,
  });
  assert.equal(
    core.parseMatrixAccountDataContent("{}").value.content.density,
    "compact",
  );
  assert.equal(core.parseMatrixRoomTag("{}").value.order, 0.25);
  assert.equal(
    core.parseMatrixRoomTags("{}").value.tags["m.favourite"].order,
    0.25,
  );

  const deletedTagsCore = createHouraProtocolCore(
    binding({
      roomTagsEnvelope: {
        ok: true,
        value: {
          tags: {},
        },
        error: null,
      },
    }),
  );
  assert.deepEqual(deletedTagsCore.parseMatrixRoomTags("{}").value.tags, {});
});

test("maps SPEC-046 receipts, typing, and read marker envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const receipt = readSpecVector("test-vectors/sync/matrix-receipt-basic.json");
  const invalidThread = readSpecVector(
    "test-vectors/sync/matrix-receipt-invalid-thread.json",
  );
  const typing = readSpecVector("test-vectors/sync/matrix-typing-basic.json");
  const missingToken = readSpecVector(
    "test-vectors/sync/matrix-typing-missing-token.json",
  );
  const readMarkers = readSpecVector(
    "test-vectors/sync/matrix-read-markers-basic.json",
  );
  const directForbidden = readSpecVector(
    "test-vectors/sync/matrix-read-marker-direct-account-data-forbidden.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-046"));
  for (const vector of [
    receipt,
    invalidThread,
    typing,
    missingToken,
    readMarkers,
    directForbidden,
  ]) {
    assert.equal(vector.contract, "SPEC-046");
  }

  assert.deepEqual(core.parseMatrixTypingRequest("{}"), {
    ok: true,
    value: {
      typing: true,
      timeout: 30000,
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixTypingContent("{}").value.user_ids, [
    "@alice:example.test",
  ]);
  assert.equal(core.parseMatrixReceiptRequest("{}").value.thread_id, "main");
  assert.equal(
    core.parseMatrixReceiptContent("{}").value.receipts["$event1:example.test"][
      "m.read"
    ]["@alice:example.test"].thread_id,
    "main",
  );
  assert.equal(
    core.parseMatrixReadMarkersRequest("{}").value["m.read.private"],
    "$event2:example.test",
  );
  assert.equal(
    core.parseMatrixFullyReadContent("{}").value.event_id,
    "$event1:example.test",
  );
});

test("maps SPEC-047 filters, presence, and capabilities envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const filter = readSpecVector("test-vectors/sync/matrix-filter-create-read-basic.json");
  const filterMismatch = readSpecVector("test-vectors/sync/matrix-filter-user-mismatch.json");
  const presence = readSpecVector("test-vectors/sync/matrix-presence-set-get-basic.json");
  const presenceMismatch = readSpecVector(
    "test-vectors/sync/matrix-presence-user-mismatch.json",
  );
  const capabilities = readSpecVector("test-vectors/sync/matrix-capabilities-basic.json");
  const missingToken = readSpecVector(
    "test-vectors/sync/matrix-capabilities-missing-token.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-047"));
  for (const vector of [
    filter,
    filterMismatch,
    presence,
    presenceMismatch,
    capabilities,
    missingToken,
  ]) {
    assert.equal(vector.contract, "SPEC-047");
  }

  assert.deepEqual(core.parseMatrixFilterDefinition("{}").value.event_fields, [
    "type",
    "content",
    "sender",
  ]);
  assert.equal(
    core.parseMatrixFilterDefinition("{}").value.room.timeline.limit,
    20,
  );
  assert.equal(
    core.parseMatrixFilterCreateResponse("{}").value.filter_id,
    "filter1",
  );
  assert.equal(core.parseMatrixPresenceRequest("{}").value.presence, "online");
  assert.equal(
    core.parseMatrixPresenceContent("{}").value.currently_active,
    true,
  );
  assert.equal(core.parseMatrixPresenceEvent("{}").value.type, "m.presence");
  assert.equal(
    core.parseMatrixCapabilitiesResponse("{}").value.capabilities[
      "m.room_versions"
    ].default,
    "12",
  );

  const invalidPresenceEventCore = createHouraProtocolCore(
    binding({
      presenceEventEnvelope: {
        ok: true,
        value: {
          sender: "@alice:example.test",
          type: "m.room.message",
          content: {
            presence: "online",
          },
        },
        error: null,
      },
    }),
  );
  assert.throws(
    () => invalidPresenceEventCore.parseMatrixPresenceEvent("{}"),
    HouraProtocolCoreFacadeError,
  );
});

test("maps SPEC-049 moderation, reporting, and admin envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const moderation = readSpecVector(
    "test-vectors/rooms/matrix-room-moderation-kick-ban-unban.json",
  );
  const redaction = readSpecVector(
    "test-vectors/rooms/matrix-room-redaction-basic.json",
  );
  const reporting = readSpecVector(
    "test-vectors/rooms/matrix-room-reporting-basic.json",
  );
  const admin = readSpecVector(
    "test-vectors/rooms/matrix-admin-account-moderation-basic.json",
  );
  const permissionDenied = readSpecVector(
    "test-vectors/rooms/matrix-room-moderation-permission-denied.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-049"));
  for (const vector of [
    moderation,
    redaction,
    reporting,
    admin,
    permissionDenied,
  ]) {
    assert.equal(vector.contract, "SPEC-049");
  }

  assert.deepEqual(core.parseMatrixModerationRequest("{}"), {
    ok: true,
    value: {
      user_id: "@bob:example.test",
      reason: "Off topic",
    },
    error: null,
  });
  assert.equal(
    core.parseMatrixRedactionRequest("{}").value.reason,
    "Remove spam",
  );
  assert.equal(
    core.parseMatrixRedactionResponse("{}").value.event_id,
    "$redaction1:example.test",
  );
  assert.equal(core.parseMatrixReportRequest("{}").value.reason, "Room contains spam");
  assert.deepEqual(core.parseMatrixAccountModerationCapability("{}").value, {
    lock: true,
    suspend: true,
  });
  assert.deepEqual(core.parseMatrixAdminAccountModerationStatus("{}").value, {
    locked: true,
  });
  assert.equal(core.parseMatrixModerationError("{}").value.errcode, "M_FORBIDDEN");
});

test("maps SPEC-048 room directory, alias, and invite envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const publicRooms = readSpecVector(
    "test-vectors/rooms/matrix-public-rooms-basic.json",
  );
  const filtered = readSpecVector(
    "test-vectors/rooms/matrix-public-rooms-filter-basic.json",
  );
  const aliases = readSpecVector(
    "test-vectors/rooms/matrix-room-aliases-basic.json",
  );
  const invite = readSpecVector("test-vectors/rooms/matrix-room-invite-basic.json");

  assert.ok(core.manifest.supported_specs.includes("SPEC-048"));
  for (const vector of [publicRooms, filtered, aliases, invite]) {
    assert.equal(vector.contract, "SPEC-048");
  }
  assert.equal(core.parseMatrixPublicRoomsRequest("{}").value.limit, 10);
  assert.equal(
    core.parseMatrixPublicRoomsResponse("{}").value.chunk[0].canonical_alias,
    "#project:example.test",
  );
  assert.equal(
    core.parseMatrixDirectoryVisibility("{}").value.visibility,
    "public",
  );
  assert.deepEqual(core.parseMatrixRoomAliases("{}").value.aliases, [
    "#project:example.test",
    "#project-alt:example.test",
  ]);
  assert.equal(core.parseMatrixInviteRequest("{}").value.user_id, "@bob:example.test");
  assert.equal(
    core.parseMatrixInviteRoom("{}").value.events[0].content.membership,
    "invite",
  );
  assert.equal(
    core.parseMatrixRoomDirectoryError("{}").value.errcode,
    "M_FORBIDDEN",
  );
});

test("maps SPEC-053 key backup metadata envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const lifecycle = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-version-lifecycle.json",
  );
  const restore = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json",
  );
  const wrongVersion = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-wrong-version.json",
  );
  const missingSession = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-restore-missing-session.json",
  );
  const ownerScope = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-owner-scope.json",
  );
  const recoveryGate = readSpecVector(
    "test-vectors/messaging/matrix-key-backup-logout-relogin-recovery-gate.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-053"));
  for (const vector of [
    lifecycle,
    restore,
    wrongVersion,
    missingSession,
    ownerScope,
    recoveryGate,
  ]) {
    assert.equal(vector.contract, "SPEC-053");
  }
  assert.equal(lifecycle.event.steps.length, 4);
  assert.equal(restore.event.steps.length, 2);
  assert.deepEqual(core.parseMatrixKeyBackupVersionCreateResponse("{}"), {
    ok: true,
    value: {
      version: "1",
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixKeyBackupVersion("{}"), {
    ok: true,
    value: {
      version: "1",
      algorithm: "m.megolm_backup.v1.curve25519-aes-sha2",
      auth_data: {
        public_key: "curve25519-public",
        signatures: {
          "@alice:example.test": {
            "ed25519:ALICE1": "signature",
          },
        },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixKeyBackupSession("{}"), {
    ok: true,
    value: {
      first_message_index: 1,
      forwarded_count: 0,
      is_verified: true,
      session_data: {
        ephemeral: "ephemeral",
        ciphertext: "ciphertext",
        mac: "mac",
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixKeyBackupSessionUploadResponse("{}"), {
    ok: true,
    value: {
      etag: "etag-1",
      count: 1,
    },
    error: null,
  });
  assert.equal(
    core.parseMatrixKeyBackupError("{}").value.errcode,
    "M_WRONG_ROOM_KEYS_VERSION",
  );
  assert.equal(core.parseMatrixKeyBackupError("{}").value.current_version, "1");
  assert.equal(
    createHouraProtocolCore(
      binding({
        keyBackupErrorEnvelope: {
          ok: true,
          value: {
            status: 404,
            errcode: "M_NOT_FOUND",
            error: "Room key session not found.",
          },
          error: null,
        },
      }),
    ).parseMatrixKeyBackupError("{}").value.errcode,
    "M_NOT_FOUND",
  );
  assert.equal(
    core.parseMatrixKeyBackupOwnerScopeGate("{}").value.owner_scope_enforced,
    true,
  );
  assert.equal(
    core.parseMatrixKeyBackupRecoveryGate("{}").value.local_olm_megolm_allowed,
    false,
  );

  const protoKeyCore = createHouraProtocolCore(
    binding({
      keyBackupVersionEnvelope: {
        ok: true,
        value: {
          algorithm: "m.megolm_backup.v1.curve25519-aes-sha2",
          auth_data: {
            public_key: "curve25519-public",
            signatures: {
              ["__proto__"]: {
                ["__proto__"]: "signature",
              },
            },
          },
        },
        error: null,
      },
    }),
  );
  assert.equal(
    protoKeyCore.parseMatrixKeyBackupVersion("{}").value.auth_data.signatures[
      "__proto__"
    ]["__proto__"],
    "signature",
  );
});

test("maps SPEC-056 federation transaction, join, and invite envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const transaction = readSpecVector(
    "test-vectors/events/matrix-federation-send-transaction-basic.json",
  );
  const failedTransaction = readSpecVector(
    "test-vectors/events/matrix-federation-send-transaction-pdu-failure.json",
  );
  const join = readSpecVector(
    "test-vectors/events/matrix-federation-make-send-join-basic.json",
  );
  const invite = readSpecVector(
    "test-vectors/events/matrix-federation-invite-v2-basic.json",
  );

  assert.ok(core.manifest.supported_specs.includes("SPEC-056"));
  assert.equal(transaction.contract, "SPEC-056");
  assert.equal(failedTransaction.contract, "SPEC-056");
  assert.equal(join.contract, "SPEC-056");
  assert.equal(invite.contract, "SPEC-056");
  assert.deepEqual(core.parseMatrixFederationTransaction("{}"), {
    ok: true,
    value: {
      origin: "remote.example.test",
      origin_server_ts: 1778408851000,
      pdus: [],
      edus: [],
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationTransactionResponse("{}"), {
    ok: true,
    value: {
      pdus: {
        "$event1:remote.example.test": {},
      },
    },
    error: null,
  });
  const protoKeyCore = createHouraProtocolCore(
    binding({
      federationTransactionResponseEnvelope: {
        ok: true,
        value: {
          pdus: {
            ["__proto__"]: { error: "blocked" },
          },
        },
        error: null,
      },
    }),
  );
  const protoKeyResponse =
    protoKeyCore.parseMatrixFederationTransactionResponse("{}");
  assert.equal(Object.prototype.blocked, undefined);
  assert.equal(
    Object.prototype.hasOwnProperty.call(protoKeyResponse.value.pdus, "__proto__"),
    true,
  );
  assert.equal(protoKeyResponse.value.pdus.__proto__.error, "blocked");
  assert.equal(join.event.steps[1].body.event.content.membership, "join");
  assert.deepEqual(core.parseMatrixFederationMakeJoinResponse("{}"), {
    ok: true,
    value: {
      room_version: "12",
      event: {
        type: "m.room.member",
        content: { membership: "join" },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationSendJoinResponse("{}"), {
    ok: true,
    value: {
      origin: "example.test",
      state: [],
      auth_chain: [],
      event: {
        type: "m.room.member",
        content: { membership: "join" },
      },
    },
    error: null,
  });
  assert.equal(invite.request.body.event.content.membership, "invite");
  assert.deepEqual(core.parseMatrixFederationInviteRequest("{}"), {
    ok: true,
    value: {
      room_version: "12",
      event: {
        type: "m.room.member",
        content: { membership: "invite" },
      },
    },
    error: null,
  });
  assert.deepEqual(core.parseMatrixFederationInviteResponse("{}"), {
    ok: true,
    value: {
      event: {
        type: "m.room.member",
        content: { membership: "invite" },
      },
    },
    error: null,
  });
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

test("maps SPEC-068 Matrix account management helper envelopes", () => {
  const core = createHouraProtocolCore(binding());

  assert.deepEqual(
    core.parseMatrixAuthMetadata('{"account_management_uri":"https://account.example.test/manage"}'),
    {
      ok: true,
      value: {
        issuer: "https://account.example.test/",
        account_management_uri: "https://account.example.test/manage",
        account_management_actions_supported: [
          "org.matrix.device_delete",
          "org.matrix.account_deactivate",
        ],
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.buildMatrixAccountManagementRedirect(
      '{"requested_account_management_action":"org.matrix.device_delete"}',
    ),
    {
      ok: true,
      value: {
        uri: "https://account.example.test/manage?action=org.matrix.device_delete&device_id=DEVICE2",
        action: "org.matrix.device_delete",
        device_id: "DEVICE2",
        generic_fallback: false,
      },
      error: null,
    },
  );
  assert.deepEqual(
    core.reconcileMatrixAccountManagementDeviceDelete('{"deleted_device_id":"DEVICE2"}'),
    {
      ok: true,
      value: {
        deleted_device_id: "DEVICE2",
        missing_device_id: true,
        mark_delete_complete: true,
      },
      error: null,
    },
  );
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

test("maps SPEC-085 event retrieval and membership envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const vector = readSpecVector(
    "test-vectors/core/" +
      "matrix-" +
      "client-server-event-retrieval-membership-history.json",
  );
  assert.equal(vector.contract, "SPEC-085");
  assert.ok(core.manifest.supported_specs.includes("SPEC-085"));

  assert.deepEqual(core.parseMatrixEventRetrievalRequestDescriptor("{}"), {
    ok: true,
    value: {
      method: "GET",
      path: "/_matrix/client/v3/rooms/{roomId}/event/{eventId}",
      requires_auth: true,
      response_parser: "client_event",
      adopted_runtime_behavior: true,
    },
    error: null,
  });
  assert.equal(
    core.parseMatrixJoinedMembersResponse("{}").value.joined["@alice:example.test"]
      .display_name,
    "Alice",
  );
  assert.equal(
    core.parseMatrixMembersResponse("{}").value.chunk[0].content.membership,
    "join",
  );
  assert.deepEqual(core.parseMatrixTimestampToEventResponse("{}"), {
    ok: true,
    value: {
      event_id: "$event:example.test",
      origin_server_ts: 1715754600000,
    },
    error: null,
  });
});

test("maps SPEC-090 relations threads and reactions envelopes", () => {
  const core = createHouraProtocolCore(binding());
  const vector = readSpecVector(
    "test-vectors/core/" +
      "matrix-" +
      "client-server-relations-threads-reactions.json",
  );
  assert.equal(vector.contract, "SPEC-090");
  assert.ok(core.manifest.supported_specs.includes("SPEC-090"));

  assert.deepEqual(core.parseMatrixRelationsRequestDescriptor("{}"), {
    ok: true,
    value: {
      method: "GET",
      path: "/_matrix/client/v1/rooms/{roomId}/relations/{eventId}",
      requires_auth: true,
      response_parser: "relation_chunk",
      adopted_runtime_behavior: true,
    },
    error: null,
  });
  const relationChunk = core.parseMatrixRelationChunkResponse("{}");
  assert.equal(relationChunk.value.chunk[0].type, "m.reaction");
  assert.equal(
    relationChunk.value.chunk[0].content["m.relates_to"].rel_type,
    "m.annotation",
  );
  assert.equal(relationChunk.value.next_batch, "rel_2");

  const threads = core.parseMatrixThreadRootsResponse("{}");
  assert.equal(
    threads.value.chunk[0].unsigned["m.relations"]["m.thread"].count,
    2,
  );
  assert.equal(threads.value.next_batch, "thread_2");

  assert.equal(core.parseMatrixReactionEvent("{}").value.event_id, "$reaction:example.test");
  assert.equal(core.parseMatrixEditEvent("{}").value.event_id, "$edit:example.test");
  assert.equal(core.parseMatrixReplyEvent("{}").value.event_id, "$reply:example.test");
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

test("maps SPEC-093 sync breadth extension envelopes", () => {
  const vector = readSpecVector("test-vectors/sync/matrix-sync-breadth-extensions.json");
  assert.equal(vector.contract, "SPEC-093");

  const core = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: {
        ok: true,
        value: vector.event.sample_responses.sync_extensions,
        error: null,
      },
    }),
  );
  assert.ok(core.manifest.supported_specs.includes("SPEC-093"));

  assert.deepEqual(core.parseMatrixSyncRequestDescriptor("{}"), {
    ok: true,
    value: {
      method: "GET",
      path: "/_matrix/client/v3/sync",
      requires_auth: true,
      query_params: {
        filter: "filter-1",
        full_state: true,
        set_presence: "online",
        since: "s1",
        timeout: 0,
        use_state_after: true,
      },
      response_parser: "sync_extensions",
      adopted_runtime_behavior: false,
    },
    error: null,
  });

  const sync = core.parseMatrixSyncResponse("{}");
  assert.equal(sync.value.presence.events[0].sender, "@alice:example.test");
  assert.equal(sync.value.to_device.events[0].type, "m.room.encrypted");
  assert.deepEqual(sync.value.device_lists.changed, ["@alice:example.test"]);
  assert.equal(sync.value.device_one_time_keys_count.signed_curve25519, 3);
  assert.equal(Object.keys(sync.value.rooms.invite).length, 1);
  assert.equal(Object.keys(sync.value.rooms.leave).length, 1);
  assert.equal(Object.keys(sync.value.rooms.knock).length, 1);

  const negativeCountCore = createHouraProtocolCore(
    binding({
      syncResponseEnvelope: {
        ok: true,
        value: {
          next_batch: "s3",
          account_data: { events: [] },
          device_one_time_keys_count: { signed_curve25519: -1 },
          rooms: { join: {}, invite: {}, leave: {} },
        },
        error: null,
      },
    }),
  );
  assert.throws(
    () => negativeCountCore.parseMatrixSyncResponse("{}"),
    (error) =>
      error instanceof HouraProtocolCoreFacadeError &&
      error.code === "invalid_envelope" &&
      error.message.includes("device_one_time_keys_count.signed_curve25519"),
  );
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

test("maps SPEC-095 Matrix media repository breadth envelopes", () => {
  const vector = readSpecVector("test-vectors/media/matrix-media-repository-breadth.json");
  const descriptors = vector.event.request_descriptors;
  const responses = vector.event.sample_responses;
  const descriptor = descriptors.find((item) => item.id === "media-thumbnail");
  const core = createHouraProtocolCore(
    binding({
      mediaRepositoryRequestDescriptorEnvelope: {
        ok: true,
        value: descriptor,
        error: null,
      },
      mediaConfigResponseEnvelope: {
        ok: true,
        value: responses.media_config,
        error: null,
      },
      mediaPreviewUrlResponseEnvelope: {
        ok: true,
        value: { fields: responses.preview_url },
        error: null,
      },
      mediaThumbnailMetadataEnvelope: {
        ok: true,
        value: responses.thumbnail_metadata,
        error: null,
      },
      mediaUploadCreateResponseEnvelope: {
        ok: true,
        value: responses.upload_create,
        error: null,
      },
      mediaUploadResponseEnvelope: {
        ok: true,
        value: responses.upload_resume,
        error: null,
      },
      mediaContentDispositionFilenameEnvelope: {
        ok: true,
        value: { filename: vector.expected.safe_filename },
        error: null,
      },
    }),
  );

  assert.equal(HOURA_PROTOCOL_CORE_SPEC_IDS.includes("SPEC-095"), true);
  assert.deepEqual(core.parseMatrixMediaRepositoryRequestDescriptor("{}"), {
    ok: true,
    value: descriptor,
    error: null,
  });
  assert.deepEqual(core.parseMatrixMediaConfigResponse("{}"), {
    ok: true,
    value: responses.media_config,
    error: null,
  });
  assert.equal(
    core.parseMatrixMediaPreviewUrlResponse("{}").value.fields["og:image"],
    vector.expected.preview_image_uri,
  );
  assert.equal(
    core.parseMatrixMediaThumbnailMetadata("{}").value.content_uri,
    vector.expected.thumbnail_uri,
  );
  assert.equal(
    core.parseMatrixMediaUploadCreateResponse("{}").value.content_uri,
    vector.expected.upload_create_uri,
  );
  assert.equal(
    core.parseMatrixMediaUploadResponse("{}").value.content_uri,
    vector.expected.upload_create_uri,
  );
  assert.equal(
    core.parseMatrixMediaContentDispositionFilename("").value.filename,
    vector.expected.safe_filename,
  );
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
