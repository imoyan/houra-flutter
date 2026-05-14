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
    "SPEC-038", "SPEC-039", "SPEC-040", "SPEC-053", "SPEC-054", "SPEC-055", "SPEC-056",
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

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationTransaction {
    pub origin: String,
    pub origin_server_ts: u64,
    pub pdus: Vec<Value>,
    pub edus: Vec<Value>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationPduResult {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationTransactionResponse {
    pub pdus: BTreeMap<String, MatrixFederationPduResult>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationMakeJoinResponse {
    pub room_version: String,
    pub event: Value,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationSendJoinResponse {
    pub origin: String,
    pub state: Vec<Value>,
    pub auth_chain: Vec<Value>,
    pub event: Value,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationInviteRequest {
    pub room_version: String,
    pub event: Value,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationInviteResponse {
    pub event: Value,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationServerName {
    pub server_name: String,
    pub host: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub port: Option<u16>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationWellKnownServer {
    pub delegated_server_name: String,
    pub host: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub port: Option<u16>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationVerifyKey {
    pub key: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationOldVerifyKey {
    pub expired_ts: u64,
    pub key: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationSigningKey {
    pub server_name: String,
    pub verify_keys: BTreeMap<String, MatrixFederationVerifyKey>,
    pub old_verify_keys: BTreeMap<String, MatrixFederationOldVerifyKey>,
    pub valid_until_ts: u64,
    pub signatures: BTreeMap<String, BTreeMap<String, String>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationKeyQueryCriteria {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub minimum_valid_until_ts: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationKeyQueryRequest {
    pub server_keys: BTreeMap<String, BTreeMap<String, MatrixFederationKeyQueryCriteria>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationKeyQueryResponse {
    pub server_keys: Vec<MatrixFederationSigningKey>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationDestinationResolutionFailure {
    pub server_name: String,
    pub stages: Vec<String>,
    pub destination_resolved: bool,
    pub federation_request_sent: bool,
    pub backoff_recorded: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixVerificationSasFlow {
    pub transaction_id: String,
    pub transport: String,
    pub event_types: Vec<String>,
    pub verified: bool,
    pub local_sas_allowed: bool,
    pub versions_advertisement_widened: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixVerificationCancel {
    pub transaction_id: String,
    pub code: String,
    pub reason: String,
    pub verified: bool,
    pub versions_advertisement_widened: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningKey {
    pub user_id: String,
    pub usage: Vec<String>,
    pub keys: BTreeMap<String, String>,
    pub signatures: BTreeMap<String, BTreeMap<String, String>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningDeviceSigningUpload {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub master_key: Option<MatrixCrossSigningKey>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub self_signing_key: Option<MatrixCrossSigningKey>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub user_signing_key: Option<MatrixCrossSigningKey>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixCrossSigningSignatureUpload {
    pub signed_objects: BTreeMap<String, BTreeMap<String, Value>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningInvalidSignatureFailure {
    pub status: u64,
    pub errcode: String,
    pub error: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningMissingTokenGate {
    pub protected_key_operations_require_token: bool,
    pub semantic_errors_suppressed_until_authenticated: bool,
    pub auth_precedes_signature_validation: bool,
    pub operations: Vec<String>,
    pub errcode: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixWrongDeviceIdentity {
    pub user_id: String,
    pub device_id: String,
    pub master_key: String,
    pub device_key: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixWrongDeviceFailureGate {
    pub trusted_identity: MatrixWrongDeviceIdentity,
    pub observed_identity: MatrixWrongDeviceIdentity,
    pub required_steps: Vec<String>,
    pub required_evidence: Vec<String>,
    pub cancel_code: String,
    pub device_verified: bool,
    pub outbound_session_shared: bool,
    pub requires_user_reverification: bool,
    pub versions_advertisement_widened: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupAuthData {
    pub public_key: String,
    pub signatures: BTreeMap<String, BTreeMap<String, String>>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupVersionCreateResponse {
    pub version: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupVersion {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub version: Option<String>,
    pub algorithm: String,
    pub auth_data: MatrixKeyBackupAuthData,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixKeyBackupSession {
    pub first_message_index: u64,
    pub forwarded_count: u64,
    pub is_verified: bool,
    pub session_data: BTreeMap<String, Value>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupSessionUploadResponse {
    pub etag: String,
    pub count: u64,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupError {
    pub status: u64,
    pub errcode: String,
    pub error: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub current_version: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupOwnerScopeGate {
    pub owner_scope_enforced: bool,
    pub protected_backup_unchanged: bool,
    pub checked_steps: Vec<String>,
    pub versions_advertisement_widened: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupRecoveryGate {
    pub logout_relogin_restore: bool,
    pub crypto_stack_required: bool,
    pub local_olm_megolm_allowed: bool,
    pub required_contracts: Vec<String>,
    pub required_evidence: Vec<String>,
    pub versions_advertisement_widened: bool,
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

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationTransactionParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationTransaction>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationTransactionResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationTransactionResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationMakeJoinResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationMakeJoinResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationSendJoinResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationSendJoinResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationInviteRequestParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationInviteRequest>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixFederationInviteResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationInviteResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationServerNameParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationServerName>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationWellKnownServerParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationWellKnownServer>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationSigningKeyParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationSigningKey>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationKeyQueryRequestParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationKeyQueryRequest>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationKeyQueryResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationKeyQueryResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixFederationDestinationResolutionFailureParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixFederationDestinationResolutionFailure>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixVerificationSasFlowParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixVerificationSasFlow>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixVerificationCancelParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixVerificationCancel>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningDeviceSigningUploadParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixCrossSigningDeviceSigningUpload>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixCrossSigningSignatureUploadParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixCrossSigningSignatureUpload>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningInvalidSignatureFailureParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixCrossSigningInvalidSignatureFailure>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixCrossSigningMissingTokenGateParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixCrossSigningMissingTokenGate>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixWrongDeviceFailureGateParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixWrongDeviceFailureGate>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupVersionCreateResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupVersionCreateResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupVersionParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupVersion>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub struct MatrixKeyBackupSessionParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupSession>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupSessionUploadResponseParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupSessionUploadResponse>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupErrorParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupError>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupOwnerScopeGateParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupOwnerScopeGate>,
    pub error: Option<ProtocolErrorEnvelope>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct MatrixKeyBackupRecoveryGateParseEnvelope {
    pub ok: bool,
    pub value: Option<MatrixKeyBackupRecoveryGate>,
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
    InvalidFederationField { field: String },
    InvalidVerificationField { field: String },
    InvalidKeyBackupField { field: String },
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
            ProtocolError::InvalidFederationField { .. } => "invalid_federation_field",
            ProtocolError::InvalidVerificationField { .. } => "invalid_verification_field",
            ProtocolError::InvalidKeyBackupField { .. } => "invalid_key_backup_field",
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
            ProtocolError::InvalidFederationField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidVerificationField { field } => {
                details.insert("field".to_owned(), field.clone());
            }
            ProtocolError::InvalidKeyBackupField { field } => {
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
            ProtocolError::InvalidFederationField { field } => {
                write!(formatter, "{field} is not a valid Matrix federation value")
            }
            ProtocolError::InvalidVerificationField { field } => {
                write!(
                    formatter,
                    "{field} is not a valid Matrix verification value"
                )
            }
            ProtocolError::InvalidKeyBackupField { field } => {
                write!(formatter, "{field} is not a valid Matrix key backup value")
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
    current_version: Option<String>,
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

#[derive(Debug, Deserialize)]
struct MatrixFederationTransactionWire {
    origin: Option<String>,
    origin_server_ts: Option<i64>,
    pdus: Option<Vec<Value>>,
    #[serde(default)]
    edus: Vec<Value>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationPduResultWire {
    error: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationTransactionResponseWire {
    pdus: Option<BTreeMap<String, MatrixFederationPduResultWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationMakeJoinResponseWire {
    room_version: Option<String>,
    event: Option<Value>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationSendJoinResponseWire {
    origin: Option<String>,
    state: Option<Vec<Value>>,
    auth_chain: Option<Vec<Value>>,
    event: Option<Value>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationInviteWire {
    room_version: Option<String>,
    event: Option<Value>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationInviteResponseWire {
    event: Option<Value>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationWellKnownServerWire {
    #[serde(rename = "m.server")]
    delegated_server_name: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationVerifyKeyWire {
    key: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationOldVerifyKeyWire {
    expired_ts: Option<i64>,
    key: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationSigningKeyWire {
    server_name: Option<String>,
    verify_keys: Option<BTreeMap<String, MatrixFederationVerifyKeyWire>>,
    #[serde(default)]
    old_verify_keys: BTreeMap<String, MatrixFederationOldVerifyKeyWire>,
    valid_until_ts: Option<i64>,
    signatures: Option<BTreeMap<String, BTreeMap<String, String>>>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationKeyQueryCriteriaWire {
    minimum_valid_until_ts: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationKeyQueryRequestWire {
    server_keys: Option<BTreeMap<String, BTreeMap<String, MatrixFederationKeyQueryCriteriaWire>>>,
}

#[derive(Debug, Deserialize)]
struct MatrixFederationKeyQueryResponseWire {
    server_keys: Option<Vec<MatrixFederationSigningKeyWire>>,
}

#[derive(Debug, Deserialize)]
struct MatrixVerificationEventWire {
    #[serde(default)]
    transport: Option<String>,
    transaction_id: Option<String>,
    steps: Option<Vec<MatrixVerificationStepWire>>,
    auth_precedes_signature_validation: Option<bool>,
    trusted_identity: Option<MatrixWrongDeviceIdentityWire>,
    observed_identity: Option<MatrixWrongDeviceIdentityWire>,
    required_evidence: Option<Vec<String>>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupVersionWire {
    version: Option<String>,
    algorithm: Option<String>,
    auth_data: Option<MatrixKeyBackupAuthDataWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupAuthDataWire {
    public_key: Option<String>,
    signatures: Option<BTreeMap<String, BTreeMap<String, String>>>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupSessionWire {
    first_message_index: Option<i64>,
    forwarded_count: Option<i64>,
    is_verified: Option<bool>,
    session_data: Option<BTreeMap<String, Value>>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupSessionUploadResponseWire {
    etag: Option<String>,
    count: Option<i64>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupErrorWire {
    status: Option<i64>,
    error: Option<MatrixErrorWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupGateEventWire {
    required_contracts: Option<Vec<String>>,
    crypto_stack_required: Option<bool>,
    local_olm_megolm_allowed: Option<bool>,
    steps: Option<Vec<MatrixKeyBackupGateStepWire>>,
    required_evidence: Option<Vec<String>>,
}

#[derive(Debug, Deserialize)]
struct MatrixKeyBackupGateStepWire {
    id: Option<String>,
    required: Option<bool>,
    expected_status: Option<i64>,
    expected_error: Option<MatrixErrorWire>,
    must_not_disclose_protected_backup: Option<bool>,
    must_not_mutate_protected_backup: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixVerificationStepWire {
    id: Option<String>,
    #[serde(rename = "type")]
    event_type: Option<String>,
    to_device: Option<bool>,
    content: Option<MatrixVerificationContentWire>,
    result: Option<MatrixVerificationResultWire>,
    expected_status: Option<u64>,
    expected_error: Option<MatrixErrorWire>,
    cancel_code: Option<String>,
    required: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixVerificationContentWire {
    transaction_id: Option<String>,
    code: Option<String>,
    reason: Option<String>,
}

#[derive(Debug, Deserialize)]
struct MatrixVerificationResultWire {
    verified: Option<bool>,
    device_verified: Option<bool>,
    outbound_session_shared: Option<bool>,
    requires_user_reverification: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct MatrixCrossSigningKeyWire {
    user_id: Option<String>,
    usage: Option<Vec<String>>,
    keys: Option<BTreeMap<String, String>>,
    signatures: Option<BTreeMap<String, BTreeMap<String, String>>>,
}

#[derive(Debug, Deserialize)]
struct MatrixCrossSigningDeviceSigningUploadWire {
    master_key: Option<MatrixCrossSigningKeyWire>,
    self_signing_key: Option<MatrixCrossSigningKeyWire>,
    user_signing_key: Option<MatrixCrossSigningKeyWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixCrossSigningInvalidSignatureFailureWire {
    status: Option<u64>,
    error: Option<MatrixErrorWire>,
}

#[derive(Debug, Deserialize)]
struct MatrixWrongDeviceIdentityWire {
    user_id: Option<String>,
    device_id: Option<String>,
    master_key: Option<String>,
    device_key: Option<String>,
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

pub fn parse_matrix_federation_transaction(
    bytes: &[u8],
) -> Result<MatrixFederationTransaction, ProtocolError> {
    let wire: MatrixFederationTransactionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let origin_server_ts = required_federation_timestamp(
        wire.origin_server_ts,
        "federation.transaction.origin_server_ts",
    )?;
    let pdus = required_federation_object_array(wire.pdus, "federation.transaction.pdus")?;
    if pdus.len() > 50 {
        return Err(invalid_federation_field("federation.transaction.pdus"));
    }
    if wire.edus.len() > 100 {
        return Err(invalid_federation_field("federation.transaction.edus"));
    }

    Ok(MatrixFederationTransaction {
        origin: required_federation_string(wire.origin, "federation.transaction.origin")?,
        origin_server_ts,
        pdus,
        edus: federation_object_array(wire.edus, "federation.transaction.edus")?,
    })
}

pub fn parse_matrix_federation_transaction_envelope(
    bytes: &[u8],
) -> MatrixFederationTransactionParseEnvelope {
    match parse_matrix_federation_transaction(bytes) {
        Ok(value) => MatrixFederationTransactionParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationTransactionParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_transaction_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_transaction_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_transaction_response(
    bytes: &[u8],
) -> Result<MatrixFederationTransactionResponse, ProtocolError> {
    let wire: MatrixFederationTransactionResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let pdus = wire
        .pdus
        .ok_or_else(|| invalid_federation_field("federation.transaction_response.pdus"))?
        .into_iter()
        .map(|(event_id, result)| {
            if event_id.is_empty() {
                return Err(invalid_federation_field(
                    "federation.transaction_response.pdus",
                ));
            }
            Ok((
                event_id,
                MatrixFederationPduResult {
                    error: optional_federation_string(
                        result.error,
                        "federation.transaction_response.pdus.error",
                    )?,
                },
            ))
        })
        .collect::<Result<BTreeMap<_, _>, _>>()?;

    Ok(MatrixFederationTransactionResponse { pdus })
}

pub fn parse_matrix_federation_transaction_response_envelope(
    bytes: &[u8],
) -> MatrixFederationTransactionResponseParseEnvelope {
    match parse_matrix_federation_transaction_response(bytes) {
        Ok(value) => MatrixFederationTransactionResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationTransactionResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_transaction_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_transaction_response_envelope(
        bytes,
    ))
    .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_make_join_response(
    bytes: &[u8],
) -> Result<MatrixFederationMakeJoinResponse, ProtocolError> {
    let wire: MatrixFederationMakeJoinResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let event = required_federation_object(wire.event, "federation.make_join.event")?;

    Ok(MatrixFederationMakeJoinResponse {
        room_version: required_federation_string(
            wire.room_version,
            "federation.make_join.room_version",
        )?,
        event,
    })
}

pub fn parse_matrix_federation_make_join_response_envelope(
    bytes: &[u8],
) -> MatrixFederationMakeJoinResponseParseEnvelope {
    match parse_matrix_federation_make_join_response(bytes) {
        Ok(value) => MatrixFederationMakeJoinResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationMakeJoinResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_make_join_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_make_join_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_send_join_response(
    bytes: &[u8],
) -> Result<MatrixFederationSendJoinResponse, ProtocolError> {
    let wire: MatrixFederationSendJoinResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixFederationSendJoinResponse {
        origin: required_federation_string(wire.origin, "federation.send_join.origin")?,
        state: required_federation_object_array(wire.state, "federation.send_join.state")?,
        auth_chain: required_federation_object_array(
            wire.auth_chain,
            "federation.send_join.auth_chain",
        )?,
        event: required_federation_object(wire.event, "federation.send_join.event")?,
    })
}

pub fn parse_matrix_federation_send_join_response_envelope(
    bytes: &[u8],
) -> MatrixFederationSendJoinResponseParseEnvelope {
    match parse_matrix_federation_send_join_response(bytes) {
        Ok(value) => MatrixFederationSendJoinResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationSendJoinResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_send_join_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_send_join_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_invite_request(
    bytes: &[u8],
) -> Result<MatrixFederationInviteRequest, ProtocolError> {
    let wire: MatrixFederationInviteWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixFederationInviteRequest {
        room_version: required_federation_string(
            wire.room_version,
            "federation.invite.room_version",
        )?,
        event: required_federation_object(wire.event, "federation.invite.event")?,
    })
}

pub fn parse_matrix_federation_invite_request_envelope(
    bytes: &[u8],
) -> MatrixFederationInviteRequestParseEnvelope {
    match parse_matrix_federation_invite_request(bytes) {
        Ok(value) => MatrixFederationInviteRequestParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationInviteRequestParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_invite_request_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_invite_request_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_invite_response(
    bytes: &[u8],
) -> Result<MatrixFederationInviteResponse, ProtocolError> {
    let wire: MatrixFederationInviteResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;

    Ok(MatrixFederationInviteResponse {
        event: required_federation_object(wire.event, "federation.invite_response.event")?,
    })
}

pub fn parse_matrix_federation_invite_response_envelope(
    bytes: &[u8],
) -> MatrixFederationInviteResponseParseEnvelope {
    match parse_matrix_federation_invite_response(bytes) {
        Ok(value) => MatrixFederationInviteResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationInviteResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_invite_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_invite_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_server_name(
    server_name: &str,
) -> Result<MatrixFederationServerName, ProtocolError> {
    let server_name = required_federation_borrowed_string(server_name, "federation.server_name")?;
    if server_name.contains('/') || server_name.contains('@') || server_name.contains('#') {
        return Err(invalid_federation_field("federation.server_name"));
    }
    let (host, port) = split_federation_server_name(server_name)?;

    Ok(MatrixFederationServerName {
        server_name: server_name.to_owned(),
        host,
        port,
    })
}

pub fn parse_matrix_federation_server_name_envelope(
    server_name: &str,
) -> MatrixFederationServerNameParseEnvelope {
    match parse_matrix_federation_server_name(server_name) {
        Ok(value) => MatrixFederationServerNameParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationServerNameParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_server_name_json(server_name: &str) -> String {
    serde_json::to_string(&parse_matrix_federation_server_name_envelope(server_name))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_well_known_server(
    bytes: &[u8],
) -> Result<MatrixFederationWellKnownServer, ProtocolError> {
    let wire: MatrixFederationWellKnownServerWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let delegated_server_name =
        required_federation_string(wire.delegated_server_name, "federation.well_known.m.server")?;
    let parsed = parse_matrix_federation_server_name(&delegated_server_name)?;

    Ok(MatrixFederationWellKnownServer {
        delegated_server_name: parsed.server_name,
        host: parsed.host,
        port: parsed.port,
    })
}

pub fn parse_matrix_federation_well_known_server_envelope(
    bytes: &[u8],
) -> MatrixFederationWellKnownServerParseEnvelope {
    match parse_matrix_federation_well_known_server(bytes) {
        Ok(value) => MatrixFederationWellKnownServerParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationWellKnownServerParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_well_known_server_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_well_known_server_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_signing_key(
    bytes: &[u8],
) -> Result<MatrixFederationSigningKey, ProtocolError> {
    let wire: MatrixFederationSigningKeyWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    matrix_federation_signing_key_from_wire(wire)
}

pub fn parse_matrix_federation_signing_key_envelope(
    bytes: &[u8],
) -> MatrixFederationSigningKeyParseEnvelope {
    match parse_matrix_federation_signing_key(bytes) {
        Ok(value) => MatrixFederationSigningKeyParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationSigningKeyParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_signing_key_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_signing_key_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_key_query_request(
    bytes: &[u8],
) -> Result<MatrixFederationKeyQueryRequest, ProtocolError> {
    let wire: MatrixFederationKeyQueryRequestWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let server_keys = wire
        .server_keys
        .ok_or_else(|| invalid_federation_field("federation.key_query_request.server_keys"))?
        .into_iter()
        .map(|(server_name, key_criteria)| {
            parse_matrix_federation_server_name(&server_name)?;
            if key_criteria.is_empty() {
                return Err(invalid_federation_field(
                    "federation.key_query_request.server_keys",
                ));
            }
            let criteria = key_criteria
                .into_iter()
                .map(|(key_id, criteria)| {
                    required_federation_key_id(&key_id, "federation.key_query_request.key_id")?;
                    Ok((
                        key_id,
                        MatrixFederationKeyQueryCriteria {
                            minimum_valid_until_ts: optional_federation_timestamp(
                                criteria.minimum_valid_until_ts,
                                "federation.key_query_request.minimum_valid_until_ts",
                            )?,
                        },
                    ))
                })
                .collect::<Result<BTreeMap<_, _>, _>>()?;
            Ok((server_name, criteria))
        })
        .collect::<Result<BTreeMap<_, _>, _>>()?;

    Ok(MatrixFederationKeyQueryRequest { server_keys })
}

pub fn parse_matrix_federation_key_query_request_envelope(
    bytes: &[u8],
) -> MatrixFederationKeyQueryRequestParseEnvelope {
    match parse_matrix_federation_key_query_request(bytes) {
        Ok(value) => MatrixFederationKeyQueryRequestParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationKeyQueryRequestParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_key_query_request_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_key_query_request_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_key_query_response(
    bytes: &[u8],
) -> Result<MatrixFederationKeyQueryResponse, ProtocolError> {
    let wire: MatrixFederationKeyQueryResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let server_keys = wire
        .server_keys
        .ok_or_else(|| invalid_federation_field("federation.key_query_response.server_keys"))?
        .into_iter()
        .map(matrix_federation_signing_key_from_wire)
        .collect::<Result<Vec<_>, _>>()?;

    Ok(MatrixFederationKeyQueryResponse { server_keys })
}

pub fn parse_matrix_federation_key_query_response_envelope(
    bytes: &[u8],
) -> MatrixFederationKeyQueryResponseParseEnvelope {
    match parse_matrix_federation_key_query_response(bytes) {
        Ok(value) => MatrixFederationKeyQueryResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationKeyQueryResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_key_query_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_key_query_response_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_federation_destination_resolution_failure(
    bytes: &[u8],
) -> Result<MatrixFederationDestinationResolutionFailure, ProtocolError> {
    let value: Value =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let event = value
        .get("event")
        .and_then(Value::as_object)
        .ok_or_else(|| invalid_federation_field("federation.destination_failure.event"))?;
    let server_name = event
        .get("server_name")
        .and_then(Value::as_str)
        .ok_or_else(|| invalid_federation_field("federation.destination_failure.server_name"))?;
    parse_matrix_federation_server_name(server_name)?;
    let steps = event
        .get("steps")
        .and_then(Value::as_array)
        .ok_or_else(|| invalid_federation_field("federation.destination_failure.steps"))?;
    let mut stages = Vec::new();
    let mut destination_resolved = true;
    let mut federation_request_sent = true;
    let mut backoff_recorded = false;
    for step in steps {
        let step = step
            .as_object()
            .ok_or_else(|| invalid_federation_field("federation.destination_failure.steps"))?;
        let stage = step
            .get("stage")
            .and_then(Value::as_str)
            .ok_or_else(|| invalid_federation_field("federation.destination_failure.stage"))?;
        stages.push(stage.to_owned());
        if let Some(result) = step.get("result").and_then(Value::as_object) {
            if let Some(value) = result.get("destination_resolved").and_then(Value::as_bool) {
                destination_resolved = value;
            }
            if let Some(value) = result
                .get("federation_request_sent")
                .and_then(Value::as_bool)
            {
                federation_request_sent = value;
            }
            if let Some(value) = result.get("backoff_recorded").and_then(Value::as_bool) {
                backoff_recorded = value;
            }
        }
    }

    Ok(MatrixFederationDestinationResolutionFailure {
        server_name: server_name.to_owned(),
        stages,
        destination_resolved,
        federation_request_sent,
        backoff_recorded,
    })
}

pub fn parse_matrix_federation_destination_resolution_failure_envelope(
    bytes: &[u8],
) -> MatrixFederationDestinationResolutionFailureParseEnvelope {
    match parse_matrix_federation_destination_resolution_failure(bytes) {
        Ok(value) => MatrixFederationDestinationResolutionFailureParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixFederationDestinationResolutionFailureParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_federation_destination_resolution_failure_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_federation_destination_resolution_failure_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_verification_sas_flow(
    bytes: &[u8],
) -> Result<MatrixVerificationSasFlow, ProtocolError> {
    let wire: MatrixVerificationEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let transaction_id =
        required_verification_string(wire.transaction_id, "verification.transaction_id")?;
    let transport = required_verification_string(wire.transport, "verification.transport")?;
    let mut event_types = Vec::new();
    let mut verified = false;
    for (index, step) in verification_steps(wire.steps)?.into_iter().enumerate() {
        if let Some(event_type) = step.event_type {
            required_verification_borrowed_string(
                &event_type,
                &format!("verification.steps.{index}.type"),
            )?;
            if step.to_device != Some(true) {
                return Err(invalid_verification_field(&format!(
                    "verification.steps.{index}.to_device"
                )));
            }
            let content = step.content.ok_or_else(|| {
                invalid_verification_field(&format!("verification.steps.{index}.content"))
            })?;
            let step_transaction_id = required_verification_string(
                content.transaction_id,
                &format!("verification.steps.{index}.content.transaction_id"),
            )?;
            if step_transaction_id != transaction_id {
                return Err(invalid_verification_field(&format!(
                    "verification.steps.{index}.content.transaction_id"
                )));
            }
            event_types.push(event_type);
        }
        if let Some(result) = step.result {
            if result.verified == Some(true) {
                verified = true;
            }
        }
    }
    if event_types.is_empty() {
        return Err(invalid_verification_field("verification.steps.type"));
    }

    Ok(MatrixVerificationSasFlow {
        transaction_id,
        transport,
        event_types,
        verified,
        local_sas_allowed: false,
        versions_advertisement_widened: false,
    })
}

pub fn parse_matrix_verification_sas_flow_envelope(
    bytes: &[u8],
) -> MatrixVerificationSasFlowParseEnvelope {
    match parse_matrix_verification_sas_flow(bytes) {
        Ok(value) => MatrixVerificationSasFlowParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixVerificationSasFlowParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_verification_sas_flow_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_verification_sas_flow_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_verification_cancel(
    bytes: &[u8],
) -> Result<MatrixVerificationCancel, ProtocolError> {
    let wire: MatrixVerificationEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let transaction_id =
        required_verification_string(wire.transaction_id, "verification.transaction_id")?;
    let mut cancel_code = None;
    let mut cancel_reason = None;
    let mut verified = false;
    for (index, step) in verification_steps(wire.steps)?.into_iter().enumerate() {
        if step.event_type.as_deref() == Some("m.key.verification.cancel") {
            if step.to_device != Some(true) {
                return Err(invalid_verification_field(&format!(
                    "verification.steps.{index}.to_device"
                )));
            }
            let content = step.content.ok_or_else(|| {
                invalid_verification_field(&format!("verification.steps.{index}.content"))
            })?;
            let step_transaction_id = required_verification_string(
                content.transaction_id,
                &format!("verification.steps.{index}.content.transaction_id"),
            )?;
            if step_transaction_id != transaction_id {
                return Err(invalid_verification_field(&format!(
                    "verification.steps.{index}.content.transaction_id"
                )));
            }
            cancel_code = Some(required_verification_string(
                content.code,
                &format!("verification.steps.{index}.content.code"),
            )?);
            cancel_reason = Some(required_verification_string(
                content.reason,
                &format!("verification.steps.{index}.content.reason"),
            )?);
        }
        if let Some(result) = step.result {
            if result.verified == Some(false) {
                verified = false;
            }
        }
    }

    Ok(MatrixVerificationCancel {
        transaction_id,
        code: cancel_code
            .ok_or_else(|| invalid_verification_field("verification.steps.content.code"))?,
        reason: cancel_reason
            .ok_or_else(|| invalid_verification_field("verification.steps.content.reason"))?,
        verified,
        versions_advertisement_widened: false,
    })
}

pub fn parse_matrix_verification_cancel_envelope(
    bytes: &[u8],
) -> MatrixVerificationCancelParseEnvelope {
    match parse_matrix_verification_cancel(bytes) {
        Ok(value) => MatrixVerificationCancelParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixVerificationCancelParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_verification_cancel_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_verification_cancel_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_cross_signing_device_signing_upload(
    bytes: &[u8],
) -> Result<MatrixCrossSigningDeviceSigningUpload, ProtocolError> {
    let wire: MatrixCrossSigningDeviceSigningUploadWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let upload = MatrixCrossSigningDeviceSigningUpload {
        master_key: optional_cross_signing_key(
            wire.master_key,
            "cross_signing.device_signing_upload.master_key",
        )?,
        self_signing_key: optional_cross_signing_key(
            wire.self_signing_key,
            "cross_signing.device_signing_upload.self_signing_key",
        )?,
        user_signing_key: optional_cross_signing_key(
            wire.user_signing_key,
            "cross_signing.device_signing_upload.user_signing_key",
        )?,
    };
    if upload.master_key.is_none()
        && upload.self_signing_key.is_none()
        && upload.user_signing_key.is_none()
    {
        return Err(invalid_verification_field(
            "cross_signing.device_signing_upload",
        ));
    }
    Ok(upload)
}

pub fn parse_matrix_cross_signing_device_signing_upload_envelope(
    bytes: &[u8],
) -> MatrixCrossSigningDeviceSigningUploadParseEnvelope {
    match parse_matrix_cross_signing_device_signing_upload(bytes) {
        Ok(value) => MatrixCrossSigningDeviceSigningUploadParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixCrossSigningDeviceSigningUploadParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_cross_signing_device_signing_upload_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_cross_signing_device_signing_upload_envelope(
        bytes,
    ))
    .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_cross_signing_signature_upload(
    bytes: &[u8],
) -> Result<MatrixCrossSigningSignatureUpload, ProtocolError> {
    let signed_objects: BTreeMap<String, BTreeMap<String, Value>> =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    if signed_objects.is_empty() {
        return Err(invalid_verification_field(
            "cross_signing.signatures_upload",
        ));
    }
    for (user_id, devices) in &signed_objects {
        required_verification_borrowed_string(user_id, "cross_signing.signatures_upload.user_id")?;
        if devices.is_empty() {
            return Err(invalid_verification_field(
                "cross_signing.signatures_upload.devices",
            ));
        }
        for (device_id, object) in devices {
            required_verification_borrowed_string(
                device_id,
                "cross_signing.signatures_upload.device_id",
            )?;
            if !object.is_object() {
                return Err(invalid_verification_field(
                    "cross_signing.signatures_upload.signed_object",
                ));
            }
        }
    }
    Ok(MatrixCrossSigningSignatureUpload { signed_objects })
}

pub fn parse_matrix_cross_signing_signature_upload_envelope(
    bytes: &[u8],
) -> MatrixCrossSigningSignatureUploadParseEnvelope {
    match parse_matrix_cross_signing_signature_upload(bytes) {
        Ok(value) => MatrixCrossSigningSignatureUploadParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixCrossSigningSignatureUploadParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_cross_signing_signature_upload_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_cross_signing_signature_upload_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_cross_signing_invalid_signature_failure(
    bytes: &[u8],
) -> Result<MatrixCrossSigningInvalidSignatureFailure, ProtocolError> {
    let wire: MatrixCrossSigningInvalidSignatureFailureWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let error = wire
        .error
        .ok_or_else(|| invalid_verification_field("cross_signing.invalid_signature.error"))?;
    let status = wire
        .status
        .ok_or_else(|| invalid_verification_field("cross_signing.invalid_signature.status"))?;
    if status != 400 {
        return Err(invalid_verification_field(
            "cross_signing.invalid_signature.status",
        ));
    }
    let errcode =
        required_verification_string(error.errcode, "cross_signing.invalid_signature.errcode")?;
    if errcode != "M_INVALID_SIGNATURE" {
        return Err(invalid_verification_field(
            "cross_signing.invalid_signature.errcode",
        ));
    }
    Ok(MatrixCrossSigningInvalidSignatureFailure {
        status,
        errcode,
        error: required_verification_string(error.error, "cross_signing.invalid_signature.error")?,
    })
}

pub fn parse_matrix_cross_signing_invalid_signature_failure_envelope(
    bytes: &[u8],
) -> MatrixCrossSigningInvalidSignatureFailureParseEnvelope {
    match parse_matrix_cross_signing_invalid_signature_failure(bytes) {
        Ok(value) => MatrixCrossSigningInvalidSignatureFailureParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixCrossSigningInvalidSignatureFailureParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_cross_signing_invalid_signature_failure_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_cross_signing_invalid_signature_failure_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_cross_signing_missing_token_gate(
    bytes: &[u8],
) -> Result<MatrixCrossSigningMissingTokenGate, ProtocolError> {
    let wire: MatrixVerificationEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let mut operations = Vec::new();
    let mut errcode = None;
    for (index, step) in verification_steps(wire.steps)?.into_iter().enumerate() {
        let id = required_verification_string(
            step.id,
            &format!("cross_signing.missing_token.steps.{index}.id"),
        )?;
        if step.expected_status != Some(401) {
            return Err(invalid_verification_field(&format!(
                "cross_signing.missing_token.steps.{index}.expected_status"
            )));
        }
        let error = step.expected_error.ok_or_else(|| {
            invalid_verification_field(&format!(
                "cross_signing.missing_token.steps.{index}.expected_error"
            ))
        })?;
        let step_errcode = required_verification_string(
            error.errcode,
            &format!("cross_signing.missing_token.steps.{index}.expected_error.errcode"),
        )?;
        if step_errcode != "M_MISSING_TOKEN" {
            return Err(invalid_verification_field(&format!(
                "cross_signing.missing_token.steps.{index}.expected_error.errcode"
            )));
        }
        errcode = Some(step_errcode);
        operations.push(id);
    }

    Ok(MatrixCrossSigningMissingTokenGate {
        protected_key_operations_require_token: true,
        semantic_errors_suppressed_until_authenticated: true,
        auth_precedes_signature_validation: wire.auth_precedes_signature_validation == Some(true),
        operations,
        errcode: errcode.ok_or_else(|| {
            invalid_verification_field("cross_signing.missing_token.expected_error.errcode")
        })?,
    })
}

pub fn parse_matrix_cross_signing_missing_token_gate_envelope(
    bytes: &[u8],
) -> MatrixCrossSigningMissingTokenGateParseEnvelope {
    match parse_matrix_cross_signing_missing_token_gate(bytes) {
        Ok(value) => MatrixCrossSigningMissingTokenGateParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixCrossSigningMissingTokenGateParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_cross_signing_missing_token_gate_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_cross_signing_missing_token_gate_envelope(
        bytes,
    ))
    .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_wrong_device_failure_gate(
    bytes: &[u8],
) -> Result<MatrixWrongDeviceFailureGate, ProtocolError> {
    let wire: MatrixVerificationEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let mut required_steps = Vec::new();
    let mut cancel_code = None;
    let mut device_verified = false;
    let mut outbound_session_shared = false;
    let mut requires_user_reverification = true;
    for (index, step) in verification_steps(wire.steps)?.into_iter().enumerate() {
        let step_id = step.id.clone();
        if step.required == Some(true) {
            required_steps.push(required_verification_string(
                step_id.clone(),
                &format!("wrong_device.steps.{index}.id"),
            )?);
        }
        if step_id.as_deref() == Some("refuse-to-mark-device-verified") {
            device_verified = false;
        }
        if step_id.as_deref() == Some("refuse-outbound-session-share") {
            outbound_session_shared = false;
        }
        if step_id.as_deref() == Some("record-verification-failure") {
            requires_user_reverification = true;
        }
        if let Some(code) = step.cancel_code {
            cancel_code = Some(
                required_verification_borrowed_string(
                    &code,
                    &format!("wrong_device.steps.{index}.cancel_code"),
                )?
                .to_owned(),
            );
        }
        if let Some(result) = step.result {
            if result.device_verified == Some(false) {
                device_verified = false;
            }
            if result.outbound_session_shared == Some(false) {
                outbound_session_shared = false;
            }
            if result.requires_user_reverification == Some(true) {
                requires_user_reverification = true;
            }
        }
    }
    let expected_steps = [
        "load-established-trust-chain",
        "observe-device-or-master-key-mismatch",
        "refuse-to-mark-device-verified",
        "refuse-outbound-session-share",
        "record-verification-failure",
    ];
    if !expected_steps
        .iter()
        .all(|step| required_steps.iter().any(|required| required == step))
    {
        return Err(invalid_verification_field("wrong_device.required_steps"));
    }

    Ok(MatrixWrongDeviceFailureGate {
        trusted_identity: wrong_device_identity(
            wire.trusted_identity,
            "wrong_device.trusted_identity",
        )?,
        observed_identity: wrong_device_identity(
            wire.observed_identity,
            "wrong_device.observed_identity",
        )?,
        required_steps,
        required_evidence: required_verification_string_array(
            wire.required_evidence,
            "wrong_device.required_evidence",
        )?,
        cancel_code: cancel_code
            .ok_or_else(|| invalid_verification_field("wrong_device.cancel_code"))?,
        device_verified,
        outbound_session_shared,
        requires_user_reverification,
        versions_advertisement_widened: false,
    })
}

pub fn parse_matrix_wrong_device_failure_gate_envelope(
    bytes: &[u8],
) -> MatrixWrongDeviceFailureGateParseEnvelope {
    match parse_matrix_wrong_device_failure_gate(bytes) {
        Ok(value) => MatrixWrongDeviceFailureGateParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixWrongDeviceFailureGateParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_wrong_device_failure_gate_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_wrong_device_failure_gate_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_version_create_response(
    bytes: &[u8],
) -> Result<MatrixKeyBackupVersionCreateResponse, ProtocolError> {
    let wire: MatrixKeyBackupVersionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    Ok(MatrixKeyBackupVersionCreateResponse {
        version: required_key_backup_string(wire.version, "key_backup.version")?,
    })
}

pub fn parse_matrix_key_backup_version_create_response_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupVersionCreateResponseParseEnvelope {
    match parse_matrix_key_backup_version_create_response(bytes) {
        Ok(value) => MatrixKeyBackupVersionCreateResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupVersionCreateResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_version_create_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_version_create_response_envelope(
        bytes,
    ))
    .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_version(
    bytes: &[u8],
) -> Result<MatrixKeyBackupVersion, ProtocolError> {
    let wire: MatrixKeyBackupVersionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    key_backup_version_from_wire(wire, "key_backup.version")
}

pub fn parse_matrix_key_backup_version_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupVersionParseEnvelope {
    match parse_matrix_key_backup_version(bytes) {
        Ok(value) => MatrixKeyBackupVersionParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupVersionParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_version_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_version_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_session(
    bytes: &[u8],
) -> Result<MatrixKeyBackupSession, ProtocolError> {
    let wire: MatrixKeyBackupSessionWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    key_backup_session_from_wire(wire, "key_backup.session")
}

pub fn parse_matrix_key_backup_session_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupSessionParseEnvelope {
    match parse_matrix_key_backup_session(bytes) {
        Ok(value) => MatrixKeyBackupSessionParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupSessionParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_session_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_session_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_session_upload_response(
    bytes: &[u8],
) -> Result<MatrixKeyBackupSessionUploadResponse, ProtocolError> {
    let wire: MatrixKeyBackupSessionUploadResponseWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    Ok(MatrixKeyBackupSessionUploadResponse {
        etag: required_key_backup_string(wire.etag, "key_backup.session_upload.etag")?,
        count: required_key_backup_non_negative_i64(wire.count, "key_backup.session_upload.count")?,
    })
}

pub fn parse_matrix_key_backup_session_upload_response_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupSessionUploadResponseParseEnvelope {
    match parse_matrix_key_backup_session_upload_response(bytes) {
        Ok(value) => MatrixKeyBackupSessionUploadResponseParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupSessionUploadResponseParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_session_upload_response_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_session_upload_response_envelope(
        bytes,
    ))
    .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_error(bytes: &[u8]) -> Result<MatrixKeyBackupError, ProtocolError> {
    let wire: MatrixKeyBackupErrorWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let error = wire
        .error
        .ok_or_else(|| invalid_key_backup_field("key_backup.error"))?;
    Ok(MatrixKeyBackupError {
        status: required_key_backup_non_negative_i64(wire.status, "key_backup.status")?,
        errcode: required_key_backup_string(error.errcode, "key_backup.error.errcode")?,
        error: required_key_backup_string(error.error, "key_backup.error.error")?,
        current_version: optional_key_backup_string(
            error.current_version,
            "key_backup.error.current_version",
        )?,
    })
}

pub fn parse_matrix_key_backup_error_envelope(bytes: &[u8]) -> MatrixKeyBackupErrorParseEnvelope {
    match parse_matrix_key_backup_error(bytes) {
        Ok(value) => MatrixKeyBackupErrorParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupErrorParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_error_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_error_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_owner_scope_gate(
    bytes: &[u8],
) -> Result<MatrixKeyBackupOwnerScopeGate, ProtocolError> {
    let wire: MatrixKeyBackupGateEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let mut checked_steps = Vec::new();
    for (index, step) in key_backup_steps(wire.steps)?.into_iter().enumerate() {
        let id = required_key_backup_string(
            step.id,
            &format!("key_backup.owner_scope.steps.{index}.id"),
        )?;
        let status = step.expected_status.ok_or_else(|| {
            invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.expected_status"
            ))
        })?;
        if status != 404 {
            return Err(invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.expected_status"
            )));
        }
        let error = step.expected_error.ok_or_else(|| {
            invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.expected_error"
            ))
        })?;
        let errcode = required_key_backup_string(
            error.errcode,
            &format!("key_backup.owner_scope.steps.{index}.expected_error.errcode"),
        )?;
        if errcode != "M_NOT_FOUND" {
            return Err(invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.expected_error.errcode"
            )));
        }
        if id.contains("read") && step.must_not_disclose_protected_backup != Some(true) {
            return Err(invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.must_not_disclose_protected_backup"
            )));
        }
        if id.contains("overwrite") && step.must_not_mutate_protected_backup != Some(true) {
            return Err(invalid_key_backup_field(&format!(
                "key_backup.owner_scope.steps.{index}.must_not_mutate_protected_backup"
            )));
        }
        checked_steps.push(id);
    }
    if checked_steps.len() < 4 {
        return Err(invalid_key_backup_field("key_backup.owner_scope.steps"));
    }
    Ok(MatrixKeyBackupOwnerScopeGate {
        owner_scope_enforced: true,
        protected_backup_unchanged: true,
        checked_steps,
        versions_advertisement_widened: false,
    })
}

pub fn parse_matrix_key_backup_owner_scope_gate_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupOwnerScopeGateParseEnvelope {
    match parse_matrix_key_backup_owner_scope_gate(bytes) {
        Ok(value) => MatrixKeyBackupOwnerScopeGateParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupOwnerScopeGateParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_owner_scope_gate_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_owner_scope_gate_envelope(bytes))
        .expect("parse envelope serialization should be infallible")
}

pub fn parse_matrix_key_backup_recovery_gate(
    bytes: &[u8],
) -> Result<MatrixKeyBackupRecoveryGate, ProtocolError> {
    let wire: MatrixKeyBackupGateEventWire =
        serde_json::from_slice(bytes).map_err(|error| ProtocolError::Json(error.to_string()))?;
    let steps = key_backup_steps(wire.steps)?;
    let required_contracts = required_key_backup_string_array(
        wire.required_contracts,
        "key_backup.recovery.required_contracts",
    )?;
    let required_evidence = required_key_backup_string_array(
        wire.required_evidence,
        "key_backup.recovery.required_evidence",
    )?;
    if steps.len() < 6 || steps.iter().any(|step| step.required != Some(true)) {
        return Err(invalid_key_backup_field("key_backup.recovery.steps"));
    }
    Ok(MatrixKeyBackupRecoveryGate {
        logout_relogin_restore: true,
        crypto_stack_required: wire.crypto_stack_required == Some(true),
        local_olm_megolm_allowed: wire.local_olm_megolm_allowed == Some(true),
        required_contracts,
        required_evidence,
        versions_advertisement_widened: false,
    })
}

pub fn parse_matrix_key_backup_recovery_gate_envelope(
    bytes: &[u8],
) -> MatrixKeyBackupRecoveryGateParseEnvelope {
    match parse_matrix_key_backup_recovery_gate(bytes) {
        Ok(value) => MatrixKeyBackupRecoveryGateParseEnvelope {
            ok: true,
            value: Some(value),
            error: None,
        },
        Err(error) => MatrixKeyBackupRecoveryGateParseEnvelope {
            ok: false,
            value: None,
            error: Some(error.to_envelope()),
        },
    }
}

pub fn parse_matrix_key_backup_recovery_gate_json(bytes: &[u8]) -> String {
    serde_json::to_string(&parse_matrix_key_backup_recovery_gate_envelope(bytes))
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

fn invalid_federation_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidFederationField {
        field: field.to_owned(),
    }
}

fn invalid_verification_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidVerificationField {
        field: field.to_owned(),
    }
}

fn invalid_key_backup_field(field: &str) -> ProtocolError {
    ProtocolError::InvalidKeyBackupField {
        field: field.to_owned(),
    }
}

fn required_key_backup_string(value: Option<String>, field: &str) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_key_backup_field(field)),
    }
}

fn optional_key_backup_string(
    value: Option<String>,
    field: &str,
) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if value.is_empty() => Err(invalid_key_backup_field(field)),
        value => Ok(value),
    }
}

fn required_key_backup_non_negative_i64(
    value: Option<i64>,
    field: &str,
) -> Result<u64, ProtocolError> {
    match value {
        Some(value) if value >= 0 => Ok(value as u64),
        _ => Err(invalid_key_backup_field(field)),
    }
}

fn required_key_backup_string_array(
    value: Option<Vec<String>>,
    field: &str,
) -> Result<Vec<String>, ProtocolError> {
    let values = value.ok_or_else(|| invalid_key_backup_field(field))?;
    if values.is_empty() || values.iter().any(String::is_empty) {
        Err(invalid_key_backup_field(field))
    } else {
        Ok(values)
    }
}

fn key_backup_version_from_wire(
    wire: MatrixKeyBackupVersionWire,
    context: &str,
) -> Result<MatrixKeyBackupVersion, ProtocolError> {
    Ok(MatrixKeyBackupVersion {
        version: optional_key_backup_string(wire.version, &format!("{context}.version"))?,
        algorithm: required_key_backup_string(wire.algorithm, &format!("{context}.algorithm"))?,
        auth_data: key_backup_auth_data_from_wire(
            wire.auth_data
                .ok_or_else(|| invalid_key_backup_field(&format!("{context}.auth_data")))?,
            &format!("{context}.auth_data"),
        )?,
    })
}

fn key_backup_auth_data_from_wire(
    wire: MatrixKeyBackupAuthDataWire,
    context: &str,
) -> Result<MatrixKeyBackupAuthData, ProtocolError> {
    Ok(MatrixKeyBackupAuthData {
        public_key: required_key_backup_string(wire.public_key, &format!("{context}.public_key"))?,
        signatures: optional_key_backup_nested_string_map(
            wire.signatures,
            &format!("{context}.signatures"),
        )?,
    })
}

fn key_backup_session_from_wire(
    wire: MatrixKeyBackupSessionWire,
    context: &str,
) -> Result<MatrixKeyBackupSession, ProtocolError> {
    let session_data = wire
        .session_data
        .ok_or_else(|| invalid_key_backup_field(&format!("{context}.session_data")))?;
    if session_data.is_empty() {
        return Err(invalid_key_backup_field(&format!("{context}.session_data")));
    }
    Ok(MatrixKeyBackupSession {
        first_message_index: required_key_backup_non_negative_i64(
            wire.first_message_index,
            &format!("{context}.first_message_index"),
        )?,
        forwarded_count: required_key_backup_non_negative_i64(
            wire.forwarded_count,
            &format!("{context}.forwarded_count"),
        )?,
        is_verified: wire
            .is_verified
            .ok_or_else(|| invalid_key_backup_field(&format!("{context}.is_verified")))?,
        session_data,
    })
}

fn key_backup_steps(
    value: Option<Vec<MatrixKeyBackupGateStepWire>>,
) -> Result<Vec<MatrixKeyBackupGateStepWire>, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_key_backup_field("key_backup.steps")),
    }
}

fn optional_key_backup_nested_string_map(
    value: Option<BTreeMap<String, BTreeMap<String, String>>>,
    field: &str,
) -> Result<BTreeMap<String, BTreeMap<String, String>>, ProtocolError> {
    match value {
        Some(map) => validate_key_backup_nested_string_map(map, field),
        None => Ok(BTreeMap::new()),
    }
}

fn validate_key_backup_nested_string_map(
    map: BTreeMap<String, BTreeMap<String, String>>,
    field: &str,
) -> Result<BTreeMap<String, BTreeMap<String, String>>, ProtocolError> {
    if map.is_empty() {
        return Err(invalid_key_backup_field(field));
    }
    for (outer_key, inner) in &map {
        if outer_key.is_empty() || inner.is_empty() {
            return Err(invalid_key_backup_field(field));
        }
        if inner
            .iter()
            .any(|(inner_key, value)| inner_key.is_empty() || value.is_empty())
        {
            return Err(invalid_key_backup_field(field));
        }
    }
    Ok(map)
}

fn required_verification_borrowed_string<'a>(
    value: &'a str,
    field: &str,
) -> Result<&'a str, ProtocolError> {
    if value.is_empty() {
        Err(invalid_verification_field(field))
    } else {
        Ok(value)
    }
}

fn required_verification_string(
    value: Option<String>,
    field: &str,
) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_verification_field(field)),
    }
}

fn required_verification_string_array(
    value: Option<Vec<String>>,
    field: &str,
) -> Result<Vec<String>, ProtocolError> {
    let values = value.ok_or_else(|| invalid_verification_field(field))?;
    if values.is_empty() || values.iter().any(String::is_empty) {
        Err(invalid_verification_field(field))
    } else {
        Ok(values)
    }
}

fn verification_steps(
    value: Option<Vec<MatrixVerificationStepWire>>,
) -> Result<Vec<MatrixVerificationStepWire>, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_verification_field("verification.steps")),
    }
}

fn optional_cross_signing_key(
    value: Option<MatrixCrossSigningKeyWire>,
    field: &str,
) -> Result<Option<MatrixCrossSigningKey>, ProtocolError> {
    value
        .map(|value| cross_signing_key(value, field))
        .transpose()
}

fn cross_signing_key(
    value: MatrixCrossSigningKeyWire,
    field: &str,
) -> Result<MatrixCrossSigningKey, ProtocolError> {
    let usage = required_verification_string_array(value.usage, &format!("{field}.usage"))?;
    let keys = verification_string_map(value.keys, &format!("{field}.keys"))?;
    let signatures =
        verification_nested_string_map(value.signatures, &format!("{field}.signatures"))?;

    Ok(MatrixCrossSigningKey {
        user_id: required_verification_string(value.user_id, &format!("{field}.user_id"))?,
        usage,
        keys,
        signatures,
    })
}

fn verification_string_map(
    value: Option<BTreeMap<String, String>>,
    field: &str,
) -> Result<BTreeMap<String, String>, ProtocolError> {
    let map = value.ok_or_else(|| invalid_verification_field(field))?;
    if map.is_empty()
        || map
            .iter()
            .any(|(key, value)| key.is_empty() || value.is_empty())
    {
        Err(invalid_verification_field(field))
    } else {
        Ok(map)
    }
}

fn verification_nested_string_map(
    value: Option<BTreeMap<String, BTreeMap<String, String>>>,
    field: &str,
) -> Result<BTreeMap<String, BTreeMap<String, String>>, ProtocolError> {
    let map = value.ok_or_else(|| invalid_verification_field(field))?;
    if map.is_empty() {
        return Err(invalid_verification_field(field));
    }
    for (outer_key, inner) in &map {
        if outer_key.is_empty() || inner.is_empty() {
            return Err(invalid_verification_field(field));
        }
        if inner
            .iter()
            .any(|(inner_key, value)| inner_key.is_empty() || value.is_empty())
        {
            return Err(invalid_verification_field(field));
        }
    }
    Ok(map)
}

fn wrong_device_identity(
    value: Option<MatrixWrongDeviceIdentityWire>,
    field: &str,
) -> Result<MatrixWrongDeviceIdentity, ProtocolError> {
    let value = value.ok_or_else(|| invalid_verification_field(field))?;
    Ok(MatrixWrongDeviceIdentity {
        user_id: required_verification_string(value.user_id, &format!("{field}.user_id"))?,
        device_id: required_verification_string(value.device_id, &format!("{field}.device_id"))?,
        master_key: required_verification_string(value.master_key, &format!("{field}.master_key"))?,
        device_key: required_verification_string(value.device_key, &format!("{field}.device_key"))?,
    })
}

fn required_federation_borrowed_string<'a>(
    value: &'a str,
    field: &str,
) -> Result<&'a str, ProtocolError> {
    let value = value.trim();
    if value.is_empty() {
        Err(invalid_federation_field(field))
    } else {
        Ok(value)
    }
}

fn required_federation_string(value: Option<String>, field: &str) -> Result<String, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(value),
        _ => Err(invalid_federation_field(field)),
    }
}

fn optional_federation_string(
    value: Option<String>,
    field: &str,
) -> Result<Option<String>, ProtocolError> {
    match value {
        Some(value) if !value.is_empty() => Ok(Some(value)),
        Some(_) => Err(invalid_federation_field(field)),
        None => Ok(None),
    }
}

fn required_federation_timestamp(value: Option<i64>, field: &str) -> Result<u64, ProtocolError> {
    match value {
        Some(value) if value >= 0 => Ok(value as u64),
        _ => Err(invalid_federation_field(field)),
    }
}

fn optional_federation_timestamp(
    value: Option<i64>,
    field: &str,
) -> Result<Option<u64>, ProtocolError> {
    match value {
        Some(value) if value >= 0 => Ok(Some(value as u64)),
        Some(_) => Err(invalid_federation_field(field)),
        None => Ok(None),
    }
}

fn required_federation_array(
    value: Option<Vec<Value>>,
    field: &str,
) -> Result<Vec<Value>, ProtocolError> {
    match value {
        Some(value) => Ok(value),
        None => Err(invalid_federation_field(field)),
    }
}

fn required_federation_object_array(
    value: Option<Vec<Value>>,
    field: &str,
) -> Result<Vec<Value>, ProtocolError> {
    federation_object_array(required_federation_array(value, field)?, field)
}

fn federation_object_array(value: Vec<Value>, field: &str) -> Result<Vec<Value>, ProtocolError> {
    if value.iter().all(Value::is_object) {
        Ok(value)
    } else {
        Err(invalid_federation_field(field))
    }
}

fn required_federation_object(value: Option<Value>, field: &str) -> Result<Value, ProtocolError> {
    match value {
        Some(value) if value.is_object() => Ok(value),
        _ => Err(invalid_federation_field(field)),
    }
}

fn split_federation_server_name(server_name: &str) -> Result<(String, Option<u16>), ProtocolError> {
    let (host, port) = match server_name.rsplit_once(':') {
        Some((host, port)) if !host.contains(':') => {
            let port = port
                .parse::<u16>()
                .map_err(|_| invalid_federation_field("federation.server_name.port"))?;
            (host, Some(port))
        }
        _ => (server_name, None),
    };
    if host.is_empty() || host.starts_with('.') || host.ends_with('.') {
        return Err(invalid_federation_field("federation.server_name.host"));
    }
    Ok((host.to_owned(), port))
}

fn required_federation_key_id(key_id: &str, field: &str) -> Result<(), ProtocolError> {
    if key_id.is_empty() || !key_id.contains(':') {
        Err(invalid_federation_field(field))
    } else {
        Ok(())
    }
}

fn federation_signatures(
    value: Option<BTreeMap<String, BTreeMap<String, String>>>,
    field: &str,
) -> Result<BTreeMap<String, BTreeMap<String, String>>, ProtocolError> {
    let signatures = value.ok_or_else(|| invalid_federation_field(field))?;
    if signatures.is_empty() {
        return Err(invalid_federation_field(field));
    }
    for (server_name, signatures) in &signatures {
        parse_matrix_federation_server_name(server_name)?;
        if signatures.is_empty() {
            return Err(invalid_federation_field(field));
        }
        for (key_id, signature) in signatures {
            required_federation_key_id(key_id, field)?;
            required_federation_borrowed_string(signature, field)?;
        }
    }
    Ok(signatures)
}

fn matrix_federation_signing_key_from_wire(
    wire: MatrixFederationSigningKeyWire,
) -> Result<MatrixFederationSigningKey, ProtocolError> {
    let server_name =
        required_federation_string(wire.server_name, "federation.signing_key.server_name")?;
    parse_matrix_federation_server_name(&server_name)?;
    let verify_keys = wire
        .verify_keys
        .ok_or_else(|| invalid_federation_field("federation.signing_key.verify_keys"))?
        .into_iter()
        .map(|(key_id, key)| {
            required_federation_key_id(&key_id, "federation.signing_key.verify_keys")?;
            Ok((
                key_id,
                MatrixFederationVerifyKey {
                    key: required_federation_string(
                        key.key,
                        "federation.signing_key.verify_keys.key",
                    )?,
                },
            ))
        })
        .collect::<Result<BTreeMap<_, _>, _>>()?;
    if verify_keys.is_empty() {
        return Err(invalid_federation_field(
            "federation.signing_key.verify_keys",
        ));
    }
    let old_verify_keys = wire
        .old_verify_keys
        .into_iter()
        .map(|(key_id, key)| {
            required_federation_key_id(&key_id, "federation.signing_key.old_verify_keys")?;
            Ok((
                key_id,
                MatrixFederationOldVerifyKey {
                    expired_ts: required_federation_timestamp(
                        key.expired_ts,
                        "federation.signing_key.old_verify_keys.expired_ts",
                    )?,
                    key: required_federation_string(
                        key.key,
                        "federation.signing_key.old_verify_keys.key",
                    )?,
                },
            ))
        })
        .collect::<Result<BTreeMap<_, _>, _>>()?;

    Ok(MatrixFederationSigningKey {
        server_name,
        verify_keys,
        old_verify_keys,
        valid_until_ts: required_federation_timestamp(
            wire.valid_until_ts,
            "federation.signing_key.valid_until_ts",
        )?,
        signatures: federation_signatures(wire.signatures, "federation.signing_key.signatures")?,
    })
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
                "SPEC-037", "SPEC-038", "SPEC-039", "SPEC-040", "SPEC-053", "SPEC-054", "SPEC-055",
                "SPEC-056"
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
    fn parses_spec_054_verification_cross_signing_and_wrong_device_vectors() {
        let sas = read_spec_vector(
            "test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json",
        );
        let parsed_sas = parse_matrix_verification_sas_flow(sas["event"].to_string().as_bytes())
            .expect("SPEC-054 SAS verification flow should parse");
        assert_eq!(sas["contract"], "SPEC-054");
        assert_eq!(parsed_sas.transaction_id, "verif-txn-1");
        assert_eq!(
            parsed_sas.event_types,
            vec![
                "m.key.verification.request",
                "m.key.verification.ready",
                "m.key.verification.start",
                "m.key.verification.accept",
                "m.key.verification.key",
                "m.key.verification.mac"
            ]
        );
        assert!(parsed_sas.verified);
        assert!(!parsed_sas.local_sas_allowed);
        assert!(!parsed_sas.versions_advertisement_widened);

        let cancel =
            read_spec_vector("test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json");
        let parsed_cancel =
            parse_matrix_verification_cancel(cancel["event"].to_string().as_bytes())
                .expect("SPEC-054 verification cancel should parse");
        assert_eq!(parsed_cancel.transaction_id, "verif-txn-mismatch");
        assert_eq!(parsed_cancel.code, "m.mismatched_sas");
        assert!(!parsed_cancel.verified);

        let lifecycle =
            read_spec_vector("test-vectors/messaging/matrix-cross-signing-key-lifecycle.json");
        let steps = lifecycle["event"]["steps"]
            .as_array()
            .expect("cross-signing lifecycle should contain steps");
        let parsed_upload = parse_matrix_cross_signing_device_signing_upload(
            steps[0]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-054 cross-signing public keys should parse");
        assert_eq!(
            parsed_upload
                .master_key
                .as_ref()
                .expect("master key should be present")
                .usage,
            vec!["master"]
        );
        assert!(parsed_upload.self_signing_key.is_some());
        assert!(parsed_upload.user_signing_key.is_some());
        let parsed_signatures =
            parse_matrix_cross_signing_signature_upload(steps[2]["body"].to_string().as_bytes())
                .expect("SPEC-054 cross-signing signature upload should parse");
        assert!(parsed_signatures
            .signed_objects
            .get("@alice:example.test")
            .expect("signed user should be present")
            .contains_key("ALICE2"));

        let invalid_signature =
            read_spec_vector("test-vectors/messaging/matrix-cross-signing-invalid-signature.json");
        let parsed_invalid_signature = parse_matrix_cross_signing_invalid_signature_failure(
            invalid_signature["expected"].to_string().as_bytes(),
        )
        .expect("SPEC-054 invalid signature failure should parse");
        assert_eq!(parsed_invalid_signature.status, 400);
        assert_eq!(parsed_invalid_signature.errcode, "M_INVALID_SIGNATURE");

        let missing_token =
            read_spec_vector("test-vectors/messaging/matrix-cross-signing-missing-token.json");
        let parsed_missing_token = parse_matrix_cross_signing_missing_token_gate(
            missing_token["event"].to_string().as_bytes(),
        )
        .expect("SPEC-054 missing token gate should parse");
        assert!(parsed_missing_token.protected_key_operations_require_token);
        assert!(parsed_missing_token.semantic_errors_suppressed_until_authenticated);
        assert!(parsed_missing_token.auth_precedes_signature_validation);
        assert_eq!(parsed_missing_token.errcode, "M_MISSING_TOKEN");
        assert_eq!(parsed_missing_token.operations.len(), 3);

        let wrong_device =
            read_spec_vector("test-vectors/messaging/matrix-wrong-device-failure-gate.json");
        let parsed_wrong_device =
            parse_matrix_wrong_device_failure_gate(wrong_device["event"].to_string().as_bytes())
                .expect("SPEC-054 wrong-device gate should parse");
        assert_eq!(parsed_wrong_device.cancel_code, "m.key_mismatch");
        assert!(!parsed_wrong_device.device_verified);
        assert!(!parsed_wrong_device.outbound_session_shared);
        assert!(parsed_wrong_device.requires_user_reverification);
        assert!(parsed_wrong_device
            .required_evidence
            .contains(&"trusted_fingerprint".to_owned()));

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(manifest
            .supported_specs
            .iter()
            .any(|spec| spec == "SPEC-054"));
    }

    #[test]
    fn parses_spec_053_key_backup_metadata_vectors() {
        let lifecycle =
            read_spec_vector("test-vectors/messaging/matrix-key-backup-version-lifecycle.json");
        assert_eq!(lifecycle["contract"], "SPEC-053");
        let steps = lifecycle["event"]["steps"]
            .as_array()
            .expect("key backup lifecycle should contain steps");
        let parsed_create_response = parse_matrix_key_backup_version_create_response(
            steps[0]["expected_body_contains"].to_string().as_bytes(),
        )
        .expect("SPEC-053 key backup create response should parse");
        assert_eq!(parsed_create_response.version, "1");
        let parsed_create_body =
            parse_matrix_key_backup_version(steps[0]["body"].to_string().as_bytes())
                .expect("SPEC-053 key backup create body should parse");
        assert_eq!(
            parsed_create_body.algorithm,
            "m.megolm_backup.v1.curve25519-aes-sha2"
        );
        assert_eq!(
            parsed_create_body.auth_data.public_key,
            "backup-public-key-1"
        );
        let parsed_current = parse_matrix_key_backup_version(
            steps[1]["expected_body_contains"].to_string().as_bytes(),
        )
        .expect("SPEC-053 key backup current version should parse");
        assert_eq!(parsed_current.version.as_deref(), Some("1"));
        let parsed_update =
            parse_matrix_key_backup_version(steps[2]["body"].to_string().as_bytes())
                .expect("SPEC-053 key backup update body should parse");
        assert_eq!(
            parsed_update
                .auth_data
                .signatures
                .get("@alice:example.test")
                .and_then(|signatures| signatures.get("ed25519:DEVICE2"))
                .map(String::as_str),
            Some("signature-backup-2")
        );

        let restore = read_spec_vector(
            "test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json",
        );
        assert_eq!(restore["contract"], "SPEC-053");
        let restore_steps = restore["event"]["steps"]
            .as_array()
            .expect("key backup restore vector should contain steps");
        let parsed_session =
            parse_matrix_key_backup_session(restore_steps[0]["body"].to_string().as_bytes())
                .expect("SPEC-053 key backup upload session should parse");
        assert_eq!(parsed_session.first_message_index, 1);
        assert_eq!(parsed_session.forwarded_count, 0);
        assert!(parsed_session.is_verified);
        assert_eq!(
            parsed_session.session_data["ciphertext"],
            "backup-ciphertext"
        );
        let parsed_upload_response = parse_matrix_key_backup_session_upload_response(
            restore_steps[0]["expected_body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("SPEC-053 key backup upload response should parse");
        assert_eq!(parsed_upload_response.etag, "etag-1");
        assert_eq!(parsed_upload_response.count, 1);
        let parsed_restore = parse_matrix_key_backup_session(
            restore_steps[1]["expected_body_contains"]
                .to_string()
                .as_bytes(),
        )
        .expect("SPEC-053 key backup restore body should parse");
        assert_eq!(parsed_restore.session_data["mac"], "backup-mac");

        let wrong_version =
            read_spec_vector("test-vectors/messaging/matrix-key-backup-wrong-version.json");
        let parsed_wrong_version =
            parse_matrix_key_backup_error(wrong_version["expected"].to_string().as_bytes())
                .expect("SPEC-053 wrong version error should parse");
        assert_eq!(parsed_wrong_version.status, 403);
        assert_eq!(parsed_wrong_version.errcode, "M_WRONG_ROOM_KEYS_VERSION");
        assert_eq!(parsed_wrong_version.current_version.as_deref(), Some("1"));

        let missing_session = read_spec_vector(
            "test-vectors/messaging/matrix-key-backup-restore-missing-session.json",
        );
        let parsed_missing_session =
            parse_matrix_key_backup_error(missing_session["expected"].to_string().as_bytes())
                .expect("SPEC-053 missing session error should parse");
        assert_eq!(parsed_missing_session.status, 404);
        assert_eq!(parsed_missing_session.errcode, "M_NOT_FOUND");

        let owner_scope =
            read_spec_vector("test-vectors/messaging/matrix-key-backup-owner-scope.json");
        let parsed_owner_scope =
            parse_matrix_key_backup_owner_scope_gate(owner_scope["event"].to_string().as_bytes())
                .expect("SPEC-053 owner scope gate should parse");
        assert!(parsed_owner_scope.owner_scope_enforced);
        assert!(parsed_owner_scope.protected_backup_unchanged);
        assert_eq!(parsed_owner_scope.checked_steps.len(), 4);
        assert!(!parsed_owner_scope.versions_advertisement_widened);

        let recovery_gate = read_spec_vector(
            "test-vectors/messaging/matrix-key-backup-logout-relogin-recovery-gate.json",
        );
        let parsed_recovery_gate =
            parse_matrix_key_backup_recovery_gate(recovery_gate["event"].to_string().as_bytes())
                .expect("SPEC-053 logout/relogin recovery gate should parse");
        assert!(parsed_recovery_gate.logout_relogin_restore);
        assert!(parsed_recovery_gate.crypto_stack_required);
        assert!(!parsed_recovery_gate.local_olm_megolm_allowed);
        assert_eq!(
            parsed_recovery_gate.required_contracts,
            vec!["SPEC-050", "SPEC-052", "SPEC-053"]
        );
        assert!(parsed_recovery_gate
            .required_evidence
            .contains(&"per_step_pass_fail".to_owned()));
        assert!(!parsed_recovery_gate.versions_advertisement_widened);

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(manifest
            .supported_specs
            .iter()
            .any(|spec| spec == "SPEC-053"));
    }

    #[test]
    fn parses_spec_056_federation_transaction_join_and_invite_vectors() {
        let transaction =
            read_spec_vector("test-vectors/events/matrix-federation-send-transaction-basic.json");
        let parsed_transaction = parse_matrix_federation_transaction(
            transaction["request"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-056 transaction body should parse");
        assert_eq!(parsed_transaction.origin, "remote.example.test");
        assert_eq!(parsed_transaction.pdus.len(), 1);
        assert_eq!(parsed_transaction.edus.len(), 1);
        assert!(parse_matrix_federation_transaction(
            "{\"origin\":\"remote.example.test\",\"origin_server_ts\":1778408851000,\"pdus\":[\"bad\"],\"edus\":[]}"
                .as_bytes()
        )
        .is_err());
        assert!(parse_matrix_federation_transaction(
            "{\"origin\":\"remote.example.test\",\"origin_server_ts\":1778408851000,\"pdus\":[],\"edus\":[\"bad\"]}"
                .as_bytes()
        )
        .is_err());
        let parsed_transaction_response = parse_matrix_federation_transaction_response(
            transaction["response"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-056 transaction response should parse");
        assert!(parsed_transaction_response
            .pdus
            .get("$event1:remote.example.test")
            .expect("accepted event should be present")
            .error
            .is_none());

        let failed_transaction = read_spec_vector(
            "test-vectors/events/matrix-federation-send-transaction-pdu-failure.json",
        );
        let parsed_failure = parse_matrix_federation_transaction_response(
            failed_transaction["response"]["body"]
                .to_string()
                .as_bytes(),
        )
        .expect("SPEC-056 failed PDU response should parse");
        assert_eq!(
            parsed_failure
                .pdus
                .get("$bad:remote.example.test")
                .and_then(|result| result.error.as_deref()),
            Some("Event failed authorization")
        );

        let join =
            read_spec_vector("test-vectors/events/matrix-federation-make-send-join-basic.json");
        let steps = join["event"]["steps"]
            .as_array()
            .expect("join vector should contain steps");
        let make_join_response =
            parse_matrix_federation_make_join_response(steps[1]["body"].to_string().as_bytes())
                .expect("SPEC-056 make_join response should parse");
        assert_eq!(make_join_response.room_version, "12");
        assert_eq!(make_join_response.event["content"]["membership"], "join");

        let send_join_response =
            parse_matrix_federation_send_join_response(steps[4]["body"].to_string().as_bytes())
                .expect("SPEC-056 send_join response should parse");
        assert_eq!(send_join_response.origin, "example.test");
        assert_eq!(send_join_response.state.len(), 1);
        assert_eq!(send_join_response.auth_chain.len(), 1);
        assert_eq!(send_join_response.event["content"]["membership"], "join");

        let invite = read_spec_vector("test-vectors/events/matrix-federation-invite-v2-basic.json");
        let parsed_invite_request = parse_matrix_federation_invite_request(
            invite["request"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-056 invite request should parse");
        assert_eq!(parsed_invite_request.room_version, "12");
        assert_eq!(
            parsed_invite_request.event["content"]["membership"],
            "invite"
        );
        let parsed_invite_response = parse_matrix_federation_invite_response(
            invite["response"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-056 invite response should parse");
        assert_eq!(
            parsed_invite_response.event["signatures"]["remote.example.test"]["ed25519:auto1"],
            "base64-remote-signature"
        );

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(manifest
            .supported_specs
            .iter()
            .any(|spec| spec == "SPEC-056"));
    }

    #[test]
    fn parses_spec_055_federation_discovery_and_signing_key_vectors() {
        let well_known =
            read_spec_vector("test-vectors/core/matrix-federation-well-known-server-basic.json");
        let parsed_well_known = parse_matrix_federation_well_known_server(
            well_known["response"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-055 well-known response should parse");
        assert_eq!(
            parsed_well_known.delegated_server_name,
            "delegated.example.test:8448"
        );
        assert_eq!(parsed_well_known.host, "delegated.example.test");
        assert_eq!(parsed_well_known.port, Some(8448));
        assert!(parse_matrix_federation_well_known_server(
            "{\"m.server\":\"https://bad.example.test\"}".as_bytes()
        )
        .is_err());

        let signing_key =
            read_spec_vector("test-vectors/core/matrix-federation-signing-key-basic.json");
        let parsed_signing_key = parse_matrix_federation_signing_key(
            signing_key["response"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-055 signing key response should parse");
        assert_eq!(parsed_signing_key.server_name, "example.test");
        assert_eq!(
            parsed_signing_key
                .verify_keys
                .get("ed25519:auto1")
                .expect("current key should be present")
                .key,
            "VGhpcyBpcyBhIHRlc3QgcHVibGljIHZlcmlmeSBrZXk"
        );
        assert!(parsed_signing_key
            .old_verify_keys
            .contains_key("ed25519:old1"));
        assert_eq!(parsed_signing_key.valid_until_ts, 1779011408000);

        let key_query =
            read_spec_vector("test-vectors/core/matrix-federation-key-query-basic.json");
        let parsed_key_query_request = parse_matrix_federation_key_query_request(
            key_query["request"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-055 key query request should parse");
        assert_eq!(
            parsed_key_query_request.server_keys["example.test"]["ed25519:auto1"]
                .minimum_valid_until_ts,
            Some(1779011408000)
        );
        let parsed_key_query_response = parse_matrix_federation_key_query_response(
            key_query["response"]["body"].to_string().as_bytes(),
        )
        .expect("SPEC-055 key query response should parse");
        assert_eq!(parsed_key_query_response.server_keys.len(), 1);
        assert!(parsed_key_query_response.server_keys[0]
            .signatures
            .contains_key("notary.example.test"));

        let failure = read_spec_vector(
            "test-vectors/core/matrix-federation-destination-resolution-failure.json",
        );
        let parsed_failure =
            parse_matrix_federation_destination_resolution_failure(failure.to_string().as_bytes())
                .expect("SPEC-055 destination failure evidence should parse");
        assert_eq!(parsed_failure.server_name, "broken.example.test");
        assert_eq!(
            parsed_failure.stages,
            vec![
                "well_known",
                "srv_matrix_fed",
                "srv_matrix_deprecated",
                "address_records",
                "failure_cache"
            ]
        );
        assert!(!parsed_failure.destination_resolved);
        assert!(!parsed_failure.federation_request_sent);
        assert!(parsed_failure.backoff_recorded);

        let manifest = artifact_manifest_for_binding_kinds(&["wasm"]);
        assert!(manifest
            .supported_specs
            .iter()
            .any(|spec| spec == "SPEC-055"));
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
