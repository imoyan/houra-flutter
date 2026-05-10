use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};
use serde_json::Value;

pub const HOURA_PROTOCOL_CORE_ABI_VERSION: u32 = 1;
pub const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION: u32 = 1;
pub const HOURA_PROTOCOL_CORE_CRATE_NAME: &str = env!("CARGO_PKG_NAME");
pub const HOURA_PROTOCOL_CORE_CRATE_VERSION: &str = env!("CARGO_PKG_VERSION");
pub const MATRIX_CLIENT_VERSIONS_METHOD: &str = "GET";
pub const MATRIX_CLIENT_VERSIONS_PATH: &str = "/_matrix/client/versions";
const SUPPORTED_SPECS: &[&str] = &["SPEC-030", "SPEC-031", "SPEC-032", "SPEC-033"];

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ArtifactManifest {
    pub manifest_schema_version: u32,
    pub crate_name: String,
    pub crate_version: String,
    pub abi_version: u32,
    pub protocol_boundary: String,
    pub supported_specs: Vec<String>,
    pub supported_binding_kinds: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixClientVersions {
    pub versions: Vec<String>,
    pub unstable_features: BTreeMap<String, bool>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixErrorEnvelope {
    pub errcode: String,
    pub error: Option<String>,
    pub retry_after_ms: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFoundationValidation {
    pub valid: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixLoginFlow {
    #[serde(rename = "type")]
    pub flow_type: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixLoginFlows {
    pub flows: Vec<MatrixLoginFlow>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixLoginSession {
    pub user_id: String,
    pub access_token: String,
    pub device_id: Option<String>,
    pub home_server: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixWhoami {
    pub user_id: String,
    pub device_id: Option<String>,
    pub is_guest: Option<bool>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRegistrationAvailability {
    pub available: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRegistrationTokenValidity {
    pub valid: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixUserInteractiveAuthFlow {
    pub stages: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixUserInteractiveAuthRequired {
    pub completed: Vec<String>,
    pub flows: Vec<MatrixUserInteractiveAuthFlow>,
    pub params: BTreeMap<String, Value>,
    pub session: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ProtocolErrorEnvelope {
    pub code: String,
    pub message: String,
    pub details: BTreeMap<String, String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixClientVersionsParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixClientVersions>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixErrorParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixErrorEnvelope>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFoundationValidationEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFoundationValidation>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixLoginFlowsParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixLoginFlows>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixLoginSessionParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixLoginSession>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixWhoamiParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixWhoami>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRegistrationAvailabilityParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixRegistrationAvailability>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRegistrationTokenValidityParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixRegistrationTokenValidity>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixUserInteractiveAuthRequiredParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixUserInteractiveAuthRequired>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ProtocolError {
    Json(String),
    EmptyVersions,
    EmptyVersion { index: usize },
    MissingErrcode,
    InvalidFoundationField { field: String },
    EmptyFlows,
    EmptyFlowType { index: usize },
    InvalidAuthField { field: String },
    InvalidRegistrationField { field: String },
}

impl ProtocolError {
    pub fn code(&self) -> &'static str {
        match self {
            ProtocolError::Json(_) => "invalid_json",
            ProtocolError::EmptyVersions => "empty_versions",
            ProtocolError::EmptyVersion { .. } => "empty_version",
            ProtocolError::MissingErrcode => "missing_errcode",
            ProtocolError::InvalidFoundationField { .. } => "invalid_foundation_field",
            ProtocolError::EmptyFlows => "empty_flows",
            ProtocolError::EmptyFlowType { .. } => "empty_flow_type",
            ProtocolError::InvalidAuthField { .. } => "invalid_auth_field",
            ProtocolError::InvalidRegistrationField { .. } => "invalid_registration_field",
        }
    }

    pub fn to_envelope(&self) -> ProtocolErrorEnvelope {
        let mut details = BTreeMap::new();
        match self {
            ProtocolError::EmptyVersion { index } => {
                details.insert("index".to_owned(), index.to_string());
            }
            ProtocolError::InvalidFoundationField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::EmptyFlowType { index } => {
                details.insert("index".to_owned(), index.to_string());
            }
            ProtocolError::InvalidAuthField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidRegistrationField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            _ => {}
        }

        ProtocolErrorEnvelope {
            code: self.code().to_owned(),
            message: self.to_string(),
            details,
        }
    }
}

impl std::fmt::Display for ProtocolError {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ProtocolError::Json(message) => write!(formatter, "invalid JSON: {message}"),
            ProtocolError::EmptyVersions => write!(formatter, "versions must not be empty"),
            ProtocolError::EmptyVersion { index } => {
                write!(formatter, "versions[{index}] must not be empty")
            }
            ProtocolError::MissingErrcode => {
                write!(formatter, "errcode must be a non-empty string")
            }
            ProtocolError::InvalidFoundationField { field } => {
                write!(formatter, "{field} is not a valid Matrix foundation value")
            }
            ProtocolError::EmptyFlows => write!(formatter, "flows must not be empty"),
            ProtocolError::EmptyFlowType { index } => {
                write!(formatter, "flows[{index}].type must not be empty")
            }
            ProtocolError::InvalidAuthField { field } => {
                write!(
                    formatter,
                    "{field} is not a valid Matrix auth/session value"
                )
            }
            ProtocolError::InvalidRegistrationField { field } => {
                write!(
                    formatter,
                    "{field} is not a valid Matrix registration value"
                )
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

#[derive(Debug, Deserialize)]
struct MatrixErrorWire {
    errcode: Option<String>,
    error: Option<String>,
    retry_after_ms: Option<u64>,
}

#[derive(Debug, Deserialize)]
struct MatrixLoginFlowsWire {
    flows: Vec<MatrixLoginFlowWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixLoginFlowWire {
    #[serde(rename = "type")]
    flow_type: String,
}

#[derive(Debug, Deserialize)]
struct MatrixLoginSessionWire {
    user_id: Option<String>,
    access_token: Option<String>,
    device_id: Option<String>,
    home_server: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixWhoamiWire {
    user_id: Option<String>,
    device_id: Option<String>,
    is_guest: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixRegistrationAvailabilityWire {
    available: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixRegistrationTokenValidityWire {
    valid: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixUserInteractiveAuthFlowWire {
    stages: Vec<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixUserInteractiveAuthRequiredWire {
    #[serde(default)]
    completed: Vec<String>,
    flows: Vec<MatrixUserInteractiveAuthFlowWire>,
    #[serde(default)]
    params: BTreeMap<String, Value>,
    session: Option<String>,
}

pub fn abi_version() -> u32 {
    HOURA_PROTOCOL_CORE_ABI_VERSION
}

pub fn artifact_manifest() -> ArtifactManifest {
    artifact_manifest_for_binding_kinds(&[])
}

pub fn artifact_manifest_for_binding_kinds(binding_kinds: &[&str]) -> ArtifactManifest {
    ArtifactManifest {
        manifest_schema_version: HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION,
        crate_name: HOURA_PROTOCOL_CORE_CRATE_NAME.to_owned(),
        crate_version: HOURA_PROTOCOL_CORE_CRATE_VERSION.to_owned(),
        abi_version: HOURA_PROTOCOL_CORE_ABI_VERSION,
        protocol_boundary: "pure-protocol-core".to_owned(),
        supported_specs: SUPPORTED_SPECS
            .iter()
            .map(|spec| spec.to_string())
            .collect(),
        supported_binding_kinds: binding_kinds.iter().map(|kind| kind.to_string()).collect(),
    }
}

pub fn artifact_manifest_json() -> String {
    artifact_manifest_json_for_binding_kinds(&[])
}

pub fn artifact_manifest_json_for_binding_kinds(binding_kinds: &[&str]) -> String {
    serde_json::to_string(&artifact_manifest_for_binding_kinds(binding_kinds))
        .expect("artifact manifest serialization should be infallible")
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

pub fn parse_matrix_client_versions_response_envelope(
    bytes: &[u8],
) -> MatrixClientVersionsParseEnvelope {
    match parse_matrix_client_versions_response(bytes) {
        Ok(value) => MatrixClientVersionsParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixClientVersionsParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_client_versions_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_client_versions_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_error_envelope(bytes: &[u8]) -> Result<MatrixErrorEnvelope, ProtocolError> {
    let wire: MatrixErrorWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let errcode = wire.errcode.ok_or(ProtocolError::MissingErrcode)?;
    if errcode.is_empty() {
        return Err(ProtocolError::MissingErrcode);
    }
    Ok(MatrixErrorEnvelope {
        errcode,
        error: wire.error,
        retry_after_ms: wire.retry_after_ms,
    })
}

pub fn parse_matrix_error_envelope_envelope(bytes: &[u8]) -> MatrixErrorParseEnvelope {
    match parse_matrix_error_envelope(bytes) {
        Ok(value) => MatrixErrorParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixErrorParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_error_envelope_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_error_envelope_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn validate_matrix_foundation_identifiers(
    value: &Value,
) -> Result<MatrixFoundationValidation, ProtocolError> {
    validate_field(value, "user_id", is_matrix_user_id)?;
    validate_field(value, "room_id", is_matrix_room_id)?;
    validate_field(value, "room_alias", is_matrix_room_alias)?;
    validate_field(value, "event_id", is_matrix_event_id)?;
    validate_field(value, "server_name", is_matrix_server_name)?;
    validate_field(value, "content_uri", is_matrix_content_uri)?;
    validate_field(value, "event_type", is_matrix_namespaced_identifier)?;
    if !value
        .get("origin_server_ts")
        .and_then(Value::as_i64)
        .is_some_and(|timestamp| timestamp >= 0)
    {
        return Err(ProtocolError::InvalidFoundationField {
            field: "origin_server_ts".to_owned(),
        });
    }

    Ok(MatrixFoundationValidation { valid: true })
}

pub fn validate_matrix_foundation_identifiers_envelope(
    bytes: &[u8],
) -> MatrixFoundationValidationEnvelope {
    let parsed = serde_json::from_slice::<Value>(bytes)
        .map_err(|error| ProtocolError::Json(error.to_string()))
        .and_then(|value| validate_matrix_foundation_identifiers(&value));

    match parsed {
        Ok(value) => MatrixFoundationValidationEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFoundationValidationEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn validate_matrix_foundation_identifiers_json(bytes: &[u8]) -> String {
    serde_json::to_string(&validate_matrix_foundation_identifiers_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_login_flows(bytes: &[u8]) -> Result<MatrixLoginFlows, ProtocolError> {
    let wire: MatrixLoginFlowsWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    if wire.flows.is_empty() {
        return Err(ProtocolError::EmptyFlows);
    }
    let mut flows = Vec::with_capacity(wire.flows.len());
    for (index, flow) in wire.flows.into_iter().enumerate() {
        if flow.flow_type.is_empty() {
            return Err(ProtocolError::EmptyFlowType { index });
        }
        flows.push(MatrixLoginFlow {
            flow_type: flow.flow_type,
        });
    }

    Ok(MatrixLoginFlows { flows })
}

pub fn parse_matrix_login_flows_envelope(bytes: &[u8]) -> MatrixLoginFlowsParseEnvelope {
    match parse_matrix_login_flows(bytes) {
        Ok(value) => MatrixLoginFlowsParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixLoginFlowsParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_login_flows_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_login_flows_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_login_session(bytes: &[u8]) -> Result<MatrixLoginSession, ProtocolError> {
    let wire: MatrixLoginSessionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixLoginSession {
        user_id: required_non_empty(wire.user_id, "user_id")?,
        access_token: required_non_empty(wire.access_token, "access_token")?,
        device_id: optional_non_empty(wire.device_id, "device_id")?,
        home_server: optional_non_empty(wire.home_server, "home_server")?,
    })
}

pub fn parse_matrix_login_session_envelope(bytes: &[u8]) -> MatrixLoginSessionParseEnvelope {
    match parse_matrix_login_session(bytes) {
        Ok(value) => MatrixLoginSessionParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixLoginSessionParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_login_session_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_login_session_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_whoami(bytes: &[u8]) -> Result<MatrixWhoami, ProtocolError> {
    let wire: MatrixWhoamiWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixWhoami {
        user_id: required_non_empty(wire.user_id, "user_id")?,
        device_id: optional_non_empty(wire.device_id, "device_id")?,
        is_guest: wire.is_guest,
    })
}

pub fn parse_matrix_whoami_envelope(bytes: &[u8]) -> MatrixWhoamiParseEnvelope {
    match parse_matrix_whoami(bytes) {
        Ok(value) => MatrixWhoamiParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixWhoamiParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_whoami_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_whoami_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_registration_availability(
    bytes: &[u8],
) -> Result<MatrixRegistrationAvailability, ProtocolError> {
    let wire: MatrixRegistrationAvailabilityWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    Ok(MatrixRegistrationAvailability {
        available: wire
            .available
            .ok_or_else(|| invalid_registration_field("available"))?,
    })
}

pub fn parse_matrix_registration_availability_envelope(
    bytes: &[u8],
) -> MatrixRegistrationAvailabilityParseEnvelope {
    match parse_matrix_registration_availability(bytes) {
        Ok(value) => MatrixRegistrationAvailabilityParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixRegistrationAvailabilityParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_registration_availability_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_registration_availability_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_registration_session(
    bytes: &[u8],
) -> Result<MatrixLoginSession, ProtocolError> {
    parse_matrix_login_session(bytes)
}

pub fn parse_matrix_registration_session_envelope(bytes: &[u8]) -> MatrixLoginSessionParseEnvelope {
    parse_matrix_login_session_envelope(bytes)
}

pub fn parse_matrix_registration_session_json(bytes: &[u8]) -> String {
    parse_matrix_login_session_json(bytes)
}

pub fn parse_matrix_registration_token_validity(
    bytes: &[u8],
) -> Result<MatrixRegistrationTokenValidity, ProtocolError> {
    let wire: MatrixRegistrationTokenValidityWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    Ok(MatrixRegistrationTokenValidity {
        valid: wire
            .valid
            .ok_or_else(|| invalid_registration_field("valid"))?,
    })
}

pub fn parse_matrix_registration_token_validity_envelope(
    bytes: &[u8],
) -> MatrixRegistrationTokenValidityParseEnvelope {
    match parse_matrix_registration_token_validity(bytes) {
        Ok(value) => MatrixRegistrationTokenValidityParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixRegistrationTokenValidityParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_registration_token_validity_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_registration_token_validity_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_user_interactive_auth_required(
    bytes: &[u8],
) -> Result<MatrixUserInteractiveAuthRequired, ProtocolError> {
    let wire: MatrixUserInteractiveAuthRequiredWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    if wire.flows.is_empty() {
        return Err(invalid_registration_field("flows"));
    }

    let mut flows = Vec::with_capacity(wire.flows.len());
    for (index, flow) in wire.flows.into_iter().enumerate() {
        if flow.stages.is_empty() {
            return Err(invalid_registration_field(&format!("flows.{index}.stages")));
        }
        for (stage_index, stage) in flow.stages.iter().enumerate() {
            if stage.is_empty() {
                return Err(invalid_registration_field(&format!(
                    "flows.{index}.stages.{stage_index}"
                )));
            }
        }
        flows.push(MatrixUserInteractiveAuthFlow {
            stages: flow.stages,
        });
    }
    for (index, completed) in wire.completed.iter().enumerate() {
        if completed.is_empty() {
            return Err(invalid_registration_field(&format!("completed.{index}")));
        }
    }

    Ok(MatrixUserInteractiveAuthRequired {
        completed: wire.completed,
        flows,
        params: wire.params,
        session: required_registration_string(wire.session, "session")?,
    })
}

pub fn parse_matrix_user_interactive_auth_required_envelope(
    bytes: &[u8],
) -> MatrixUserInteractiveAuthRequiredParseEnvelope {
    match parse_matrix_user_interactive_auth_required(bytes) {
        Ok(value) => MatrixUserInteractiveAuthRequiredParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixUserInteractiveAuthRequiredParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_user_interactive_auth_required_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_user_interactive_auth_required_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

fn required_non_empty(value: Option<String>, field: &str) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(ProtocolError::InvalidAuthField {
            field: field.to_owned(),
        }),
    }
}

fn optional_non_empty(value: Option<String>, field: &str) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if value.is_empty() => Err(ProtocolError::InvalidAuthField {
            field: field.to_owned(),
        }),
        value => Ok(value),
    }
}

fn required_registration_string(
    value: Option<String>,
    field: &str,
) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_registration_field(field)),
    }
}

fn invalid_registration_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidRegistrationField {
        field: field.to_owned(),
    }
}

fn validate_field(
    value: &Value,
    field: &str,
    validate: impl Fn(&str) -> bool,
) -> Result<(), ProtocolError> {
    if value
        .get(field)
        .and_then(Value::as_str)
        .is_some_and(validate)
    {
        return Ok(());
    }
    Err(ProtocolError::InvalidFoundationField {
        field: field.to_owned(),
    })
}

fn is_matrix_user_id(value: &str) -> bool {
    let Some(rest) = value.strip_prefix('@') else {
        return false;
    };
    has_localpart_and_server(rest)
}

fn is_matrix_room_id(value: &str) -> bool {
    let Some(rest) = value.strip_prefix('!') else {
        return false;
    };
    has_localpart_and_server(rest)
}

fn is_matrix_room_alias(value: &str) -> bool {
    let Some(rest) = value.strip_prefix('#') else {
        return false;
    };
    has_localpart_and_server(rest)
}

fn is_matrix_event_id(value: &str) -> bool {
    let Some(rest) = value.strip_prefix('$') else {
        return false;
    };
    if rest.is_empty() {
        return false;
    }
    if let Some((event_id, server_name)) = rest.rsplit_once(':') {
        !event_id.is_empty() && is_matrix_server_name(server_name)
    } else {
        true
    }
}

fn is_matrix_content_uri(value: &str) -> bool {
    let Some(rest) = value.strip_prefix("mxc://") else {
        return false;
    };
    let Some((server_name, media_id)) = rest.split_once('/') else {
        return false;
    };
    is_matrix_server_name(server_name) && is_opaque_part(media_id)
}

fn is_matrix_namespaced_identifier(value: &str) -> bool {
    let mut parts = value.split('.');
    let Some(first) = parts.next() else {
        return false;
    };
    is_lower_alnum_part(first) && parts.clone().next().is_some() && parts.all(is_lower_alnum_part)
}

fn has_localpart_and_server(value: &str) -> bool {
    let Some((localpart, server_name)) = value.rsplit_once(':') else {
        return false;
    };
    is_opaque_part(localpart) && is_matrix_server_name(server_name)
}

fn is_matrix_server_name(value: &str) -> bool {
    if value.is_empty() || value.contains(char::is_whitespace) {
        return false;
    }
    let host = value.rsplit_once(':').map_or(value, |(host, _port)| host);
    if host.starts_with('[') {
        return host.ends_with(']') && host.len() > 2;
    }
    host.chars()
        .all(|ch| ch.is_ascii_alphanumeric() || ch == '-' || ch == '.')
}

fn is_opaque_part(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '.' | '_' | '=' | '-' | '/'))
}

fn is_lower_alnum_part(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit())
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::Value;
    use std::path::{Path, PathBuf};

    #[test]
    fn exposes_abi_version() {
        assert_eq!(abi_version(), 1);
    }

    #[test]
    fn exposes_artifact_manifest() {
        let manifest = artifact_manifest();

        assert_eq!(manifest.manifest_schema_version, 1);
        assert_eq!(manifest.crate_name, "houra-protocol-core");
        assert_eq!(manifest.crate_version, "0.1.0");
        assert_eq!(manifest.abi_version, abi_version());
        assert_eq!(manifest.protocol_boundary, "pure-protocol-core");
        assert_eq!(
            manifest.supported_specs,
            vec!["SPEC-030", "SPEC-031", "SPEC-032", "SPEC-033"]
        );
        assert!(manifest.supported_binding_kinds.is_empty());
    }

    #[test]
    fn serializes_artifact_manifest_stably() {
        let json = artifact_manifest_json();

        assert_eq!(
            json,
            "{\"manifest_schema_version\":1,\"crate_name\":\"houra-protocol-core\",\"crate_version\":\"0.1.0\",\"abi_version\":1,\"protocol_boundary\":\"pure-protocol-core\",\"supported_specs\":[\"SPEC-030\",\"SPEC-031\",\"SPEC-032\",\"SPEC-033\"],\"supported_binding_kinds\":[]}"
        );
    }

    #[test]
    fn serializes_artifact_manifest_with_binding_kinds() {
        let json = artifact_manifest_json_for_binding_kinds(&["wasm"]);

        assert_eq!(
            json,
            "{\"manifest_schema_version\":1,\"crate_name\":\"houra-protocol-core\",\"crate_version\":\"0.1.0\",\"abi_version\":1,\"protocol_boundary\":\"pure-protocol-core\",\"supported_specs\":[\"SPEC-030\",\"SPEC-031\",\"SPEC-032\",\"SPEC-033\"],\"supported_binding_kinds\":[\"wasm\"]}"
        );
    }

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
    fn serializes_successful_matrix_client_versions_parse_envelope() {
        let json = parse_matrix_client_versions_response_json(br#"{"versions":["v1.18"]}"#);

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"versions\":[\"v1.18\"],\"unstable_features\":{}},\"error\":null}"
        );
    }

    #[test]
    fn serializes_invalid_json_parse_envelope() {
        let envelope = parse_matrix_client_versions_response_envelope(b"not json");

        assert!(!envelope.ok);
        assert!(envelope.value.is_none());
        let error = envelope.error.expect("invalid JSON should return an error");
        assert_eq!(error.code, "invalid_json");
        assert!(error.message.starts_with("invalid JSON:"));
        assert!(error.details.is_empty());
    }

    #[test]
    fn serializes_empty_versions_parse_envelope() {
        let json = parse_matrix_client_versions_response_json(br#"{"versions":[]}"#);

        assert_eq!(
            json,
            "{\"ok\":false,\"value\":null,\"error\":{\"code\":\"empty_versions\",\"message\":\"versions must not be empty\",\"details\":{}}}"
        );
    }

    #[test]
    fn serializes_empty_version_string_parse_envelope() {
        let json = parse_matrix_client_versions_response_json(br#"{"versions":[""]}"#);

        assert_eq!(
            json,
            "{\"ok\":false,\"value\":null,\"error\":{\"code\":\"empty_version\",\"message\":\"versions[0] must not be empty\",\"details\":{\"index\":\"0\"}}}"
        );
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

    #[test]
    fn parses_matrix_foundation_error_vector() {
        let vector = read_spec_vector("test-vectors/core/matrix-foundation-error-basic.json");
        let response_body = vector["response"]["body"].to_string();
        let parsed = parse_matrix_error_envelope(response_body.as_bytes())
            .expect("Matrix error vector should parse");

        assert_eq!(parsed.errcode, "M_BAD_JSON");
        assert_eq!(parsed.error.as_deref(), Some("Malformed JSON payload."));
        assert_eq!(parsed.retry_after_ms, None);
    }

    #[test]
    fn validates_matrix_foundation_identifier_vector() {
        let vector = read_spec_vector("test-vectors/core/matrix-foundation-identifiers-basic.json");
        let validation = validate_matrix_foundation_identifiers(&vector["event"])
            .expect("Matrix foundation identifiers should validate");

        assert!(validation.valid);
    }

    #[test]
    fn serializes_matrix_error_parse_envelope() {
        let json =
            parse_matrix_error_envelope_json(br#"{"errcode":"M_BAD_JSON","error":"Bad JSON"}"#);

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"errcode\":\"M_BAD_JSON\",\"error\":\"Bad JSON\",\"retry_after_ms\":null},\"error\":null}"
        );
    }

    #[test]
    fn rejects_houra_error_as_matrix_error() {
        let envelope = parse_matrix_error_envelope_envelope(br#"{"code":"HOURA_BAD_REQUEST"}"#);

        assert!(!envelope.ok);
        assert!(envelope.value.is_none());
        let error = envelope
            .error
            .expect("missing errcode should return an error");
        assert_eq!(error.code, "missing_errcode");
    }

    #[test]
    fn serializes_matrix_foundation_validation_envelope() {
        let json = validate_matrix_foundation_identifiers_json(
            br##"{"user_id":"@alice:example.org","room_id":"!roomid:example.org","room_alias":"#general:example.org","event_id":"$eventid:example.org","server_name":"example.org","content_uri":"mxc://example.org/mediaid","event_type":"m.room.message","origin_server_ts":1710000000000}"##,
        );

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"valid\":true},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_foundation_values() {
        let envelope = validate_matrix_foundation_identifiers_envelope(
            br##"{"user_id":"alice","room_id":"!roomid:example.org","room_alias":"#general:example.org","event_id":"$eventid:example.org","server_name":"example.org","content_uri":"mxc://example.org/mediaid","event_type":"m.room.message","origin_server_ts":1710000000000}"##,
        );

        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("invalid user id should return an error");
        assert_eq!(error.code, "invalid_foundation_field");
        assert_eq!(error.details.get("field"), Some(&"user_id".to_owned()));
    }

    #[test]
    fn parses_matrix_auth_session_vectors() {
        let flows = read_spec_vector("test-vectors/auth/matrix-login-flows-basic.json");
        let parsed_flows =
            parse_matrix_login_flows(flows["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix login flows vector should parse");
        assert_eq!(parsed_flows.flows.len(), 1);
        assert_eq!(parsed_flows.flows[0].flow_type, "m.login.password");

        let login = read_spec_vector("test-vectors/auth/matrix-password-login-basic.json");
        let parsed_login =
            parse_matrix_login_session(login["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix login session vector should parse");
        assert_eq!(parsed_login.user_id, "@alice:example.test");
        assert_eq!(parsed_login.access_token, "token-1");
        assert_eq!(parsed_login.device_id.as_deref(), Some("DEVICE1"));
        assert_eq!(parsed_login.home_server.as_deref(), Some("example.test"));

        let whoami = read_spec_vector("test-vectors/auth/matrix-whoami-basic.json");
        let parsed_whoami =
            parse_matrix_whoami(whoami["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix whoami vector should parse");
        assert_eq!(parsed_whoami.user_id, "@alice:example.test");
        assert_eq!(parsed_whoami.device_id.as_deref(), Some("DEVICE1"));
        assert_eq!(parsed_whoami.is_guest, Some(false));
    }

    #[test]
    fn serializes_matrix_auth_parse_envelopes() {
        assert_eq!(
            parse_matrix_login_flows_json(br#"{"flows":[{"type":"m.login.password"}]}"#),
            "{\"ok\":true,\"value\":{\"flows\":[{\"type\":\"m.login.password\"}]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_login_session_json(
                br#"{"user_id":"@alice:example.test","access_token":"token-1","device_id":"DEVICE1","home_server":"example.test"}"#,
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@alice:example.test\",\"access_token\":\"token-1\",\"device_id\":\"DEVICE1\",\"home_server\":\"example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_whoami_json(
                br#"{"user_id":"@alice:example.test","device_id":"DEVICE1","is_guest":false}"#,
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"is_guest\":false},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_auth_values() {
        let envelope = parse_matrix_login_flows_envelope(br#"{"flows":[]}"#);
        assert!(!envelope.ok);
        assert_eq!(
            envelope.error.expect("empty flows should fail").code,
            "empty_flows"
        );

        let envelope = parse_matrix_login_session_envelope(br#"{"access_token":"token-1"}"#);
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("missing user_id should return an error");
        assert_eq!(error.code, "invalid_auth_field");
        assert_eq!(error.details.get("field"), Some(&"user_id".to_owned()));
    }

    #[test]
    fn parses_matrix_registration_vectors() {
        let availability =
            read_spec_vector("test-vectors/auth/matrix-registration-available-basic.json");
        let parsed_availability = parse_matrix_registration_availability(
            availability["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix registration availability vector should parse");
        assert!(parsed_availability.available);

        let registration = read_spec_vector("test-vectors/auth/matrix-registration-basic.json");
        let parsed_session = parse_matrix_registration_session(
            registration["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix registration session vector should parse");
        assert_eq!(parsed_session.user_id, "@charlie:example.test");
        assert_eq!(parsed_session.access_token, "token-register");
        assert_eq!(parsed_session.device_id.as_deref(), Some("DEVICE2"));
        assert_eq!(parsed_session.home_server.as_deref(), Some("example.test"));

        let uia = read_spec_vector("test-vectors/auth/matrix-registration-uia-required.json");
        let parsed_uia = parse_matrix_user_interactive_auth_required(
            uia["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix UIA required vector should parse");
        assert!(parsed_uia.completed.is_empty());
        assert_eq!(parsed_uia.flows[0].stages, vec!["m.login.dummy"]);
        assert!(parsed_uia.params.is_empty());
        assert_eq!(parsed_uia.session, "reg-session-1");

        let token =
            read_spec_vector("test-vectors/auth/matrix-registration-token-validity-basic.json");
        let parsed_token = parse_matrix_registration_token_validity(
            token["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix registration token validity vector should parse");
        assert!(parsed_token.valid);
    }

    #[test]
    fn serializes_matrix_registration_parse_envelopes() {
        assert_eq!(
            parse_matrix_registration_availability_json(br#"{"available":true}"#),
            "{\"ok\":true,\"value\":{\"available\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_registration_session_json(
                br#"{"user_id":"@charlie:example.test","access_token":"token-register","device_id":"DEVICE2","home_server":"example.test"}"#,
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@charlie:example.test\",\"access_token\":\"token-register\",\"device_id\":\"DEVICE2\",\"home_server\":\"example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_user_interactive_auth_required_json(
                br#"{"completed":[],"flows":[{"stages":["m.login.dummy"]}],"params":{},"session":"reg-session-1"}"#,
            ),
            "{\"ok\":true,\"value\":{\"completed\":[],\"flows\":[{\"stages\":[\"m.login.dummy\"]}],\"params\":{},\"session\":\"reg-session-1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_registration_token_validity_json(br#"{"valid":false}"#),
            "{\"ok\":true,\"value\":{\"valid\":false},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_registration_values() {
        let envelope = parse_matrix_registration_availability_envelope(br#"{}"#);
        assert!(!envelope.ok);
        assert_eq!(
            envelope
                .error
                .expect("missing availability should fail")
                .code,
            "invalid_registration_field"
        );

        let envelope = parse_matrix_user_interactive_auth_required_envelope(
            br#"{"completed":[],"flows":[],"params":{},"session":"reg-session-1"}"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("empty UIA flows should return an error");
        assert_eq!(error.code, "invalid_registration_field");
        assert_eq!(error.details.get("field"), Some(&"flows".to_owned()));

        let envelope = parse_matrix_registration_token_validity_envelope(br#"{}"#);
        assert!(!envelope.ok);
        assert_eq!(
            envelope
                .error
                .expect("missing token validity should fail")
                .code,
            "invalid_registration_field"
        );
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
