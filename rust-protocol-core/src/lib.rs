//! Shared Houra protocol parsing and validation helpers.
//!
//! This crate is a lab prototype for parser, checker, ABI, and artifact
//! manifest surfaces that can be checked against the canonical `houra-spec`
//! contracts and test vectors. It is not the canonical behavior source, not a
//! production client or server implementation, and not a Matrix compatibility
//! claim.
//!
//! Public APIs exposed here are intended for docs.rs review and thin binding
//! experiments only. Hosts remain responsible for HTTP transport, retry policy,
//! token storage, sync-token persistence, media storage, UI state, crypto, and
//! federation behavior.

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};
use serde_json::Value;

pub const HOURA_PROTOCOL_CORE_ABI_VERSION: u32 = 1;
pub const HOURA_PROTOCOL_CORE_MANIFEST_SCHEMA_VERSION: u32 = 1;
pub const HOURA_PROTOCOL_CORE_CRATE_NAME: &str = env!("CARGO_PKG_NAME");
pub const HOURA_PROTOCOL_CORE_CRATE_VERSION: &str = env!("CARGO_PKG_VERSION");
pub const MATRIX_CLIENT_VERSIONS_METHOD: &str = "GET";
pub const MATRIX_CLIENT_VERSIONS_PATH: &str = "/_matrix/client/versions";
const SUPPORTED_SPECS: &[&str] = &[
    "SPEC-030", "SPEC-031", "SPEC-032", "SPEC-033", "SPEC-034", "SPEC-035", "SPEC-036", "SPEC-037",
    "SPEC-038", "SPEC-039", "SPEC-040",
];

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
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
pub struct MatrixRegistrationSession {
    pub user_id: String,
    pub access_token: String,
    pub device_id: String,
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
    pub session: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixDevice {
    pub device_id: String,
    pub display_name: Option<String>,
    pub last_seen_ip: Option<String>,
    pub last_seen_ts: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixDevices {
    pub devices: Vec<MatrixDevice>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRoomIdResponse {
    pub room_id: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixEventIdResponse {
    pub event_id: String,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixClientEvent {
    pub content: BTreeMap<String, Value>,
    pub event_id: String,
    pub origin_server_ts: u64,
    pub room_id: String,
    pub sender: String,
    pub state_key: Option<String>,
    #[serde(rename = "type")]
    pub event_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub unsigned: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixRoomState {
    pub events: Vec<MatrixClientEvent>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixMessagesResponse {
    pub chunk: Vec<MatrixClientEvent>,
    pub start: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub end: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncEvent {
    pub content: BTreeMap<String, Value>,
    pub event_id: String,
    pub origin_server_ts: u64,
    pub sender: String,
    pub state_key: Option<String>,
    #[serde(rename = "type")]
    pub event_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub unsigned: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncBasicEvent {
    pub content: BTreeMap<String, Value>,
    #[serde(rename = "type")]
    pub event_type: String,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncBasicEventList {
    pub events: Vec<MatrixSyncBasicEvent>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncRoomEventList {
    pub events: Vec<MatrixSyncEvent>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncTimeline {
    pub events: Vec<MatrixSyncEvent>,
    pub limited: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub prev_batch: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncSummary {
    #[serde(
        rename = "m.joined_member_count",
        skip_serializing_if = "Option::is_none"
    )]
    pub joined_member_count: Option<u64>,
    #[serde(
        rename = "m.invited_member_count",
        skip_serializing_if = "Option::is_none"
    )]
    pub invited_member_count: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncUnreadNotifications {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub notification_count: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub highlight_count: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncJoinedRoom {
    pub state: MatrixSyncRoomEventList,
    pub timeline: MatrixSyncTimeline,
    pub account_data: MatrixSyncBasicEventList,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub summary: Option<MatrixSyncSummary>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub unread_notifications: Option<MatrixSyncUnreadNotifications>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncRooms {
    pub join: BTreeMap<String, MatrixSyncJoinedRoom>,
    pub invite: BTreeMap<String, Value>,
    pub leave: BTreeMap<String, Value>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncResponse {
    pub next_batch: String,
    pub account_data: MatrixSyncBasicEventList,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub presence: Option<MatrixSyncBasicEventList>,
    pub rooms: MatrixSyncRooms,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixMediaContentUri {
    pub server_name: String,
    pub media_id: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixMediaUploadResponse {
    pub content_uri: String,
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
pub struct MatrixRegistrationSessionParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixRegistrationSession>,
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

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixDeviceParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixDevice>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixDevicesParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixDevices>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixRoomIdResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixRoomIdResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixEventIdResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixEventIdResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixClientEventParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixClientEvent>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixRoomStateParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixRoomState>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixMessagesResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixMessagesResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixSyncResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixSyncResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixMediaContentUriParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixMediaContentUri>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixMediaUploadResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixMediaUploadResponse>,
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
    InvalidUserInteractiveAuthField { field: String },
    InvalidDeviceField { field: String },
    InvalidRoomField { field: String },
    InvalidMediaField { field: String },
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
            ProtocolError::InvalidUserInteractiveAuthField { .. } => {
                "invalid_user_interactive_auth_field"
            }
            ProtocolError::InvalidDeviceField { .. } => "invalid_device_field",
            ProtocolError::InvalidRoomField { .. } => "invalid_room_field",
            ProtocolError::InvalidMediaField { .. } => "invalid_media_field",
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
            ProtocolError::InvalidUserInteractiveAuthField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidDeviceField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidRoomField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidMediaField { field } => {
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
            ProtocolError::InvalidUserInteractiveAuthField { field } => {
                write!(
                    formatter,
                    "{field} is not a valid Matrix user-interactive authentication value"
                )
            }
            ProtocolError::InvalidDeviceField { field } => {
                write!(formatter, "{field} is not a valid Matrix device value")
            }
            ProtocolError::InvalidRoomField { field } => {
                write!(formatter, "{field} is not a valid Matrix room value")
            }
            ProtocolError::InvalidMediaField { field } => {
                write!(formatter, "{field} is not a valid Matrix media value")
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
    flows: Option<Vec<MatrixLoginFlowWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixLoginFlowWire {
    #[serde(rename = "type")]
    flow_type: Option<String>,
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

#[derive(Debug, Deserialize)]
struct MatrixDeviceWire {
    device_id: Option<String>,
    display_name: Option<String>,
    last_seen_ip: Option<String>,
    last_seen_ts: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct MatrixDevicesWire {
    devices: Option<Vec<MatrixDeviceWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixRoomIdResponseWire {
    room_id: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixEventIdResponseWire {
    event_id: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixClientEventWire {
    content: Option<BTreeMap<String, Value>>,
    event_id: Option<String>,
    origin_server_ts: Option<i64>,
    room_id: Option<String>,
    sender: Option<String>,
    state_key: Option<String>,
    #[serde(rename = "type")]
    event_type: Option<String>,
    unsigned: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Deserialize)]
struct MatrixMessagesResponseWire {
    chunk: Option<Vec<MatrixClientEventWire>>,
    start: Option<String>,
    end: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncResponseWire {
    next_batch: Option<String>,
    account_data: Option<MatrixSyncBasicEventListWire>,
    presence: Option<MatrixSyncBasicEventListWire>,
    rooms: Option<MatrixSyncRoomsWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncRoomsWire {
    join: Option<BTreeMap<String, MatrixSyncJoinedRoomWire>>,
    invite: Option<BTreeMap<String, Value>>,
    leave: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncJoinedRoomWire {
    state: Option<MatrixSyncRoomEventListWire>,
    timeline: Option<MatrixSyncTimelineWire>,
    account_data: Option<MatrixSyncBasicEventListWire>,
    summary: Option<MatrixSyncSummaryWire>,
    unread_notifications: Option<MatrixSyncUnreadNotificationsWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncRoomEventListWire {
    events: Option<Vec<MatrixSyncEventWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncBasicEventListWire {
    events: Option<Vec<MatrixSyncBasicEventWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncTimelineWire {
    events: Option<Vec<MatrixSyncEventWire>>,
    limited: Option<bool>,
    prev_batch: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncEventWire {
    content: Option<BTreeMap<String, Value>>,
    event_id: Option<String>,
    origin_server_ts: Option<i64>,
    sender: Option<String>,
    state_key: Option<String>,
    #[serde(rename = "type")]
    event_type: Option<String>,
    unsigned: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncBasicEventWire {
    content: Option<BTreeMap<String, Value>>,
    #[serde(rename = "type")]
    event_type: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncSummaryWire {
    #[serde(rename = "m.joined_member_count")]
    joined_member_count: Option<i64>,
    #[serde(rename = "m.invited_member_count")]
    invited_member_count: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct MatrixSyncUnreadNotificationsWire {
    notification_count: Option<i64>,
    highlight_count: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct MatrixMediaUploadResponseWire {
    content_uri: Option<String>,
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
    serde_json::to_string(&artifact_manifest_for_binding_kinds(binding_kinds)).unwrap_or_else(
        |error| {
            serde_json::json!({
                "error": "artifact manifest serialization failed",
                "message": error.to_string(),
            })
            .to_string()
        },
    )
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

    let flows_wire = wire.flows.ok_or(ProtocolError::EmptyFlows)?;
    if flows_wire.is_empty() {
        return Err(ProtocolError::EmptyFlows);
    }
    let mut flows = Vec::with_capacity(flows_wire.len());
    for (index, flow) in flows_wire.into_iter().enumerate() {
        let flow_type = flow
            .flow_type
            .ok_or(ProtocolError::EmptyFlowType { index })?;
        if flow_type.is_empty() {
            return Err(ProtocolError::EmptyFlowType { index });
        }
        flows.push(MatrixLoginFlow { flow_type });
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
) -> Result<MatrixRegistrationSession, ProtocolError> {
    let wire: MatrixLoginSessionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixRegistrationSession {
        user_id: required_registration_string(wire.user_id, "user_id")?,
        access_token: required_registration_string(wire.access_token, "access_token")?,
        device_id: required_registration_string(wire.device_id, "device_id")?,
        home_server: optional_registration_string(wire.home_server, "home_server")?,
    })
}

pub fn parse_matrix_registration_session_envelope(
    bytes: &[u8],
) -> MatrixRegistrationSessionParseEnvelope {
    match parse_matrix_registration_session(bytes) {
        Ok(value) => MatrixRegistrationSessionParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixRegistrationSessionParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_registration_session_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_registration_session_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
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
        return Err(invalid_user_interactive_auth_field("flows"));
    }

    let mut flows = Vec::with_capacity(wire.flows.len());
    for (index, flow) in wire.flows.into_iter().enumerate() {
        if flow.stages.is_empty() {
            return Err(invalid_user_interactive_auth_field(&format!(
                "flows.{index}.stages"
            )));
        }
        for (stage_index, stage) in flow.stages.iter().enumerate() {
            if stage.is_empty() {
                return Err(invalid_user_interactive_auth_field(&format!(
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
            return Err(invalid_user_interactive_auth_field(&format!(
                "completed.{index}"
            )));
        }
    }

    Ok(MatrixUserInteractiveAuthRequired {
        completed: wire.completed,
        flows,
        params: wire.params,
        session: optional_user_interactive_auth_string(wire.session, "session")?,
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

pub fn parse_matrix_device(bytes: &[u8]) -> Result<MatrixDevice, ProtocolError> {
    let wire: MatrixDeviceWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    matrix_device_from_wire(wire, "device")
}

pub fn parse_matrix_device_envelope(bytes: &[u8]) -> MatrixDeviceParseEnvelope {
    match parse_matrix_device(bytes) {
        Ok(value) => MatrixDeviceParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixDeviceParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_device_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_device_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_devices(bytes: &[u8]) -> Result<MatrixDevices, ProtocolError> {
    let wire: MatrixDevicesWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let devices = wire
        .devices
        .ok_or_else(|| invalid_device_field("devices"))?
        .into_iter()
        .enumerate()
        .map(|(index, device)| matrix_device_from_wire(device, &format!("devices.{index}")))
        .collect::<Result<Vec<_>, _>>()?;

    Ok(MatrixDevices { devices })
}

pub fn parse_matrix_devices_envelope(bytes: &[u8]) -> MatrixDevicesParseEnvelope {
    match parse_matrix_devices(bytes) {
        Ok(value) => MatrixDevicesParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixDevicesParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_devices_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_devices_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_room_id_response(bytes: &[u8]) -> Result<MatrixRoomIdResponse, ProtocolError> {
    let wire: MatrixRoomIdResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixRoomIdResponse {
        room_id: required_room_string(wire.room_id, "room_id")?,
    })
}

pub fn parse_matrix_room_id_response_envelope(bytes: &[u8]) -> MatrixRoomIdResponseParseEnvelope {
    match parse_matrix_room_id_response(bytes) {
        Ok(value) => MatrixRoomIdResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixRoomIdResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_room_id_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_room_id_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_event_id_response(
    bytes: &[u8],
) -> Result<MatrixEventIdResponse, ProtocolError> {
    let wire: MatrixEventIdResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixEventIdResponse {
        event_id: required_room_string(wire.event_id, "event_id")?,
    })
}

pub fn parse_matrix_event_id_response_envelope(bytes: &[u8]) -> MatrixEventIdResponseParseEnvelope {
    match parse_matrix_event_id_response(bytes) {
        Ok(value) => MatrixEventIdResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixEventIdResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_event_id_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_event_id_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_client_event(bytes: &[u8]) -> Result<MatrixClientEvent, ProtocolError> {
    let wire: MatrixClientEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    matrix_client_event_from_wire(wire, "event")
}

pub fn parse_matrix_client_event_envelope(bytes: &[u8]) -> MatrixClientEventParseEnvelope {
    match parse_matrix_client_event(bytes) {
        Ok(value) => MatrixClientEventParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixClientEventParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_client_event_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_client_event_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_room_state(bytes: &[u8]) -> Result<MatrixRoomState, ProtocolError> {
    let wires: Vec<MatrixClientEventWire> =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let events = wires
        .into_iter()
        .enumerate()
        .map(|(index, event)| matrix_client_event_from_wire(event, &format!("events.{index}")))
        .collect::<Result<Vec<_>, _>>()?;

    Ok(MatrixRoomState { events })
}

pub fn parse_matrix_room_state_envelope(bytes: &[u8]) -> MatrixRoomStateParseEnvelope {
    match parse_matrix_room_state(bytes) {
        Ok(value) => MatrixRoomStateParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixRoomStateParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_room_state_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_room_state_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_messages_response(
    bytes: &[u8],
) -> Result<MatrixMessagesResponse, ProtocolError> {
    let wire: MatrixMessagesResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let chunk = wire
        .chunk
        .ok_or_else(|| invalid_room_field("messages.chunk"))?
        .into_iter()
        .enumerate()
        .map(|(index, event)| {
            matrix_client_event_from_wire(event, &format!("messages.chunk.{index}"))
        })
        .collect::<Result<Vec<_>, _>>()?;

    Ok(MatrixMessagesResponse {
        chunk,
        start: required_room_string(wire.start, "messages.start")?,
        end: optional_room_string(wire.end, "messages.end")?,
    })
}

pub fn parse_matrix_messages_response_envelope(
    bytes: &[u8],
) -> MatrixMessagesResponseParseEnvelope {
    match parse_matrix_messages_response(bytes) {
        Ok(value) => MatrixMessagesResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixMessagesResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_messages_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_messages_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_sync_response(bytes: &[u8]) -> Result<MatrixSyncResponse, ProtocolError> {
    let wire: MatrixSyncResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let rooms = matrix_sync_rooms_from_wire(
        wire.rooms.ok_or_else(|| invalid_room_field("sync.rooms"))?,
        "sync.rooms",
    )?;

    Ok(MatrixSyncResponse {
        next_batch: required_room_string(wire.next_batch, "sync.next_batch")?,
        account_data: matrix_sync_basic_event_list_from_wire(
            wire.account_data
                .ok_or_else(|| invalid_room_field("sync.account_data"))?,
            "sync.account_data",
        )?,
        presence: wire
            .presence
            .map(|presence| matrix_sync_basic_event_list_from_wire(presence, "sync.presence"))
            .transpose()?,
        rooms,
    })
}

pub fn parse_matrix_sync_response_envelope(bytes: &[u8]) -> MatrixSyncResponseParseEnvelope {
    match parse_matrix_sync_response(bytes) {
        Ok(value) => MatrixSyncResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixSyncResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_sync_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_sync_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_media_content_uri(value: &str) -> Result<MatrixMediaContentUri, ProtocolError> {
    let Some(rest) = value.strip_prefix("mxc://") else {
        return Err(invalid_media_field("content_uri"));
    };
    let Some((server_name, media_id)) = rest.split_once('/') else {
        return Err(invalid_media_field("content_uri"));
    };
    if !is_matrix_server_name(server_name) || !is_opaque_part(media_id) {
        return Err(invalid_media_field("content_uri"));
    }

    Ok(MatrixMediaContentUri {
        server_name: server_name.to_owned(),
        media_id: media_id.to_owned(),
    })
}

pub fn parse_matrix_media_content_uri_envelope(value: &str) -> MatrixMediaContentUriParseEnvelope {
    match parse_matrix_media_content_uri(value) {
        Ok(value) => MatrixMediaContentUriParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixMediaContentUriParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_media_content_uri_json(value: &str) -> String {
    serde_json::to_string(&parse_matrix_media_content_uri_envelope(value))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_media_upload_response(
    bytes: &[u8],
) -> Result<MatrixMediaUploadResponse, ProtocolError> {
    let wire: MatrixMediaUploadResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let content_uri = required_media_content_uri(wire.content_uri, "content_uri")?;

    Ok(MatrixMediaUploadResponse { content_uri })
}

pub fn parse_matrix_media_upload_response_envelope(
    bytes: &[u8],
) -> MatrixMediaUploadResponseParseEnvelope {
    match parse_matrix_media_upload_response(bytes) {
        Ok(value) => MatrixMediaUploadResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixMediaUploadResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_media_upload_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_media_upload_response_envelope(bytes))
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

fn optional_registration_string(
    value: Option<String>,
    field: &str,
) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if value.is_empty() => Err(invalid_registration_field(field)),
        value => Ok(value),
    }
}

fn invalid_registration_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidRegistrationField {
        field: field.to_owned(),
    }
}

fn optional_user_interactive_auth_string(
    value: Option<String>,
    field: &str,
) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if value.is_empty() => Err(invalid_user_interactive_auth_field(field)),
        value => Ok(value),
    }
}

fn invalid_user_interactive_auth_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidUserInteractiveAuthField {
        field: field.to_owned(),
    }
}

fn matrix_device_from_wire(
    wire: MatrixDeviceWire,
    context: &str,
) -> Result<MatrixDevice, ProtocolError> {
    let device_id = wire
        .device_id
        .filter(|device_id| !device_id.is_empty())
        .ok_or_else(|| invalid_device_field(&format!("{context}.device_id")))?;
    let last_seen_ts = match wire.last_seen_ts {
        Some(timestamp) if timestamp < 0 => {
            return Err(invalid_device_field(&format!("{context}.last_seen_ts")));
        }
        Some(timestamp) => Some(timestamp as u64),
        None => None,
    };

    Ok(MatrixDevice {
        device_id,
        display_name: wire.display_name,
        last_seen_ip: wire.last_seen_ip,
        last_seen_ts,
    })
}

fn invalid_device_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidDeviceField {
        field: field.to_owned(),
    }
}

fn required_room_string(value: Option<String>, field: &str) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_room_field(field)),
    }
}

fn optional_room_string(
    value: Option<String>,
    field: &str,
) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if value.is_empty() => Err(invalid_room_field(field)),
        other => Ok(other),
    }
}

fn matrix_client_event_from_wire(
    wire: MatrixClientEventWire,
    context: &str,
) -> Result<MatrixClientEvent, ProtocolError> {
    let origin_server_ts = match wire.origin_server_ts {
        Some(timestamp) if timestamp >= 0 => timestamp as u64,
        _ => return Err(invalid_room_field(&format!("{context}.origin_server_ts"))),
    };

    Ok(MatrixClientEvent {
        content: wire
            .content
            .ok_or_else(|| invalid_room_field(&format!("{context}.content")))?,
        event_id: required_room_string(wire.event_id, &format!("{context}.event_id"))?,
        origin_server_ts,
        room_id: required_room_string(wire.room_id, &format!("{context}.room_id"))?,
        sender: required_room_string(wire.sender, &format!("{context}.sender"))?,
        state_key: wire.state_key,
        event_type: required_room_string(wire.event_type, &format!("{context}.type"))?,
        unsigned: wire.unsigned,
    })
}

fn matrix_sync_rooms_from_wire(
    wire: MatrixSyncRoomsWire,
    context: &str,
) -> Result<MatrixSyncRooms, ProtocolError> {
    let join = wire
        .join
        .ok_or_else(|| invalid_room_field(&format!("{context}.join")))?
        .into_iter()
        .map(|(room_id, room)| {
            let parsed =
                matrix_sync_joined_room_from_wire(room, &format!("{context}.join.{room_id}"))?;
            Ok((room_id, parsed))
        })
        .collect::<Result<BTreeMap<_, _>, ProtocolError>>()?;

    Ok(MatrixSyncRooms {
        join,
        invite: wire
            .invite
            .ok_or_else(|| invalid_room_field(&format!("{context}.invite")))?,
        leave: wire
            .leave
            .ok_or_else(|| invalid_room_field(&format!("{context}.leave")))?,
    })
}

fn matrix_sync_joined_room_from_wire(
    wire: MatrixSyncJoinedRoomWire,
    context: &str,
) -> Result<MatrixSyncJoinedRoom, ProtocolError> {
    Ok(MatrixSyncJoinedRoom {
        state: matrix_sync_room_event_list_from_wire(
            wire.state
                .ok_or_else(|| invalid_room_field(&format!("{context}.state")))?,
            &format!("{context}.state"),
        )?,
        timeline: matrix_sync_timeline_from_wire(
            wire.timeline
                .ok_or_else(|| invalid_room_field(&format!("{context}.timeline")))?,
            &format!("{context}.timeline"),
        )?,
        account_data: matrix_sync_basic_event_list_from_wire(
            wire.account_data
                .ok_or_else(|| invalid_room_field(&format!("{context}.account_data")))?,
            &format!("{context}.account_data"),
        )?,
        summary: wire
            .summary
            .map(|summary| matrix_sync_summary_from_wire(summary, &format!("{context}.summary")))
            .transpose()?,
        unread_notifications: wire
            .unread_notifications
            .map(|unread| {
                matrix_sync_unread_notifications_from_wire(
                    unread,
                    &format!("{context}.unread_notifications"),
                )
            })
            .transpose()?,
    })
}

fn matrix_sync_room_event_list_from_wire(
    wire: MatrixSyncRoomEventListWire,
    context: &str,
) -> Result<MatrixSyncRoomEventList, ProtocolError> {
    let events = wire
        .events
        .ok_or_else(|| invalid_room_field(&format!("{context}.events")))?
        .into_iter()
        .enumerate()
        .map(|(index, event)| {
            matrix_sync_event_from_wire(event, &format!("{context}.events.{index}"))
        })
        .collect::<Result<Vec<_>, _>>()?;
    Ok(MatrixSyncRoomEventList { events })
}

fn matrix_sync_basic_event_list_from_wire(
    wire: MatrixSyncBasicEventListWire,
    context: &str,
) -> Result<MatrixSyncBasicEventList, ProtocolError> {
    let events = wire
        .events
        .ok_or_else(|| invalid_room_field(&format!("{context}.events")))?
        .into_iter()
        .enumerate()
        .map(|(index, event)| {
            matrix_sync_basic_event_from_wire(event, &format!("{context}.events.{index}"))
        })
        .collect::<Result<Vec<_>, _>>()?;
    Ok(MatrixSyncBasicEventList { events })
}

fn matrix_sync_timeline_from_wire(
    wire: MatrixSyncTimelineWire,
    context: &str,
) -> Result<MatrixSyncTimeline, ProtocolError> {
    let events = wire
        .events
        .ok_or_else(|| invalid_room_field(&format!("{context}.events")))?
        .into_iter()
        .enumerate()
        .map(|(index, event)| {
            matrix_sync_event_from_wire(event, &format!("{context}.events.{index}"))
        })
        .collect::<Result<Vec<_>, _>>()?;

    Ok(MatrixSyncTimeline {
        events,
        limited: wire
            .limited
            .ok_or_else(|| invalid_room_field(&format!("{context}.limited")))?,
        prev_batch: optional_room_string(wire.prev_batch, &format!("{context}.prev_batch"))?,
    })
}

fn matrix_sync_event_from_wire(
    wire: MatrixSyncEventWire,
    context: &str,
) -> Result<MatrixSyncEvent, ProtocolError> {
    let origin_server_ts = match wire.origin_server_ts {
        Some(timestamp) if timestamp >= 0 => timestamp as u64,
        _ => return Err(invalid_room_field(&format!("{context}.origin_server_ts"))),
    };

    Ok(MatrixSyncEvent {
        content: wire
            .content
            .ok_or_else(|| invalid_room_field(&format!("{context}.content")))?,
        event_id: required_room_string(wire.event_id, &format!("{context}.event_id"))?,
        origin_server_ts,
        sender: required_room_string(wire.sender, &format!("{context}.sender"))?,
        state_key: wire.state_key,
        event_type: required_room_string(wire.event_type, &format!("{context}.type"))?,
        unsigned: wire.unsigned,
    })
}

fn matrix_sync_basic_event_from_wire(
    wire: MatrixSyncBasicEventWire,
    context: &str,
) -> Result<MatrixSyncBasicEvent, ProtocolError> {
    Ok(MatrixSyncBasicEvent {
        content: wire
            .content
            .ok_or_else(|| invalid_room_field(&format!("{context}.content")))?,
        event_type: required_room_string(wire.event_type, &format!("{context}.type"))?,
    })
}

fn matrix_sync_summary_from_wire(
    wire: MatrixSyncSummaryWire,
    context: &str,
) -> Result<MatrixSyncSummary, ProtocolError> {
    Ok(MatrixSyncSummary {
        joined_member_count: optional_non_negative_i64(
            wire.joined_member_count,
            &format!("{context}.m.joined_member_count"),
        )?,
        invited_member_count: optional_non_negative_i64(
            wire.invited_member_count,
            &format!("{context}.m.invited_member_count"),
        )?,
    })
}

fn matrix_sync_unread_notifications_from_wire(
    wire: MatrixSyncUnreadNotificationsWire,
    context: &str,
) -> Result<MatrixSyncUnreadNotifications, ProtocolError> {
    Ok(MatrixSyncUnreadNotifications {
        notification_count: optional_non_negative_i64(
            wire.notification_count,
            &format!("{context}.notification_count"),
        )?,
        highlight_count: optional_non_negative_i64(
            wire.highlight_count,
            &format!("{context}.highlight_count"),
        )?,
    })
}

fn optional_non_negative_i64(
    value: Option<i64>,
    field: &str,
) -> Result<Option<u64>, ProtocolError> {
    match value {
        Some(value) if value >= 0 => Ok(Some(value as u64)),
        Some(_) => Err(invalid_room_field(field)),
        None => Ok(None),
    }
}

fn invalid_room_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidRoomField {
        field: field.to_owned(),
    }
}

fn invalid_media_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidMediaField {
        field: field.to_owned(),
    }
}

fn required_media_content_uri(value: Option<String>, field: &str) -> Result<String, ProtocolError> {
    match value {
        Some(value) if parse_matrix_media_content_uri(&value).is_ok() => Ok(value),
        _ => Err(invalid_media_field(field)),
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
            vec![
                "SPEC-030", "SPEC-031", "SPEC-032", "SPEC-033", "SPEC-034", "SPEC-035", "SPEC-036",
                "SPEC-037", "SPEC-038", "SPEC-039", "SPEC-040"
            ]
        );
        assert!(manifest.supported_binding_kinds.is_empty());
    }

    #[test]
    fn serializes_artifact_manifest_stably() {
        let json = artifact_manifest_json();
        let manifest: ArtifactManifest =
            serde_json::from_str(&json).expect("manifest JSON should parse");

        assert_eq!(manifest, artifact_manifest());
        assert!(manifest.supported_binding_kinds.is_empty());
    }

    #[test]
    fn serializes_artifact_manifest_with_binding_kinds() {
        let json = artifact_manifest_json_for_binding_kinds(&["wasm"]);
        let manifest: ArtifactManifest =
            serde_json::from_str(&json).expect("manifest JSON should parse");

        assert_eq!(manifest, artifact_manifest_for_binding_kinds(&["wasm"]));
    }

    #[test]
    fn exposes_spec_039_integration_gate_coverage() {
        let gate_name = ["matrix", "client", "server", "mvp", "live", "e2e", "gate"].join("-");
        let vector = read_spec_vector(&format!("test-vectors/core/{gate_name}.json"));
        assert_eq!(vector["contract"], "SPEC-039");
        assert_eq!(
            vector["event"]["gate"],
            ["matrix", "client", "server", "mvp", "live", "e2e"].join("-")
        );
        assert_eq!(vector["event"]["matrix_spec_version"], "v1.18");

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(
            manifest
                .supported_specs
                .iter()
                .any(|spec| spec == "SPEC-039"),
            "manifest should mark the SPEC-039 integration gate as covered"
        );
        for contract in vector["event"]["required_contracts"]
            .as_array()
            .expect("SPEC-039 vector should list required contracts")
        {
            let contract = contract
                .as_str()
                .expect("required contract ids should be strings");
            assert!(
                manifest.supported_specs.iter().any(|spec| spec == contract),
                "manifest should include required contract {contract}"
            );
        }
        assert_eq!(
            vector["event"]["conditional_repositories"]
                .as_array()
                .expect("SPEC-039 vector should list conditional repositories")
                .iter()
                .filter_map(Value::as_str)
                .collect::<Vec<_>>(),
            vec!["houra-labs"]
        );

        let scenario_steps = vector["event"]["scenario_steps"]
            .as_array()
            .expect("SPEC-039 vector should list scenario steps");
        assert_eq!(scenario_steps.len(), 12);
        for step in scenario_steps {
            let contract = step["contract"]
                .as_str()
                .expect("scenario step should cite a contract");
            assert!(
                manifest.supported_specs.iter().any(|spec| spec == contract),
                "scenario step contract {contract} should be covered"
            );
            for vector_path in step["vectors"]
                .as_array()
                .expect("scenario step should cite canonical vectors")
            {
                read_spec_vector(
                    vector_path
                        .as_str()
                        .expect("scenario vector path should be a string"),
                );
            }
        }
    }

    #[test]
    fn exposes_spec_040_event_dag_auth_event_vector_coverage() {
        let valid = read_spec_vector("test-vectors/events/matrix-event-dag-auth-events-basic.json");
        let invalid =
            read_spec_vector("test-vectors/events/matrix-event-dag-auth-events-invalid.json");
        assert_eq!(valid["contract"], "SPEC-040");
        assert_eq!(invalid["contract"], "SPEC-040");
        assert_eq!(valid["event"]["matrix_spec_version"], "v1.18");
        assert_eq!(valid["event"]["room_version"], "12");
        assert_eq!(invalid["event"]["matrix_spec_version"], "v1.18");

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(
            manifest
                .supported_specs
                .iter()
                .any(|spec| spec == "SPEC-040"),
            "manifest should mark the SPEC-040 event DAG/auth event vectors as covered"
        );

        let events = valid["event"]["events"]
            .as_array()
            .expect("SPEC-040 valid vector should list events");
        assert_eq!(events.len(), 3);
        assert_eq!(
            valid["expected"]["candidate_event_id"],
            valid["event"]["candidate_event_id"]
        );
        assert_eq!(
            valid["expected"]["candidate_prev_events"],
            serde_json::json!(["$memberAlice000000000000000000000000000000000001"])
        );
        assert_eq!(
            valid["expected"]["candidate_auth_events"],
            serde_json::json!(["$memberAlice000000000000000000000000000000000001"])
        );

        let invalid_cases = invalid["event"]["invalid_cases"]
            .as_array()
            .expect("SPEC-040 invalid vector should list invalid cases");
        assert_eq!(
            invalid_cases.len(),
            invalid["expected"]["invalid_case_count"]
                .as_u64()
                .expect("invalid_case_count should be an integer") as usize
        );
        assert_eq!(invalid["expected"]["error"], "M_INVALID_PARAM");
        assert_eq!(
            invalid_cases
                .iter()
                .map(|case| case["expected_violation"]
                    .as_str()
                    .expect("invalid case should cite expected_violation"))
                .collect::<Vec<_>>(),
            vec![
                "missing_prev_event",
                "duplicate_auth_event",
                "self_prev_event",
                "auth_create_event_v12",
                "prev_event_cycle",
                "duplicate_auth_state_key",
            ]
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
        let expected_login = &login["expected"]["body_contains"];
        assert_eq!(
            Some(parsed_login.user_id.as_str()),
            expected_login.get("user_id").and_then(Value::as_str)
        );
        assert_eq!(
            Some(parsed_login.access_token.as_str()),
            expected_login.get("access_token").and_then(Value::as_str)
        );
        assert_eq!(
            parsed_login.device_id.as_deref(),
            expected_login.get("device_id").and_then(Value::as_str)
        );
        assert_eq!(
            parsed_login.home_server.as_deref(),
            expected_login.get("home_server").and_then(Value::as_str)
        );

        let whoami = read_spec_vector("test-vectors/auth/matrix-whoami-basic.json");
        let parsed_whoami =
            parse_matrix_whoami(whoami["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix whoami vector should parse");
        let expected_whoami = &whoami["expected"]["body_contains"];
        assert_eq!(
            Some(parsed_whoami.user_id.as_str()),
            expected_whoami.get("user_id").and_then(Value::as_str)
        );
        assert_eq!(
            parsed_whoami.device_id.as_deref(),
            expected_whoami.get("device_id").and_then(Value::as_str)
        );
        assert_eq!(
            parsed_whoami.is_guest,
            expected_whoami.get("is_guest").and_then(Value::as_bool)
        );
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
        assert_eq!(parsed_session.device_id, "DEVICE2");
        assert_eq!(parsed_session.home_server.as_deref(), Some("example.test"));

        let uia = read_spec_vector("test-vectors/auth/matrix-registration-uia-required.json");
        let parsed_uia = parse_matrix_user_interactive_auth_required(
            uia["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix UIA required vector should parse");
        assert!(parsed_uia.completed.is_empty());
        assert_eq!(parsed_uia.flows[0].stages, vec!["m.login.dummy"]);
        assert!(parsed_uia.params.is_empty());
        assert_eq!(parsed_uia.session.as_deref(), Some("reg-session-1"));

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
            parse_matrix_user_interactive_auth_required_json(
                br#"{"completed":[],"flows":[{"stages":["m.login.dummy"]}],"params":{}}"#,
            ),
            "{\"ok\":true,\"value\":{\"completed\":[],\"flows\":[{\"stages\":[\"m.login.dummy\"]}],\"params\":{},\"session\":null},\"error\":null}"
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
        assert_eq!(error.code, "invalid_user_interactive_auth_field");
        assert_eq!(error.details.get("field"), Some(&"flows".to_owned()));

        let envelope = parse_matrix_user_interactive_auth_required_envelope(
            br#"{"completed":[],"flows":[{"stages":["m.login.dummy"]}],"params":{},"session":""}"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("empty UIA session should return an error");
        assert_eq!(error.code, "invalid_user_interactive_auth_field");
        assert_eq!(error.details.get("field"), Some(&"session".to_owned()));

        let envelope = parse_matrix_registration_session_envelope(
            br#"{"user_id":"@charlie:example.test","access_token":"token-register"}"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("missing registration device_id should return an error");
        assert_eq!(error.code, "invalid_registration_field");
        assert_eq!(error.details.get("field"), Some(&"device_id".to_owned()));

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

    #[test]
    fn parses_matrix_device_vectors() {
        let detail = read_spec_vector("test-vectors/auth/matrix-device-detail-basic.json");
        let parsed_device =
            parse_matrix_device(detail["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix device detail vector should parse");
        assert_eq!(parsed_device.device_id, "DEVICE1");
        assert_eq!(parsed_device.display_name.as_deref(), Some("Alice phone"));
        assert_eq!(parsed_device.last_seen_ip.as_deref(), Some("203.0.113.10"));
        assert_eq!(parsed_device.last_seen_ts, Some(1_710_000_000_000));

        let list = read_spec_vector("test-vectors/auth/matrix-devices-list-basic.json");
        let parsed_devices =
            parse_matrix_devices(list["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix devices list vector should parse");
        assert_eq!(parsed_devices.devices.len(), 1);
        assert_eq!(parsed_devices.devices[0].device_id, "DEVICE1");

        let delete_uia =
            read_spec_vector("test-vectors/auth/matrix-device-delete-uia-required.json");
        let parsed_delete_uia = parse_matrix_user_interactive_auth_required(
            delete_uia["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix device delete UIA vector should parse");
        assert_eq!(parsed_delete_uia.flows[0].stages, vec!["m.login.password"]);
        assert_eq!(
            parsed_delete_uia.session.as_deref(),
            Some("device-del-session-1")
        );

        let bulk_delete_uia =
            read_spec_vector("test-vectors/auth/matrix-devices-delete-bulk-uia-required.json");
        let parsed_bulk_delete_uia = parse_matrix_user_interactive_auth_required(
            bulk_delete_uia["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix bulk device delete UIA vector should parse");
        assert_eq!(
            parsed_bulk_delete_uia.session.as_deref(),
            Some("device-del-session-1")
        );

        for relative_path in [
            "test-vectors/auth/matrix-devices-missing-token.json",
            "test-vectors/auth/matrix-device-token-invalid-after-delete.json",
            "test-vectors/auth/matrix-device-detail-not-found.json",
            "test-vectors/auth/matrix-device-update-not-found.json",
        ] {
            let vector = read_spec_vector(relative_path);
            parse_matrix_error_envelope(vector["expected"]["body_contains"].to_string().as_bytes())
                .unwrap_or_else(|error| panic!("{relative_path} should parse: {error}"));
        }
    }

    #[test]
    fn serializes_matrix_device_parse_envelopes() {
        assert_eq!(
            parse_matrix_device_json(
                br#"{"device_id":"DEVICE1","display_name":"Alice phone","last_seen_ip":"203.0.113.10","last_seen_ts":1710000000000}"#,
            ),
            "{\"ok\":true,\"value\":{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_devices_json(
                br#"{"devices":[{"device_id":"DEVICE1","display_name":"Alice phone","last_seen_ip":"203.0.113.10","last_seen_ts":1710000000000}]}"#,
            ),
            "{\"ok\":true,\"value\":{\"devices\":[{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000}]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_devices_json(br#"{"devices":[]}"#),
            "{\"ok\":true,\"value\":{\"devices\":[]},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_device_values() {
        let envelope = parse_matrix_device_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing device_id should fail");
        assert_eq!(error.code, "invalid_device_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"device.device_id".to_owned())
        );

        let envelope = parse_matrix_devices_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing devices should fail");
        assert_eq!(error.code, "invalid_device_field");
        assert_eq!(error.details.get("field"), Some(&"devices".to_owned()));

        let envelope =
            parse_matrix_device_envelope(br#"{"device_id":"DEVICE1","last_seen_ts":-1}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("negative last_seen_ts should fail");
        assert_eq!(error.code, "invalid_device_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"device.last_seen_ts".to_owned())
        );
    }

    #[test]
    fn parses_matrix_room_vectors() {
        let create = read_spec_vector("test-vectors/rooms/matrix-create-room-basic.json");
        let parsed_create = parse_matrix_room_id_response(
            create["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix create room vector should parse");
        assert_eq!(parsed_create.room_id, "!room:example.test");

        let join = read_spec_vector("test-vectors/rooms/matrix-join-room-basic.json");
        let parsed_join =
            parse_matrix_room_id_response(join["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix join room vector should parse");
        assert_eq!(parsed_join.room_id, "!room:example.test");

        let state = read_spec_vector("test-vectors/rooms/matrix-room-state-basic.json");
        let parsed_state =
            parse_matrix_room_state(state["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix room state vector should parse");
        assert_eq!(parsed_state.events.len(), 2);
        assert_eq!(parsed_state.events[0].event_id, "$name:example.test");
        assert_eq!(parsed_state.events[0].event_type, "m.room.name");
        assert_eq!(parsed_state.events[0].state_key.as_deref(), Some(""));
        assert_eq!(parsed_state.events[0].content["name"], "General");
        assert_eq!(parsed_state.events[1].event_type, "m.room.member");
        assert_eq!(
            parsed_state.events[1].state_key.as_deref(),
            Some("@alice:example.test")
        );

        let forbidden = read_spec_vector("test-vectors/rooms/matrix-room-state-forbidden.json");
        parse_matrix_error_envelope(
            forbidden["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix room state forbidden error should parse");
    }

    #[test]
    fn serializes_matrix_room_parse_envelopes() {
        assert_eq!(
            parse_matrix_room_id_response_json(br#"{"room_id":"!room:example.test"}"#),
            "{\"ok\":true,\"value\":{\"room_id\":\"!room:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_client_event_json(
                br#"{"event_id":"$name:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":1710000000000,"type":"m.room.name","state_key":"","content":{"name":"General"}}"#,
            ),
            "{\"ok\":true,\"value\":{\"content\":{\"name\":\"General\"},\"event_id\":\"$name:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":\"\",\"type\":\"m.room.name\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_state_json(
                br#"[{"event_id":"$name:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":1710000000000,"type":"m.room.name","state_key":"","content":{"name":"General"}}]"#,
            ),
            "{\"ok\":true,\"value\":{\"events\":[{\"content\":{\"name\":\"General\"},\"event_id\":\"$name:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":\"\",\"type\":\"m.room.name\"}]},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_room_values() {
        let envelope = parse_matrix_room_id_response_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing room_id should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(error.details.get("field"), Some(&"room_id".to_owned()));

        let envelope = parse_matrix_client_event_envelope(
            br#"{"event_id":"$name:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":1710000000000,"type":"m.room.name"}"#,
        );
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing event content should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"event.content".to_owned())
        );

        let envelope = parse_matrix_room_state_envelope(
            br#"[{"event_id":"$name:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":-1,"type":"m.room.name","state_key":"","content":{"name":"General"}}]"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("negative origin_server_ts should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"events.0.origin_server_ts".to_owned())
        );
    }

    #[test]
    fn parses_matrix_messaging_vectors() {
        let send = read_spec_vector("test-vectors/messaging/matrix-send-event-text-basic.json");
        let parsed_send = parse_matrix_event_id_response(
            send["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix send event vector should parse");
        assert_eq!(parsed_send.event_id, "$event1:example.test");

        let messages = read_spec_vector("test-vectors/messaging/matrix-messages-basic.json");
        let parsed_messages = parse_matrix_messages_response(
            messages["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix messages vector should parse");
        assert_eq!(parsed_messages.chunk.len(), 1);
        assert_eq!(parsed_messages.chunk[0].event_id, "$event1:example.test");
        assert_eq!(parsed_messages.chunk[0].event_type, "m.room.message");
        assert_eq!(parsed_messages.chunk[0].content["body"], "Hello Matrix");
        if let Some(unsigned) = &parsed_messages.chunk[0].unsigned {
            assert_eq!(unsigned["transaction_id"], "txn-1");
        }
        assert_eq!(parsed_messages.start, "t1");
        assert_eq!(parsed_messages.end.as_deref(), Some("t0"));

        let next_page = read_spec_vector("test-vectors/messaging/matrix-messages-next-page.json");
        let parsed_next_page = parse_matrix_messages_response(
            next_page["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix messages next page vector should parse");
        assert_eq!(parsed_next_page.chunk[0].event_id, "$event0:example.test");
        assert_eq!(parsed_next_page.start, "t0");
        assert!(parsed_next_page.end.is_none());

        for path in [
            "test-vectors/messaging/matrix-send-event-malformed-payload.json",
            "test-vectors/messaging/matrix-send-event-missing-token.json",
            "test-vectors/messaging/matrix-messages-forbidden.json",
            "test-vectors/messaging/matrix-messages-invalid-dir.json",
        ] {
            let vector = read_spec_vector(path);
            parse_matrix_error_envelope(vector["expected"]["body_contains"].to_string().as_bytes())
                .unwrap_or_else(|error| panic!("{path} should parse as Matrix error: {error:?}"));
        }
    }

    #[test]
    fn serializes_matrix_messaging_parse_envelopes() {
        assert_eq!(
            parse_matrix_event_id_response_json(br#"{"event_id":"$event1:example.test"}"#),
            "{\"ok\":true,\"value\":{\"event_id\":\"$event1:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_messages_response_json(
                br#"{"chunk":[{"event_id":"$event1:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":1710000000000,"type":"m.room.message","content":{"msgtype":"m.text","body":"Hello Matrix"},"unsigned":{"transaction_id":"txn-1"}}],"start":"t1","end":"t0"}"#,
            ),
            "{\"ok\":true,\"value\":{\"chunk\":[{\"content\":{\"body\":\"Hello Matrix\",\"msgtype\":\"m.text\"},\"event_id\":\"$event1:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":null,\"type\":\"m.room.message\",\"unsigned\":{\"transaction_id\":\"txn-1\"}}],\"start\":\"t1\",\"end\":\"t0\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_messages_response_json(
                br#"{"chunk":[{"event_id":"$event0:example.test","room_id":"!room:example.test","sender":"@bob:example.test","origin_server_ts":1709999999000,"type":"m.room.message","content":{"msgtype":"m.text","body":"Earlier message"}}],"start":"t0"}"#,
            ),
            "{\"ok\":true,\"value\":{\"chunk\":[{\"content\":{\"body\":\"Earlier message\",\"msgtype\":\"m.text\"},\"event_id\":\"$event0:example.test\",\"origin_server_ts\":1709999999000,\"room_id\":\"!room:example.test\",\"sender\":\"@bob:example.test\",\"state_key\":null,\"type\":\"m.room.message\"}],\"start\":\"t0\"},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_messaging_values() {
        let envelope = parse_matrix_event_id_response_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing event_id should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(error.details.get("field"), Some(&"event_id".to_owned()));

        let envelope = parse_matrix_messages_response_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing chunk should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"messages.chunk".to_owned())
        );

        let envelope = parse_matrix_messages_response_envelope(
            br#"{"chunk":[{"event_id":"$event1:example.test","room_id":"!room:example.test","sender":"@alice:example.test","origin_server_ts":-1,"type":"m.room.message","content":{"msgtype":"m.text","body":"Hello Matrix"}}],"start":"t1"}"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("negative origin_server_ts should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(
            error.details.get("field"),
            Some(&"messages.chunk.0.origin_server_ts".to_owned())
        );
    }

    #[test]
    fn parses_matrix_sync_vectors() {
        let initial = read_spec_vector("test-vectors/sync/matrix-sync-initial-basic.json");
        let parsed_initial =
            parse_matrix_sync_response(initial["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix initial sync vector should parse");
        assert_eq!(parsed_initial.next_batch, "s1");
        let room = parsed_initial
            .rooms
            .join
            .get("!room:example.test")
            .expect("joined room should parse");
        assert_eq!(room.state.events.len(), 2);
        assert_eq!(room.timeline.events[0].event_id, "$event1:example.test");
        assert_eq!(room.timeline.events[0].event_type, "m.room.message");
        assert_eq!(room.timeline.events[0].content["body"], "Hello Matrix");
        assert_eq!(room.timeline.prev_batch.as_deref(), Some("t0"));
        assert!(!room.timeline.limited);
        assert_eq!(room.account_data.events[0].event_type, "m.tag");
        assert_eq!(
            room.summary
                .as_ref()
                .expect("summary should parse")
                .joined_member_count,
            Some(1)
        );
        assert_eq!(
            room.unread_notifications
                .as_ref()
                .expect("unread notifications should parse")
                .notification_count,
            Some(0)
        );

        let incremental = read_spec_vector("test-vectors/sync/matrix-sync-incremental-basic.json");
        let parsed_incremental = parse_matrix_sync_response(
            incremental["expected"]["body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("Matrix incremental sync vector should parse");
        let room = parsed_incremental
            .rooms
            .join
            .get("!room:example.test")
            .expect("joined room should parse");
        assert!(room.state.events.is_empty());
        assert_eq!(room.timeline.events[0].event_id, "$event2:example.test");

        let empty = read_spec_vector("test-vectors/sync/matrix-sync-empty-incremental.json");
        let parsed_empty =
            parse_matrix_sync_response(empty["expected"]["body_contains"].to_string().as_bytes())
                .expect("Matrix empty sync vector should parse");
        assert_eq!(parsed_empty.next_batch, "s2");
        assert!(parsed_empty.rooms.join.is_empty());
        if let Some(presence) = &parsed_empty.presence {
            assert!(presence.events.is_empty());
        }

        for path in [
            "test-vectors/sync/matrix-sync-invalid-since.json",
            "test-vectors/sync/matrix-sync-missing-token.json",
            "test-vectors/sync/matrix-sync-invalid-token.json",
        ] {
            let vector = read_spec_vector(path);
            parse_matrix_error_envelope(vector["expected"]["body_contains"].to_string().as_bytes())
                .unwrap_or_else(|error| panic!("{path} should parse as Matrix error: {error:?}"));
        }
    }

    #[test]
    fn serializes_matrix_sync_parse_envelopes() {
        assert_eq!(
            parse_matrix_sync_response_json(
                br#"{"next_batch":"s1","account_data":{"events":[]},"rooms":{"join":{"!room:example.test":{"state":{"events":[]},"timeline":{"events":[{"event_id":"$event1:example.test","sender":"@alice:example.test","origin_server_ts":1710000000000,"type":"m.room.message","content":{"msgtype":"m.text","body":"Hello Matrix"}}],"limited":false,"prev_batch":"t0"},"account_data":{"events":[]}}},"invite":{},"leave":{}}}"#,
            ),
            "{\"ok\":true,\"value\":{\"next_batch\":\"s1\",\"account_data\":{\"events\":[]},\"rooms\":{\"join\":{\"!room:example.test\":{\"state\":{\"events\":[]},\"timeline\":{\"events\":[{\"content\":{\"body\":\"Hello Matrix\",\"msgtype\":\"m.text\"},\"event_id\":\"$event1:example.test\",\"origin_server_ts\":1710000000000,\"sender\":\"@alice:example.test\",\"state_key\":null,\"type\":\"m.room.message\"}],\"limited\":false,\"prev_batch\":\"t0\"},\"account_data\":{\"events\":[]}}},\"invite\":{},\"leave\":{}}},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_sync_values() {
        let envelope = parse_matrix_sync_response_envelope(br#"{}"#);
        assert!(!envelope.ok);
        let error = envelope.error.expect("missing sync.rooms should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(error.details.get("field"), Some(&"sync.rooms".to_owned()));

        let envelope = parse_matrix_sync_response_envelope(
            br#"{"next_batch":"s1","account_data":{"events":[]},"rooms":{"join":{"!room:example.test":{"state":{"events":[]},"timeline":{"events":[{"event_id":"$event1:example.test","sender":"@alice:example.test","origin_server_ts":-1,"type":"m.room.message","content":{"msgtype":"m.text","body":"Hello Matrix"}}],"limited":false},"account_data":{"events":[]}}},"invite":{},"leave":{}}}"#,
        );
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("negative sync origin_server_ts should fail");
        assert_eq!(error.code, "invalid_room_field");
        assert_eq!(
            error.details.get("field"),
            Some(
                &"sync.rooms.join.!room:example.test.timeline.events.0.origin_server_ts".to_owned()
            )
        );
    }

    #[test]
    fn parses_matrix_media_vectors() {
        let upload = read_spec_vector("test-vectors/media/matrix-media-upload-basic.json");
        let parsed_upload = parse_matrix_media_upload_response(
            upload["expected"]["body_contains"].to_string().as_bytes(),
        )
        .expect("Matrix media upload vector should parse");
        assert_eq!(parsed_upload.content_uri, "mxc://example.test/media1");

        let parsed_uri = parse_matrix_media_content_uri(&parsed_upload.content_uri)
            .expect("Matrix media content URI should parse");
        assert_eq!(parsed_uri.server_name, "example.test");
        assert_eq!(parsed_uri.media_id, "media1");

        for path in [
            "test-vectors/media/matrix-media-upload-missing-token.json",
            "test-vectors/media/matrix-media-upload-too-large.json",
            "test-vectors/media/matrix-media-download-missing-token.json",
            "test-vectors/media/matrix-media-download-not-found.json",
        ] {
            let vector = read_spec_vector(path);
            parse_matrix_error_envelope(vector["expected"]["body_contains"].to_string().as_bytes())
                .unwrap_or_else(|error| panic!("{path} should parse as Matrix error: {error:?}"));
        }
    }

    #[test]
    fn serializes_matrix_media_parse_envelopes() {
        assert_eq!(
            parse_matrix_media_content_uri_json("mxc://example.test/media1"),
            "{\"ok\":true,\"value\":{\"server_name\":\"example.test\",\"media_id\":\"media1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_media_upload_response_json(
                br#"{"content_uri":"mxc://example.test/media1"}"#
            ),
            "{\"ok\":true,\"value\":{\"content_uri\":\"mxc://example.test/media1\"},\"error\":null}"
        );
    }

    #[test]
    fn rejects_invalid_matrix_media_values() {
        let envelope = parse_matrix_media_content_uri_envelope("https://example.test/media1");
        assert!(!envelope.ok);
        let error = envelope.error.expect("invalid content URI should fail");
        assert_eq!(error.code, "invalid_media_field");
        assert_eq!(error.details.get("field"), Some(&"content_uri".to_owned()));

        let envelope =
            parse_matrix_media_upload_response_envelope(br#"{"content_uri":"mxc://example.test"}"#);
        assert!(!envelope.ok);
        let error = envelope
            .error
            .expect("missing media id in upload content_uri should fail");
        assert_eq!(error.code, "invalid_media_field");
        assert_eq!(error.details.get("field"), Some(&"content_uri".to_owned()));
    }

    #[test]
    fn reports_descriptive_error_when_spec_root_is_missing() {
        let error = spec_root_from_sources(None, &[]).expect_err("missing spec root should fail");

        assert!(error.contains("canonical houra-spec checkout not found"));
        assert!(error.contains("HOURA_SPEC_ROOT"));
        assert!(!error.contains("Checked:"));
        assert!(!error.contains("No such file"));
    }

    #[test]
    fn reports_descriptive_error_when_spec_vectors_are_missing() {
        let root =
            std::env::temp_dir().join(format!("houra_wrong_spec_root_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&root);
        std::fs::create_dir(&root).expect("temporary spec root should be created");

        let error = spec_root_from_sources(Some(root.to_string_lossy().as_ref()), &[])
            .expect_err("spec root without test-vectors should fail");

        assert!(error.contains("missing test-vectors/"));
        assert!(error.contains("HOURA_SPEC_ROOT"));
        assert!(!error.contains("No such file"));

        std::fs::remove_dir_all(&root).expect("temporary spec root should be removed");
    }

    fn read_spec_vector(relative_path: &str) -> Value {
        let spec_root = spec_root()
            .expect("canonical houra-spec checkout is required for spec-dependent Rust tests");
        let path = spec_root.join(relative_path);
        let source = std::fs::read_to_string(&path)
            .unwrap_or_else(|error| panic!("failed to read {}: {error}", path.display()));
        serde_json::from_str(&source)
            .unwrap_or_else(|error| panic!("failed to parse {}: {error}", path.display()))
    }

    fn spec_root() -> Result<PathBuf, String> {
        let env_path = std::env::var("HOURA_SPEC_ROOT").ok();
        spec_root_from_sources(env_path.as_deref(), &["../../houra-spec", "../houra-spec"])
    }

    fn spec_root_from_sources(
        houra_spec_root: Option<&str>,
        default_candidates: &[&str],
    ) -> Result<PathBuf, String> {
        if let Some(path) = houra_spec_root.filter(|path| !path.is_empty()) {
            return validate_spec_root(PathBuf::from(path));
        }

        for candidate in default_candidates {
            let path = Path::new(candidate);
            if path.join("test-vectors").exists() {
                return Ok(path.to_path_buf());
            }
        }

        let mut message = "canonical houra-spec checkout not found. Set HOURA_SPEC_ROOT to \
             the canonical houra-spec checkout before running spec-dependent \
             tests."
            .to_owned();
        if !default_candidates.is_empty() {
            message.push_str(&format!(" Checked: {}", default_candidates.join(", ")));
        }
        Err(message)
    }

    fn validate_spec_root(path: PathBuf) -> Result<PathBuf, String> {
        if path.join("test-vectors").exists() {
            return Ok(path);
        }

        if path.exists() {
            return Err(format!(
                "canonical houra-spec checkout at {} is missing test-vectors/. Set \
                 HOURA_SPEC_ROOT to the canonical houra-spec checkout before \
                 running spec-dependent tests.",
                path.display()
            ));
        }

        Err(format!(
            "canonical houra-spec checkout not found at {}. Set \
             HOURA_SPEC_ROOT to the canonical houra-spec checkout before \
             running spec-dependent tests.",
            path.display()
        ))
    }
}
