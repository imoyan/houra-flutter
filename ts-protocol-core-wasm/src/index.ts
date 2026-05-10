export const HOURA_PROTOCOL_CORE_ABI_VERSION = 1;
export const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION = 1;
export const HOURA_PROTOCOL_CORE_WASM_BINDING_KIND = "wasm";
export const HOURA_PROTOCOL_CORE_SPEC_IDS = [
  "SPEC-030",
  "SPEC-031",
  "SPEC-032",
  "SPEC-033",
] as const;

export interface HouraProtocolCoreWasmBinding {
  houraArtifactManifestJson(): string;
  parseMatrixClientVersionsResponseJson(responseBody: string): string;
  parseMatrixErrorEnvelopeJson(responseBody: string): string;
  parseMatrixLoginFlowsJson(responseBody: string): string;
  parseMatrixLoginSessionJson(responseBody: string): string;
  parseMatrixRegistrationAvailabilityJson(responseBody: string): string;
  parseMatrixRegistrationSessionJson(responseBody: string): string;
  parseMatrixRegistrationTokenValidityJson(responseBody: string): string;
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
  session: string;
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
  parseMatrixClientVersionsResponse(
    responseBody: string,
  ): ProtocolResult<MatrixClientVersions>;
  parseMatrixErrorEnvelope(responseBody: string): ProtocolResult<MatrixErrorEnvelope>;
  parseMatrixLoginFlows(responseBody: string): ProtocolResult<MatrixLoginFlows>;
  parseMatrixLoginSession(
    responseBody: string,
  ): ProtocolResult<MatrixLoginSession>;
  parseMatrixRegistrationAvailability(
    responseBody: string,
  ): ProtocolResult<MatrixRegistrationAvailability>;
  parseMatrixRegistrationSession(
    responseBody: string,
  ): ProtocolResult<MatrixLoginSession>;
  parseMatrixRegistrationTokenValidity(
    responseBody: string,
  ): ProtocolResult<MatrixRegistrationTokenValidity>;
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
    parseMatrixClientVersionsResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixClientVersionsResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientVersionsEnvelope(envelope);
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
      return readMatrixLoginSessionEnvelope(envelope);
    },
    parseMatrixRegistrationTokenValidity(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRegistrationTokenValidityJson(responseBody),
        "parse envelope",
      );
      return readMatrixRegistrationTokenValidityEnvelope(envelope);
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

    return {
      completed: readStringArray(value, "completed", "invalid_envelope"),
      flows,
      params: readRecord(value, "params", "uia value"),
      session: readString(value, "session", "invalid_envelope"),
    };
  });
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
