use std::env;
use std::fs;
use std::path::PathBuf;
use std::time::Instant;

use serde_json::Value;

fn main() {
    let args: Vec<String> = env::args().collect();
    let iterations = read_usize_option(&args, "--iterations").unwrap_or(200);
    let json_output = args.iter().any(|arg| arg == "--json");
    let spec_root = env::var("HOURA_SPEC_ROOT").unwrap_or_else(|_| "../../houra-spec".to_string());
    let vector_path = ["test-vectors/core/matrix", "client-versions-basic.json"].join("-");
    let vector = read_vector(&spec_root, &vector_path);
    let body = vector
        .get("expected")
        .and_then(|expected| expected.get("body_contains"))
        .expect("benchmark vector must include expected.body_contains");
    let payload = serde_json::to_vec(body).expect("benchmark body should serialize");
    let payload_bytes = payload.len();

    let mut samples = Vec::with_capacity(iterations);
    for _ in 0..iterations {
        let started = Instant::now();
        houra_protocol_core::parse_matrix_client_versions_response(&payload)
            .expect("benchmark payload should parse");
        samples.push(started.elapsed().as_micros() as u64);
    }
    samples.sort_unstable();
    let report = serde_json::json!({
        "surface_kind": "rust-native",
        "language": "rust",
        "status": "measured",
        "support_claim_status": "native-protocol-core-candidate-only",
        "benchmark_id": "spec-030-versions-parse",
        "spec_id": "SPEC-030",
        "vector": vector_path,
        "payload_bytes": payload_bytes,
        "iterations": iterations,
        "min_microseconds": samples.first().copied().unwrap_or(0),
        "median_microseconds": percentile(&samples, 0.50),
        "p95_microseconds": percentile(&samples, 0.95),
        "max_microseconds": samples.last().copied().unwrap_or(0),
    });

    if json_output {
        println!(
            "{}",
            serde_json::to_string_pretty(&report).expect("benchmark report should serialize")
        );
    } else {
        println!(
            "rust-native p95={}us iterations={} payload={}B",
            report["p95_microseconds"], iterations, payload_bytes
        );
    }
}

fn read_vector(spec_root: &str, vector_path: &str) -> Value {
    let path = PathBuf::from(spec_root).join(vector_path);
    let source = fs::read_to_string(&path).unwrap_or_else(|error| {
        panic!(
            "failed to read benchmark vector {}: {}",
            path.display(),
            error
        )
    });
    let decoded: Value = serde_json::from_str(&source).expect("benchmark vector should be JSON");
    assert_eq!(decoded["contract"], "SPEC-030");
    decoded
}

fn percentile(samples: &[u64], percentile: f64) -> u64 {
    if samples.is_empty() {
        return 0;
    }
    let index = ((samples.len() - 1) as f64 * percentile).ceil() as usize;
    samples[index]
}

fn read_usize_option(args: &[String], name: &str) -> Option<usize> {
    for index in 0..args.len() {
        let arg = &args[index];
        if arg == name && index + 1 < args.len() {
            return args[index + 1].parse().ok();
        }
        if let Some(value) = arg.strip_prefix(&format!("{name}=")) {
            return value.parse().ok();
        }
    }
    None
}
