import { readFileSync } from "node:fs";
import { join } from "node:path";

import {
  HOURA_PROTOCOL_CORE_ABI_VERSION,
  HOURA_PROTOCOL_CORE_CRATE_NAME,
  HOURA_PROTOCOL_CORE_CRATE_VERSION,
  HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY,
  HOURA_PROTOCOL_CORE_SPEC_IDS,
  createHouraProtocolCore,
} from "./dist/index.js";

const iterations = readNumberOption("--iterations") ?? 200;
const jsonOutput = process.argv.includes("--json");
const specRoot = process.env.HOURA_SPEC_ROOT ?? "../../houra-spec";
const vectorPath = ["test-vectors/core/matrix", "client-versions-basic.json"].join("-");
const vector = JSON.parse(readFileSync(join(specRoot, vectorPath), "utf8"));

if (vector.contract !== "SPEC-030") {
  throw new Error("benchmark vector must be SPEC-030");
}

const body = vector.expected.body_contains;
const payload = JSON.stringify(body);
const payloadBytes = Buffer.byteLength(payload);
const core = createHouraProtocolCore({
  houraArtifactManifestJson() {
    return JSON.stringify({
      manifest_schema_version: 1,
      crate_name: HOURA_PROTOCOL_CORE_CRATE_NAME,
      crate_version: HOURA_PROTOCOL_CORE_CRATE_VERSION,
      abi_version: HOURA_PROTOCOL_CORE_ABI_VERSION,
      protocol_boundary: HOURA_PROTOCOL_CORE_PROTOCOL_BOUNDARY,
      supported_specs: [...HOURA_PROTOCOL_CORE_SPEC_IDS],
      supported_binding_kinds: ["wasm"],
    });
  },
  parseMatrixClientVersionsResponseJson(responseBody) {
    const parsed = JSON.parse(responseBody);
    if (!Array.isArray(parsed.versions) || parsed.versions.length === 0) {
      return JSON.stringify({
        ok: false,
        value: null,
        error: { code: "invalid_versions", message: "versions must be non-empty" },
      });
    }
    return JSON.stringify({
      ok: true,
      value: {
        versions: parsed.versions,
        unstable_features: parsed.unstable_features ?? {},
      },
      error: null,
    });
  },
});

const samples = [];
for (let index = 0; index < iterations; index += 1) {
  const started = process.hrtime.bigint();
  core.parseMatrixClientVersionsResponse(payload);
  const elapsed = process.hrtime.bigint() - started;
  samples.push(Number(elapsed / 1000n));
}
samples.sort((left, right) => left - right);

const report = {
  surface_kind: "typescript-facade-baseline",
  language: "typescript",
  status: "measured",
  support_claim_status: "current-production-path-baseline",
  benchmark_id: "spec-030-versions-parse",
  spec_id: "SPEC-030",
  vector: vectorPath,
  payload_bytes: payloadBytes,
  iterations,
  min_microseconds: samples.at(0) ?? 0,
  median_microseconds: percentile(samples, 0.5),
  p95_microseconds: percentile(samples, 0.95),
  max_microseconds: samples.at(-1) ?? 0,
};

if (jsonOutput) {
  console.log(JSON.stringify(report, null, 2));
} else {
  console.log(
    `typescript-facade-baseline p95=${report.p95_microseconds}us iterations=${iterations} payload=${payloadBytes}B`,
  );
}

function percentile(samples, percentileValue) {
  if (samples.length === 0) {
    return 0;
  }
  const index = Math.ceil((samples.length - 1) * percentileValue);
  return samples[index];
}

function readNumberOption(name) {
  for (let index = 0; index < process.argv.length; index += 1) {
    const arg = process.argv[index];
    if (arg === name && index + 1 < process.argv.length) {
      return Number.parseInt(process.argv[index + 1], 10);
    }
    if (arg.startsWith(`${name}=`)) {
      return Number.parseInt(arg.slice(name.length + 1), 10);
    }
  }
  return undefined;
}
