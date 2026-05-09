use std::collections::BTreeMap;

use serde::Deserialize;

pub const MATRIX_CLIENT_VERSIONS_METHOD: &str = "GET";
pub const MATRIX_CLIENT_VERSIONS_PATH: &str = "/_matrix/client/versions";

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MatrixClientVersions {
    pub versions: Vec<String>,
    pub unstable_features: BTreeMap<String, bool>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ProtocolError {
    Json(String),
    EmptyVersions,
    EmptyVersion { index: usize },
}

impl std::fmt::Display for ProtocolError {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ProtocolError::Json(message) => write!(formatter, "invalid JSON: {message}"),
            ProtocolError::EmptyVersions => write!(formatter, "versions must not be empty"),
            ProtocolError::EmptyVersion { index } => {
                write!(formatter, "versions[{index}] must not be empty")
            }
        }
    }
}

impl std::error::Error for ProtocolError {}

#[derive(Debug, Deserialize)]
struct MatrixClientVersionsWire {
    versions: Vec<String>,
    #[serde(default)]
    unstable_features: BTreeMap<String, bool>,
}

pub fn parse_matrix_client_versions_response(
    bytes: &[u8],
) -> Result<MatrixClientVersions, ProtocolError> {
    let wire: MatrixClientVersionsWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    if wire.versions.is_empty() {
        return Err(ProtocolError::EmptyVersions);
    }

    for (index, version) in wire.versions.iter().enumerate() {
        if version.is_empty() {
            return Err(ProtocolError::EmptyVersion { index });
        }
    }

    Ok(MatrixClientVersions {
        versions: wire.versions,
        unstable_features: wire.unstable_features,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::Value;
    use std::path::{Path, PathBuf};

    #[test]
    fn exposes_matrix_client_versions_request_metadata() {
        assert_eq!(MATRIX_CLIENT_VERSIONS_METHOD, "GET");
        assert_eq!(MATRIX_CLIENT_VERSIONS_PATH, "/_matrix/client/versions",);
    }

    #[test]
    fn parses_matrix_client_versions_vector_response() {
        let vector_name = ["matrix", "client", "versions", "basic"].join("-");
        let vector = read_spec_vector(&format!("test-vectors/core/{vector_name}.json"));
        let request = &vector["request"];
        assert_eq!(request["method"], MATRIX_CLIENT_VERSIONS_METHOD);
        assert_eq!(request["path"], MATRIX_CLIENT_VERSIONS_PATH);

        let response_body = vector["expected"]["body_contains"].to_string();
        let parsed = parse_matrix_client_versions_response(response_body.as_bytes())
            .expect("vector response should parse");

        assert_eq!(parsed.versions, vec!["v1.18"]);
        assert!(parsed.unstable_features.is_empty());
    }

    #[test]
    fn treats_missing_unstable_features_as_empty() {
        let parsed = parse_matrix_client_versions_response(br#"{"versions":["v1.18"]}"#)
            .expect("response without unstable_features should parse");

        assert_eq!(parsed.versions, vec!["v1.18"]);
        assert!(parsed.unstable_features.is_empty());
    }

    #[test]
    fn rejects_empty_versions() {
        let error =
            parse_matrix_client_versions_response(br#"{"versions":[],"unstable_features":{}}"#)
                .expect_err("empty versions must be rejected");

        assert_eq!(error, ProtocolError::EmptyVersions);
    }

    #[test]
    fn rejects_empty_version_strings() {
        let error =
            parse_matrix_client_versions_response(br#"{"versions":[""],"unstable_features":{}}"#)
                .expect_err("empty version strings must be rejected");

        assert_eq!(error, ProtocolError::EmptyVersion { index: 0 });
    }

    fn read_spec_vector(relative_path: &str) -> Value {
        let spec_root = spec_root();
        let path = spec_root.join(relative_path);
        let source = std::fs::read_to_string(&path)
            .unwrap_or_else(|error| panic!("failed to read {}: {error}", path.display()));
        serde_json::from_str(&source)
            .unwrap_or_else(|error| panic!("failed to parse {}: {error}", path.display()))
    }

    fn spec_root() -> PathBuf {
        if let Ok(path) = std::env::var("HOURA_SPEC_ROOT") {
            return PathBuf::from(path);
        }

        for candidate in ["../../houra-spec", "../houra-spec"] {
            let path = Path::new(candidate);
            if path.join("test-vectors").exists() {
                return path.to_path_buf();
            }
        }

        panic!("set HOURA_SPEC_ROOT to the canonical houra-spec checkout");
    }
}
