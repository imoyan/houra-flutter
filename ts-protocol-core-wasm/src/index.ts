export const HOURA_PROTOCOL_CORE_ABI_VERSION = 1;
export const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION = 1;
export const HOURA_PROTOCOL_CORE_WASM_BINDING_KIND = "wasm";
export const HOURA_PROTOCOL_CORE_SPEC_IDS = ["SPEC-030", "SPEC-031"] as const;

export interface HouraProtocolCoreWasmBinding {
  houraArtifactManifestJson(): string;
  parseMatrixClientVersionsResponseJson(responseBody: string): string;
  parseMatrixErrorEnvelopeJson(responseBody: string): string;
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
