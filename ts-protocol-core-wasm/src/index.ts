export const HOURA_PROTOCOL_CORE_ABI_VERSION = 1;
export const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION = 1;
export const HOURA_PROTOCOL_CORE_CRATE_NAME = "houra-protocol-core";
export const HOURA_PROTOCOL_CORE_CRATE_VERSION = "0.1.0";
export const HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY = "pure-protocol-core";
export const HOURA_PROTOCOL_CORE_WASM_BINDING_KIND = "wasm";
export const HOURA_PROTOCOL_CORE_SPEC_IDS = [
  "SPEC-030",
  "SPEC-031",
  "SPEC-032",
  "SPEC-033",
  "SPEC-034",
  "SPEC-035",
  "SPEC-036",
  "SPEC-037",
  "SPEC-038",
  "SPEC-039",
  "SPEC-040",
  "SPEC-056",
] as const;

export interface HouraProtocolCoreWasmBinding {
  houraArtifactManifestJson(): string;
  parseMatrixClientEventJson(responseBody: string): string;
  parseMatrixClientVersionsResponseJson(responseBody: string): string;
  parseMatrixDeviceJson(responseBody: string): string;
  parseMatrixDevicesJson(responseBody: string): string;
  parseMatrixEventIdResponseJson(responseBody: string): string;
  parseMatrixErrorEnvelopeJson(responseBody: string): string;
  parseMatrixFederationInviteRequestJson(responseBody: string): string;
  parseMatrixFederationInviteResponseJson(responseBody: string): string;
  parseMatrixFederationMakeJoinResponseJson(responseBody: string): string;
  parseMatrixFederationSendJoinResponseJson(responseBody: string): string;
  parseMatrixFederationTransactionJson(responseBody: string): string;
  parseMatrixFederationTransactionResponseJson(responseBody: string): string;
  parseMatrixLoginFlowsJson(responseBody: string): string;
  parseMatrixLoginSessionJson(responseBody: string): string;
  parseMatrixMediaContentUriJson(contentUri: string): string;
  parseMatrixMediaUploadResponseJson(responseBody: string): string;
  parseMatrixMessagesResponseJson(responseBody: string): string;
  parseMatrixSyncResponseJson(responseBody: string): string;
  parseMatrixRegistrationAvailabilityJson(responseBody: string): string;
  parseMatrixRegistrationSessionJson(responseBody: string): string;
  parseMatrixRegistrationTokenValidityJson(responseBody: string): string;
  parseMatrixRoomIdResponseJson(responseBody: string): string;
  parseMatrixRoomStateJson(responseBody: string): string;
  parseMatrixUserInteractiveAuthRequiredJson(responseBody: string): string;
  parseMatrixWhoamiJson(responseBody: string): string;
  validateMatrixFoundationIdentifiersJson(value: string): string;
}

export interface ArtifactManifest {
  manifest_schema_version: number;
  crate_name: string;
  crate_version: string;
  abi_version: number;
  protocol_boundary: string;
  supported_specs: string[];
  supported_binding_kinds: string[];
}

export interface ArtifactReleaseEvidence {
  evidence_kind: "houra-protocol-core-artifact";
  redaction: "metadata-only-no-raw-requests-or-secrets";
  binding_kind: typeof HOURA_PROTOCOL_CORE_WASM_BINDING_KIND;
  manifest_schema_version: number;
  crate_name: string;
  crate_version: string;
  abi_version: number;
  protocol_boundary: string;
  supported_specs: string[];
  supported_binding_kinds: string[];
  spec_snapshot_ref?: string;
}

export interface MatrixClientVersions {
  versions: string[];
  unstable_features: Record<string, boolean>;
}

export interface MatrixErrorEnvelope {
  errcode: string;
  error?: string;
  retry_after_ms?: number;
}

export interface MatrixFoundationValidation {
  valid: boolean;
}

export interface MatrixLoginFlow {
  type: string;
}

export interface MatrixLoginFlows {
  flows: MatrixLoginFlow[];
}

export interface MatrixLoginSession {
  user_id: string;
  access_token: string;
  device_id?: string;
  home_server?: string;
}

export interface MatrixRegistrationSession {
  user_id: string;
  access_token: string;
  device_id: string;
  home_server?: string;
}

export interface MatrixWhoami {
  user_id: string;
  device_id?: string;
  is_guest?: boolean;
}

export interface MatrixRegistrationAvailability {
  available: boolean;
}

export interface MatrixRegistrationTokenValidity {
  valid: boolean;
}

export interface MatrixUserInteractiveAuthFlow {
  stages: string[];
}

export interface MatrixUserInteractiveAuthRequired {
  completed: string[];
  flows: MatrixUserInteractiveAuthFlow[];
  params: Record<string, unknown>;
  session?: string;
}

export interface MatrixDevice {
  device_id: string;
  display_name?: string;
  last_seen_ip?: string;
  last_seen_ts?: number;
}

export interface MatrixDevices {
  devices: MatrixDevice[];
}

export interface MatrixRoomIdResponse {
  room_id: string;
}

export interface MatrixEventIdResponse {
  event_id: string;
}

export interface MatrixClientEvent {
  content: Record<string, unknown>;
  event_id: string;
  origin_server_ts: number;
  room_id: string;
  sender: string;
  state_key?: string;
  type: string;
  unsigned?: Record<string, unknown>;
}

export interface MatrixRoomState {
  events: MatrixClientEvent[];
}

export interface MatrixMessagesResponse {
  chunk: MatrixClientEvent[];
  start: string;
  end?: string;
}

export interface MatrixSyncEvent {
  content: Record<string, unknown>;
  event_id: string;
  origin_server_ts: number;
  sender: string;
  state_key?: string;
  type: string;
  unsigned?: Record<string, unknown>;
}

export interface MatrixSyncBasicEvent {
  content: Record<string, unknown>;
  type: string;
}

export interface MatrixSyncJoinedRoom {
  state: {
    events: MatrixSyncEvent[];
  };
  timeline: {
    events: MatrixSyncEvent[];
    limited: boolean;
    prev_batch?: string;
  };
  account_data: {
    events: MatrixSyncBasicEvent[];
  };
  summary?: {
    "m.joined_member_count"?: number;
    "m.invited_member_count"?: number;
  };
  unread_notifications?: {
    notification_count?: number;
    highlight_count?: number;
  };
}

export interface MatrixSyncResponse {
  next_batch: string;
  account_data: {
    events: MatrixSyncBasicEvent[];
  };
  presence?: {
    events: MatrixSyncBasicEvent[];
  };
  rooms: {
    join: Record<string, MatrixSyncJoinedRoom>;
    invite: Record<string, unknown>;
    leave: Record<string, unknown>;
  };
}

export interface MatrixMediaContentUri {
  server_name: string;
  media_id: string;
}

export interface MatrixMediaUploadResponse {
  content_uri: string;
}

export interface MatrixFederationTransaction {
  origin: string;
  origin_server_ts: number;
  pdus: Record<string, unknown>[];
  edus: Record<string, unknown>[];
}

export interface MatrixFederationPduResult {
  error?: string;
}

export interface MatrixFederationTransactionResponse {
  pdus: Record<string, MatrixFederationPduResult>;
}

export interface MatrixFederationMakeJoinResponse {
  room_version: string;
  event: Record<string, unknown>;
}

export interface MatrixFederationSendJoinResponse {
  origin: string;
  state: Record<string, unknown>[];
  auth_chain: Record<string, unknown>[];
  event: Record<string, unknown>;
}

export interface MatrixFederationInviteRequest {
  room_version: string;
  event: Record<string, unknown>;
}

export interface MatrixFederationInviteResponse {
  event: Record<string, unknown>;
}

export interface ProtocolErrorEnvelope {
  code: string;
  message: string;
  details: Record<string, string>;
}

export type ProtocolResult<T> =
  | { ok: true; value: T; error: null }
  | { ok: false; value: null; error: ProtocolErrorEnvelope };

export interface HouraProtocolCoreFacade {
  manifest: ArtifactManifest;
  releaseEvidence: ArtifactReleaseEvidence;
  parseMatrixClientEvent(responseBody: string): ProtocolResult<MatrixClientEvent>;
  parseMatrixClientVersionsResponse(
    responseBody: string,
  ): ProtocolResult<MatrixClientVersions>;
  parseMatrixDevice(responseBody: string): ProtocolResult<MatrixDevice>;
  parseMatrixDevices(responseBody: string): ProtocolResult<MatrixDevices>;
  parseMatrixEventIdResponse(
    responseBody: string,
  ): ProtocolResult<MatrixEventIdResponse>;
  parseMatrixErrorEnvelope(responseBody: string): ProtocolResult<MatrixErrorEnvelope>;
  parseMatrixFederationInviteRequest(
    responseBody: string,
  ): ProtocolResult<MatrixFederationInviteRequest>;
  parseMatrixFederationInviteResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationInviteResponse>;
  parseMatrixFederationMakeJoinResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationMakeJoinResponse>;
  parseMatrixFederationSendJoinResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationSendJoinResponse>;
  parseMatrixFederationTransaction(
    responseBody: string,
  ): ProtocolResult<MatrixFederationTransaction>;
  parseMatrixFederationTransactionResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationTransactionResponse>;
  parseMatrixLoginFlows(responseBody: string): ProtocolResult<MatrixLoginFlows>;
  parseMatrixLoginSession(
    responseBody: string,
  ): ProtocolResult<MatrixLoginSession>;
  parseMatrixMediaContentUri(
    contentUri: string,
  ): ProtocolResult<MatrixMediaContentUri>;
  parseMatrixMediaUploadResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMediaUploadResponse>;
  parseMatrixMessagesResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMessagesResponse>;
  parseMatrixSyncResponse(
    responseBody: string,
  ): ProtocolResult<MatrixSyncResponse>;
  parseMatrixRegistrationAvailability(
    responseBody: string,
  ): ProtocolResult<MatrixRegistrationAvailability>;
  parseMatrixRegistrationSession(
    responseBody: string,
  ): ProtocolResult<MatrixRegistrationSession>;
  parseMatrixRegistrationTokenValidity(
    responseBody: string,
  ): ProtocolResult<MatrixRegistrationTokenValidity>;
  parseMatrixRoomIdResponse(
    responseBody: string,
  ): ProtocolResult<MatrixRoomIdResponse>;
  parseMatrixRoomState(responseBody: string): ProtocolResult<MatrixRoomState>;
  parseMatrixUserInteractiveAuthRequired(
    responseBody: string,
  ): ProtocolResult<MatrixUserInteractiveAuthRequired>;
  parseMatrixWhoami(responseBody: string): ProtocolResult<MatrixWhoami>;
  validateMatrixFoundationIdentifiers(
    value: string,
  ): ProtocolResult<MatrixFoundationValidation>;
}

export type FacadeErrorCode =
  | "invalid_json"
  | "invalid_manifest"
  | "invalid_envelope";

export class HouraProtocolCoreFacadeError extends Error {
  readonly code: FacadeErrorCode;

  constructor(code: FacadeErrorCode, message: string) {
    super(message);
    this.name = "HouraProtocolCoreFacadeError";
    this.code = code;
  }
}

export function createHouraProtocolCore(
  binding: HouraProtocolCoreWasmBinding,
): HouraProtocolCoreFacade {
  const manifest = readArtifactManifest(binding);
  assertManifestCompatible(manifest);

  return {
    manifest,
    releaseEvidence: artifactReleaseEvidenceFromManifest(manifest),
    parseMatrixClientEvent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixClientEventJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientEventEnvelope(envelope);
    },
    parseMatrixClientVersionsResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixClientVersionsResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientVersionsEnvelope(envelope);
    },
    parseMatrixDevice(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDeviceJson(responseBody),
        "parse envelope",
      );
      return readMatrixDeviceEnvelope(envelope);
    },
    parseMatrixDevices(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDevicesJson(responseBody),
        "parse envelope",
      );
      return readMatrixDevicesEnvelope(envelope);
    },
    parseMatrixEventIdResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixEventIdResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixEventIdResponseEnvelope(envelope);
    },
    parseMatrixErrorEnvelope(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixErrorEnvelopeJson(responseBody),
        "parse envelope",
      );
      return readMatrixErrorEnvelope(envelope);
    },
    parseMatrixFederationInviteRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationInviteRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationInviteRequestEnvelope(envelope);
    },
    parseMatrixFederationInviteResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationInviteResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationInviteResponseEnvelope(envelope);
    },
    parseMatrixFederationMakeJoinResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationMakeJoinResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationMakeJoinResponseEnvelope(envelope);
    },
    parseMatrixFederationSendJoinResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationSendJoinResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationSendJoinResponseEnvelope(envelope);
    },
    parseMatrixFederationTransaction(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationTransactionJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationTransactionEnvelope(envelope);
    },
    parseMatrixFederationTransactionResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationTransactionResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationTransactionResponseEnvelope(envelope);
    },
    parseMatrixLoginFlows(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixLoginFlowsJson(responseBody),
        "parse envelope",
      );
      return readMatrixLoginFlowsEnvelope(envelope);
    },
    parseMatrixLoginSession(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixLoginSessionJson(responseBody),
        "parse envelope",
      );
      return readMatrixLoginSessionEnvelope(envelope);
    },
    parseMatrixMediaContentUri(contentUri: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixMediaContentUriJson(contentUri),
        "parse envelope",
      );
      return readMatrixMediaContentUriEnvelope(envelope);
    },
    parseMatrixMediaUploadResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixMediaUploadResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixMediaUploadResponseEnvelope(envelope);
    },
    parseMatrixMessagesResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixMessagesResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixMessagesResponseEnvelope(envelope);
    },
    parseMatrixSyncResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixSyncResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixSyncResponseEnvelope(envelope);
    },
    parseMatrixRegistrationAvailability(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRegistrationAvailabilityJson(responseBody),
        "parse envelope",
      );
      return readMatrixRegistrationAvailabilityEnvelope(envelope);
    },
    parseMatrixRegistrationSession(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRegistrationSessionJson(responseBody),
        "parse envelope",
      );
      return readMatrixRegistrationSessionEnvelope(envelope);
    },
    parseMatrixRegistrationTokenValidity(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRegistrationTokenValidityJson(responseBody),
        "parse envelope",
      );
      return readMatrixRegistrationTokenValidityEnvelope(envelope);
    },
    parseMatrixRoomIdResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomIdResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomIdResponseEnvelope(envelope);
    },
    parseMatrixRoomState(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomStateJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomStateEnvelope(envelope);
    },
    parseMatrixUserInteractiveAuthRequired(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixUserInteractiveAuthRequiredJson(responseBody),
        "parse envelope",
      );
      return readMatrixUserInteractiveAuthRequiredEnvelope(envelope);
    },
    parseMatrixWhoami(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixWhoamiJson(responseBody),
        "parse envelope",
      );
      return readMatrixWhoamiEnvelope(envelope);
    },
    validateMatrixFoundationIdentifiers(value: string) {
      const envelope = parseJsonObject(
        binding.validateMatrixFoundationIdentifiersJson(value),
        "parse envelope",
      );
      return readMatrixFoundationValidationEnvelope(envelope);
    },
  };
}

export function artifactReleaseEvidenceFromManifest(
  manifest: ArtifactManifest,
  options: { specSnapshotRef?: string } = {},
): ArtifactReleaseEvidence {
  return {
    evidence_kind: "houra-protocol-core-artifact",
    redaction: "metadata-only-no-raw-requests-or-secrets",
    binding_kind: HOURA_PROTOCOL_CORE_WASM_BINDING_KIND,
    manifest_schema_version: manifest.manifest_schema_version,
    crate_name: manifest.crate_name,
    crate_version: manifest.crate_version,
    abi_version: manifest.abi_version,
    protocol_boundary: manifest.protocol_boundary,
    supported_specs: [...manifest.supported_specs],
    supported_binding_kinds: [...manifest.supported_binding_kinds],
    ...(options.specSnapshotRef === undefined
      ? {}
      : { spec_snapshot_ref: options.specSnapshotRef }),
  };
}

function readArtifactManifest(
  binding: HouraProtocolCoreWasmBinding,
): ArtifactManifest {
  const manifest = parseJsonObject(
    binding.houraArtifactManifestJson(),
    "artifact manifest",
  );
  const supportedSpecs = readStringArray(manifest, "supported_specs");
  const supportedBindingKinds = readStringArray(
    manifest,
    "supported_binding_kinds",
  );

  return {
    manifest_schema_version: readNumber(manifest, "manifest_schema_version"),
    crate_name: readString(manifest, "crate_name"),
    crate_version: readString(manifest, "crate_version"),
    abi_version: readNumber(manifest, "abi_version"),
    protocol_boundary: readString(manifest, "protocol_boundary"),
    supported_specs: supportedSpecs,
    supported_binding_kinds: supportedBindingKinds,
  };
}

function assertManifestCompatible(manifest: ArtifactManifest): void {
  const issues: string[] = [];
  if (
    manifest.manifest_schema_version !==
    HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION
  ) {
    issues.push("manifest_schema_version");
  }
  if (manifest.abi_version !== HOURA_PROTOCOL_CORE_ABI_VERSION) {
    issues.push("abi_version");
  }
  if (manifest.crate_name !== HOURA_PROTOCOL_CORE_CRATE_NAME) {
    issues.push("crate_name");
  }
  if (manifest.crate_version !== HOURA_PROTOCOL_CORE_CRATE_VERSION) {
    issues.push("crate_version");
  }
  if (manifest.protocol_boundary !== HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY) {
    issues.push("protocol_boundary");
  }
  if (
    !orderedStringArrayEquals(
      manifest.supported_specs,
      HOURA_PROTOCOL_CORE_SPEC_IDS,
    )
  ) {
    issues.push("supported_specs");
  }
  if (
    !manifest.supported_binding_kinds.includes(
      HOURA_PROTOCOL_CORE_WASM_BINDING_KIND,
    )
  ) {
    issues.push("supported_binding_kinds");
  }

  if (issues.length > 0) {
    throw new HouraProtocolCoreFacadeError(
      "invalid_manifest",
      `unsupported Rust protocol core manifest: ${issues.join(", ")}`,
    );
  }
}

function orderedStringArrayEquals(
  actual: readonly string[],
  expected: readonly string[],
): boolean {
  if (actual.length !== expected.length) {
    return false;
  }
  return expected.every((value, index) => actual[index] === value);
}

function readMatrixClientVersionsEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixClientVersions> {
  return readProtocolResult(envelope, readMatrixClientVersions);
}

function readMatrixClientVersions(
  value: Record<string, unknown>,
): MatrixClientVersions {
  const unstable = readRecord(value, "unstable_features", "versions value");
  return {
    versions: readStringArray(value, "versions", "invalid_envelope"),
    unstable_features: readBooleanRecord(unstable),
  };
}

function readMatrixErrorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixErrorEnvelope> {
  return readProtocolResult(envelope, readMatrixErrorValue);
}

function readMatrixErrorValue(
  value: Record<string, unknown>,
): MatrixErrorEnvelope {
  const result: MatrixErrorEnvelope = {
    errcode: readString(value, "errcode", "invalid_envelope"),
  };
  if (value.error !== null && value.error !== undefined) {
    result.error = readString(value, "error", "invalid_envelope");
  }
  if (value.retry_after_ms !== null && value.retry_after_ms !== undefined) {
    result.retry_after_ms = readNumber(value, "retry_after_ms", "invalid_envelope");
  }
  return result;
}

function readMatrixFoundationValidationEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFoundationValidation> {
  return readProtocolResult(envelope, (value) => ({
    valid: readBoolean(value, "valid"),
  }));
}

function readMatrixFederationTransactionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationTransaction> {
  return readProtocolResult(envelope, (value) => ({
    origin: readString(value, "origin", "invalid_envelope"),
    origin_server_ts: readNumber(value, "origin_server_ts", "invalid_envelope"),
    pdus: readRecordArray(value, "pdus", "federation.transaction.pdus"),
    edus: readRecordArray(value, "edus", "federation.transaction.edus"),
  }));
}

function readMatrixFederationTransactionResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationTransactionResponse> {
  return readProtocolResult(envelope, (value) => {
    const pdus: [string, MatrixFederationPduResult][] = [];
    for (const [eventId, result] of Object.entries(
      readRecord(value, "pdus", "federation.transaction_response"),
    )) {
      const record = assertRecord(
        result,
        `federation.transaction_response.pdus.${eventId}`,
      );
      const pduResult: MatrixFederationPduResult = {};
      readOptionalString(record, "error", (error) => {
        pduResult.error = error;
      }, `federation.transaction_response.pdus.${eventId}`);
      pdus.push([eventId, pduResult]);
    }
    return { pdus: Object.fromEntries(pdus) };
  });
}

function readMatrixFederationMakeJoinResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationMakeJoinResponse> {
  return readProtocolResult(envelope, (value) => ({
    room_version: readString(value, "room_version", "invalid_envelope"),
    event: readRecord(value, "event", "federation.make_join"),
  }));
}

function readMatrixFederationSendJoinResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationSendJoinResponse> {
  return readProtocolResult(envelope, (value) => ({
    origin: readString(value, "origin", "invalid_envelope"),
    state: readRecordArray(value, "state", "federation.send_join.state"),
    auth_chain: readRecordArray(
      value,
      "auth_chain",
      "federation.send_join.auth_chain",
    ),
    event: readRecord(value, "event", "federation.send_join"),
  }));
}

function readMatrixFederationInviteRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationInviteRequest> {
  return readProtocolResult(envelope, (value) => ({
    room_version: readString(value, "room_version", "invalid_envelope"),
    event: readRecord(value, "event", "federation.invite"),
  }));
}

function readMatrixFederationInviteResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationInviteResponse> {
  return readProtocolResult(envelope, (value) => ({
    event: readRecord(value, "event", "federation.invite_response"),
  }));
}

function readMatrixLoginFlowsEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixLoginFlows> {
  return readProtocolResult(envelope, (value) => {
    const flows = readArray(value, "flows", "invalid_envelope").map(
      (entry, index) => ({
        type: readString(
          assertRecord(entry, `flows.${index}`),
          "type",
          "invalid_envelope",
        ),
      }),
    );

    return { flows };
  });
}

function readMatrixLoginSessionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixLoginSession> {
  return readProtocolResult(envelope, readMatrixLoginSession);
}

function readMatrixLoginSession(
  value: Record<string, unknown>,
): MatrixLoginSession {
  const result: MatrixLoginSession = {
    user_id: readString(value, "user_id", "invalid_envelope"),
    access_token: readString(value, "access_token", "invalid_envelope"),
  };
  readOptionalString(value, "device_id", (deviceId) => {
    result.device_id = deviceId;
  });
  readOptionalString(value, "home_server", (homeServer) => {
    result.home_server = homeServer;
  });
  return result;
}

function readMatrixRegistrationSessionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRegistrationSession> {
  return readProtocolResult(envelope, readMatrixRegistrationSession);
}

function readMatrixRegistrationSession(
  value: Record<string, unknown>,
): MatrixRegistrationSession {
  const result: MatrixRegistrationSession = {
    user_id: readString(value, "user_id", "invalid_envelope"),
    access_token: readString(value, "access_token", "invalid_envelope"),
    device_id: readString(value, "device_id", "invalid_envelope"),
  };
  readOptionalString(value, "home_server", (homeServer) => {
    result.home_server = homeServer;
  });
  return result;
}

function readMatrixRegistrationAvailabilityEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRegistrationAvailability> {
  return readProtocolResult(envelope, (value) => ({
    available: readBoolean(value, "available"),
  }));
}

function readMatrixRegistrationTokenValidityEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRegistrationTokenValidity> {
  return readProtocolResult(envelope, (value) => ({
    valid: readBoolean(value, "valid"),
  }));
}

function readMatrixUserInteractiveAuthRequiredEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixUserInteractiveAuthRequired> {
  return readProtocolResult(envelope, (value) => {
    const flows = readArray(value, "flows", "invalid_envelope").map(
      (entry, index) => ({
        stages: readStringArray(
          assertRecord(entry, `flows.${index}`),
          "stages",
          "invalid_envelope",
        ),
      }),
    );

    const result: MatrixUserInteractiveAuthRequired = {
      completed: readStringArray(value, "completed", "invalid_envelope"),
      flows,
      params: readRecord(value, "params", "uia value"),
    };
    readOptionalString(value, "session", (session) => {
      result.session = session;
    });
    return result;
  });
}

function readMatrixDeviceEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDevice> {
  return readProtocolResult(envelope, readMatrixDevice);
}

function readMatrixDevicesEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDevices> {
  return readProtocolResult(envelope, (value) => {
    const devices = readArray(value, "devices", "invalid_envelope").map(
      (entry, index) => readMatrixDevice(assertRecord(entry, `devices.${index}`)),
    );

    return { devices };
  });
}

function readMatrixDevice(value: Record<string, unknown>): MatrixDevice {
  const result: MatrixDevice = {
    device_id: readString(value, "device_id", "invalid_envelope"),
  };
  readOptionalString(value, "display_name", (displayName) => {
    result.display_name = displayName;
  });
  readOptionalString(value, "last_seen_ip", (lastSeenIp) => {
    result.last_seen_ip = lastSeenIp;
  });
  readOptionalNumber(value, "last_seen_ts", (lastSeenTs) => {
    result.last_seen_ts = lastSeenTs;
  });
  return result;
}

function readMatrixRoomIdResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomIdResponse> {
  return readProtocolResult(envelope, (value) => ({
    room_id: readString(value, "room_id", "invalid_envelope"),
  }));
}

function readMatrixEventIdResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixEventIdResponse> {
  return readProtocolResult(envelope, (value) => ({
    event_id: readString(value, "event_id", "invalid_envelope"),
  }));
}

function readMatrixClientEventEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixClientEvent> {
  return readProtocolResult(envelope, readMatrixClientEvent);
}

function readMatrixRoomStateEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomState> {
  return readProtocolResult(envelope, (value) => {
    const events = readArray(value, "events", "invalid_envelope").map(
      (entry, index) =>
        readMatrixClientEvent(assertRecord(entry, `events.${index}`)),
    );

    return { events };
  });
}

function readMatrixMessagesResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixMessagesResponse> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixMessagesResponse = {
      chunk: readArray(value, "chunk", "invalid_envelope").map(
        (entry, index) =>
          readMatrixClientEvent(assertRecord(entry, `chunk.${index}`)),
      ),
      start: readString(value, "start", "invalid_envelope"),
    };
    readOptionalString(value, "end", (end) => {
      result.end = end;
    });
    return result;
  });
}

function readMatrixMediaContentUriEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixMediaContentUri> {
  return readProtocolResult(envelope, (value) => ({
    server_name: readString(value, "server_name", "invalid_envelope"),
    media_id: readString(value, "media_id", "invalid_envelope"),
  }));
}

function readMatrixMediaUploadResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixMediaUploadResponse> {
  return readProtocolResult(envelope, (value) => ({
    content_uri: readString(value, "content_uri", "invalid_envelope"),
  }));
}

function readMatrixSyncResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixSyncResponse> {
  return readProtocolResult(envelope, (value) => {
    const rooms = readRecord(value, "rooms", "sync value");
    const result: MatrixSyncResponse = {
      next_batch: readString(value, "next_batch", "invalid_envelope"),
      account_data: readMatrixSyncBasicEvents(
        readRecord(value, "account_data", "sync value"),
        "account_data",
      ),
      rooms: {
        join: readMatrixSyncJoinedRooms(readRecord(rooms, "join", "sync rooms")),
        invite: readRecord(rooms, "invite", "sync rooms"),
        leave: readRecord(rooms, "leave", "sync rooms"),
      },
    };
    if (value.presence !== null && value.presence !== undefined) {
      result.presence = readMatrixSyncBasicEvents(
        readRecord(value, "presence", "sync value"),
        "presence",
      );
    }
    return result;
  });
}

function readMatrixSyncJoinedRooms(
  value: Record<string, unknown>,
): Record<string, MatrixSyncJoinedRoom> {
  const rooms: Record<string, MatrixSyncJoinedRoom> = {};
  for (const [roomId, room] of Object.entries(value)) {
    const roomRecord = assertRecord(room, `rooms.join.${roomId}`);
    const timeline = readRecord(roomRecord, "timeline", `rooms.join.${roomId}`);
    const joinedRoom: MatrixSyncJoinedRoom = {
      state: {
        events: readArray(
          readRecord(roomRecord, "state", `rooms.join.${roomId}`),
          "events",
          "invalid_envelope",
        ).map((entry, index) =>
          readMatrixSyncEvent(
            assertRecord(entry, `rooms.join.${roomId}.state.events.${index}`),
            `rooms.join.${roomId}.state.events.${index}`,
          ),
        ),
      },
      timeline: {
        events: readArray(timeline, "events", "invalid_envelope").map(
          (entry, index) =>
            readMatrixSyncEvent(
              assertRecord(
                entry,
                `rooms.join.${roomId}.timeline.events.${index}`,
              ),
              `rooms.join.${roomId}.timeline.events.${index}`,
            ),
        ),
        limited: readBoolean(timeline, "limited"),
      },
      account_data: readMatrixSyncBasicEvents(
        readRecord(roomRecord, "account_data", `rooms.join.${roomId}`),
        `rooms.join.${roomId}.account_data`,
      ),
    };
    readOptionalString(timeline, "prev_batch", (prevBatch) => {
      joinedRoom.timeline.prev_batch = prevBatch;
    });
    if (roomRecord.summary !== null && roomRecord.summary !== undefined) {
      joinedRoom.summary = readMatrixSyncSummary(
        readRecord(roomRecord, "summary", `rooms.join.${roomId}`),
      );
    }
    if (
      roomRecord.unread_notifications !== null &&
      roomRecord.unread_notifications !== undefined
    ) {
      joinedRoom.unread_notifications = readMatrixSyncUnreadNotifications(
        readRecord(roomRecord, "unread_notifications", `rooms.join.${roomId}`),
      );
    }
    rooms[roomId] = joinedRoom;
  }
  return rooms;
}

function readMatrixSyncEvent(
  value: Record<string, unknown>,
  context: string,
): MatrixSyncEvent {
  const result: MatrixSyncEvent = {
    content: readRecord(value, "content", context),
    event_id: readContextString(value, "event_id", context),
    origin_server_ts: readContextNumber(value, "origin_server_ts", context),
    sender: readContextString(value, "sender", context),
    type: readContextString(value, "type", context),
  };
  readOptionalString(value, "state_key", (stateKey) => {
    result.state_key = stateKey;
  }, context);
  if (value.unsigned !== null && value.unsigned !== undefined) {
    result.unsigned = readRecord(value, "unsigned", context);
  }
  return result;
}

function readMatrixSyncBasicEvents(
  value: Record<string, unknown>,
  context: string,
): { events: MatrixSyncBasicEvent[] } {
  return {
    events: readArray(value, "events", "invalid_envelope").map((entry, index) => {
      const record = assertRecord(entry, `${context}.events.${index}`);
      return {
        content: readRecord(record, "content", "sync basic event"),
        type: readString(record, "type", "invalid_envelope"),
      };
    }),
  };
}

function readMatrixSyncSummary(
  value: Record<string, unknown>,
): NonNullable<MatrixSyncJoinedRoom["summary"]> {
  const summary: NonNullable<MatrixSyncJoinedRoom["summary"]> = {};
  readOptionalNumber(value, "m.joined_member_count", (count) => {
    summary["m.joined_member_count"] = count;
  });
  readOptionalNumber(value, "m.invited_member_count", (count) => {
    summary["m.invited_member_count"] = count;
  });
  return summary;
}

function readMatrixSyncUnreadNotifications(
  value: Record<string, unknown>,
): NonNullable<MatrixSyncJoinedRoom["unread_notifications"]> {
  const unread: NonNullable<MatrixSyncJoinedRoom["unread_notifications"]> = {};
  readOptionalNumber(value, "notification_count", (count) => {
    unread.notification_count = count;
  });
  readOptionalNumber(value, "highlight_count", (count) => {
    unread.highlight_count = count;
  });
  return unread;
}

function readMatrixClientEvent(
  value: Record<string, unknown>,
): MatrixClientEvent {
  const result: MatrixClientEvent = {
    content: readRecord(value, "content", "client event"),
    event_id: readString(value, "event_id", "invalid_envelope"),
    origin_server_ts: readNumber(
      value,
      "origin_server_ts",
      "invalid_envelope",
    ),
    room_id: readString(value, "room_id", "invalid_envelope"),
    sender: readString(value, "sender", "invalid_envelope"),
    type: readString(value, "type", "invalid_envelope"),
  };
  readOptionalString(value, "state_key", (stateKey) => {
    result.state_key = stateKey;
  });
  if (value.unsigned !== null && value.unsigned !== undefined) {
    result.unsigned = readRecord(value, "unsigned", "client event");
  }
  return result;
}

function readMatrixWhoamiEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixWhoami> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixWhoami = {
      user_id: readString(value, "user_id", "invalid_envelope"),
    };
    readOptionalString(value, "device_id", (deviceId) => {
      result.device_id = deviceId;
    });
    readOptionalBoolean(value, "is_guest", (isGuest) => {
      result.is_guest = isGuest;
    });
    return result;
  });
}

function readProtocolResult<T>(
  envelope: Record<string, unknown>,
  readValue: (value: Record<string, unknown>) => T,
): ProtocolResult<T> {
  const ok = readBoolean(envelope, "ok");
  if (ok) {
    if (envelope.error !== null) {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        "successful parse envelope must include error: null",
      );
    }
    return {
      ok: true,
      value: readValue(readRecord(envelope, "value", "parse envelope")),
      error: null,
    };
  }

  if (envelope.value !== null) {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      "failed parse envelope must include value: null",
    );
  }
  return {
    ok: false,
    value: null,
    error: readProtocolErrorEnvelope(
      readRecord(envelope, "error", "parse envelope"),
    ),
  };
}

function readProtocolErrorEnvelope(
  error: Record<string, unknown>,
): ProtocolErrorEnvelope {
  return {
    code: readString(error, "code", "invalid_envelope"),
    message: readString(error, "message", "invalid_envelope"),
    details: readStringRecord(readRecord(error, "details", "error envelope")),
  };
}

function parseJsonObject(
  source: string,
  context: string,
): Record<string, unknown> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(source);
  } catch (error) {
    throw new HouraProtocolCoreFacadeError(
      context === "artifact manifest" ? "invalid_manifest" : "invalid_json",
      `${context} is not valid JSON: ${String(error)}`,
    );
  }
  if (!isRecord(parsed)) {
    throw new HouraProtocolCoreFacadeError(
      context === "artifact manifest" ? "invalid_manifest" : "invalid_envelope",
      `${context} must be a JSON object`,
    );
  }
  return parsed;
}

function readRecord(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, unknown> {
  const value = source[field];
  if (!isRecord(value)) {
    throw new HouraProtocolCoreFacadeError(
      context === "artifact manifest" ? "invalid_manifest" : "invalid_envelope",
      `${context}.${field} must be a JSON object`,
    );
  }
  return value;
}

function assertRecord(
  value: unknown,
  context: string,
  errorCode: FacadeErrorCode = "invalid_envelope",
): Record<string, unknown> {
  if (!isRecord(value)) {
    throw new HouraProtocolCoreFacadeError(
      errorCode,
      `${context} must be a JSON object`,
    );
  }
  return value;
}

function readString(
  source: Record<string, unknown>,
  field: string,
  errorCode: FacadeErrorCode = "invalid_manifest",
): string {
  const value = source[field];
  if (typeof value !== "string") {
    throw new HouraProtocolCoreFacadeError(
      errorCode,
      `${field} must be a string`,
    );
  }
  return value;
}

function readOptionalString(
  source: Record<string, unknown>,
  field: string,
  apply: (value: string) => void,
  context?: string,
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  if (typeof value !== "string") {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      context
        ? `${context}.${field} must be a string`
        : `${field} must be a string`,
    );
  }
  apply(value);
}

function readContextString(
  source: Record<string, unknown>,
  field: string,
  context: string,
): string {
  const value = source[field];
  if (typeof value !== "string") {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${context}.${field} must be a string`,
    );
  }
  return value;
}

function readNumber(
  source: Record<string, unknown>,
  field: string,
  errorCode: FacadeErrorCode = "invalid_manifest",
): number {
  const value = source[field];
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new HouraProtocolCoreFacadeError(
      errorCode,
      `${field} must be an integer`,
    );
  }
  return value;
}

function readContextNumber(
  source: Record<string, unknown>,
  field: string,
  context: string,
): number {
  const value = source[field];
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${context}.${field} must be an integer`,
    );
  }
  return value;
}

function readOptionalNumber(
  source: Record<string, unknown>,
  field: string,
  apply: (value: number) => void,
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${field} must be an integer`,
    );
  }
  apply(value);
}

function readBoolean(source: Record<string, unknown>, field: string): boolean {
  const value = source[field];
  if (typeof value !== "boolean") {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${field} must be a boolean`,
    );
  }
  return value;
}

function readOptionalBoolean(
  source: Record<string, unknown>,
  field: string,
  apply: (value: boolean) => void,
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  if (typeof value !== "boolean") {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${field} must be a boolean`,
    );
  }
  apply(value);
}

function readArray(
  source: Record<string, unknown>,
  field: string,
  errorCode: FacadeErrorCode = "invalid_manifest",
): unknown[] {
  const value = source[field];
  if (!Array.isArray(value)) {
    throw new HouraProtocolCoreFacadeError(
      errorCode,
      `${field} must be an array`,
    );
  }
  return value;
}

function readRecordArray(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, unknown>[] {
  return readArray(source, field, "invalid_envelope").map((entry, index) =>
    assertRecord(entry, `${context}.${index}`),
  );
}

function readStringArray(
  source: Record<string, unknown>,
  field: string,
  errorCode: FacadeErrorCode = "invalid_manifest",
): string[] {
  const value = source[field];
  if (!Array.isArray(value) || value.some((entry) => typeof entry !== "string")) {
    throw new HouraProtocolCoreFacadeError(
      errorCode,
      `${field} must be a string array`,
    );
  }
  return value;
}

function readBooleanRecord(
  source: Record<string, unknown>,
): Record<string, boolean> {
  const result: Record<string, boolean> = {};
  for (const [key, value] of Object.entries(source)) {
    if (typeof value !== "boolean") {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        `unstable_features.${key} must be a boolean`,
      );
    }
    result[key] = value;
  }
  return result;
}

function readStringRecord(
  source: Record<string, unknown>,
): Record<string, string> {
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(source)) {
    if (typeof value !== "string") {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        `details.${key} must be a string`,
      );
    }
    result[key] = value;
  }
  return result;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
