export const HOURA_PROTOCOL_CORE_ABI_VERSION = 1;
export const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION = 1;
export const HOURA_PROTOCOL_CORE_WASM_BINDING_KIND = "wasm";
export const HOURA_PROTOCOL_CORE_SPEC_IDS = [
  "SPEC-030",
  "SPEC-031",
  "SPEC-032",
  "SPEC-033",
  "SPEC-034",
  "SPEC-035",
  "SPEC-036",
] as const;

export interface HouraProtocolCoreWasmBinding {
  houraArtifactManifestJson(): string;
  parseMatrixClientEventJson(responseBody: string): string;
  parseMatrixClientVersionsResponseJson(responseBody: string): string;
  parseMatrixDeviceJson(responseBody: string): string;
  parseMatrixDevicesJson(responseBody: string): string;
  parseMatrixEventIdResponseJson(responseBody: string): string;
  parseMatrixErrorEnvelopeJson(responseBody: string): string;
  parseMatrixLoginFlowsJson(responseBody: string): string;
  parseMatrixLoginSessionJson(responseBody: string): string;
  parseMatrixMessagesResponseJson(responseBody: string): string;
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
  parseMatrixLoginFlows(responseBody: string): ProtocolResult<MatrixLoginFlows>;
  parseMatrixLoginSession(
    responseBody: string,
  ): ProtocolResult<MatrixLoginSession>;
  parseMatrixMessagesResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMessagesResponse>;
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
    parseMatrixMessagesResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixMessagesResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixMessagesResponseEnvelope(envelope);
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
  for (const specId of HOURA_PROTOCOL_CORE_SPEC_IDS) {
    if (!manifest.supported_specs.includes(specId)) {
      issues.push("supported_specs");
      break;
    }
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

function readMatrixClientVersionsEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixClientVersions> {
  const ok = readBoolean(envelope, "ok");
  if (ok) {
    return {
      ok: true,
      value: readMatrixClientVersions(
        readRecord(envelope, "value", "parse envelope"),
      ),
      error: null,
    };
  }

  return {
    ok: false,
    value: null,
    error: readProtocolErrorEnvelope(
      readRecord(envelope, "error", "parse envelope"),
    ),
  };
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
    return {
      ok: true,
      value: readValue(readRecord(envelope, "value", "parse envelope")),
      error: null,
    };
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
      "invalid_json",
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
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  if (typeof value !== "string") {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${field} must be a string`,
    );
  }
  apply(value);
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
