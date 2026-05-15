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
  "SPEC-045",
  "SPEC-046",
  "SPEC-047",
  "SPEC-048",
  "SPEC-049",
  "SPEC-051",
  "SPEC-053",
  "SPEC-054",
  "SPEC-055",
  "SPEC-056",
  "SPEC-068",
  "SPEC-069",
  "SPEC-085",
  "SPEC-090",
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
  parseMatrixFederationDestinationResolutionFailureJson(responseBody: string): string;
  parseMatrixFederationKeyQueryRequestJson(responseBody: string): string;
  parseMatrixFederationKeyQueryResponseJson(responseBody: string): string;
  parseMatrixFederationMakeJoinResponseJson(responseBody: string): string;
  parseMatrixFederationServerNameJson(serverName: string): string;
  parseMatrixFederationSendJoinResponseJson(responseBody: string): string;
  parseMatrixFederationSigningKeyJson(responseBody: string): string;
  parseMatrixFederationTransactionJson(responseBody: string): string;
  parseMatrixFederationTransactionResponseJson(responseBody: string): string;
  parseMatrixFederationWellKnownServerJson(responseBody: string): string;
  parseMatrixVerificationSasFlowJson(responseBody: string): string;
  parseMatrixVerificationCancelJson(responseBody: string): string;
  parseMatrixCrossSigningDeviceSigningUploadJson(responseBody: string): string;
  parseMatrixCrossSigningSignatureUploadJson(responseBody: string): string;
  parseMatrixCrossSigningInvalidSignatureFailureJson(responseBody: string): string;
  parseMatrixCrossSigningMissingTokenGateJson(responseBody: string): string;
  parseMatrixWrongDeviceFailureGateJson(responseBody: string): string;
  parseMatrixKeysUploadRequestJson(responseBody: string): string;
  parseMatrixKeysUploadResponseJson(responseBody: string): string;
  parseMatrixKeysClaimRequestJson(responseBody: string): string;
  parseMatrixKeysClaimResponseJson(responseBody: string): string;
  parseMatrixDeviceKeyErrorJson(responseBody: string): string;
  parseMatrixDeviceKeyQueryRequestJson(responseBody: string): string;
  parseMatrixDeviceKeyQueryResponseJson(responseBody: string): string;
  parseMatrixPublicRoomsRequestJson(responseBody: string): string;
  parseMatrixPublicRoomsResponseJson(responseBody: string): string;
  parseMatrixDirectoryVisibilityJson(responseBody: string): string;
  parseMatrixRoomAliasesJson(responseBody: string): string;
  parseMatrixInviteRequestJson(responseBody: string): string;
  parseMatrixInviteRoomJson(responseBody: string): string;
  parseMatrixRoomDirectoryErrorJson(responseBody: string): string;
  parseMatrixModerationRequestJson(responseBody: string): string;
  parseMatrixRedactionRequestJson(responseBody: string): string;
  parseMatrixRedactionResponseJson(responseBody: string): string;
  parseMatrixReportRequestJson(responseBody: string): string;
  parseMatrixAccountModerationCapabilityJson(responseBody: string): string;
  parseMatrixAdminAccountModerationStatusJson(responseBody: string): string;
  parseMatrixModerationErrorJson(responseBody: string): string;
  parseMatrixKeyBackupVersionCreateResponseJson(responseBody: string): string;
  parseMatrixKeyBackupVersionJson(responseBody: string): string;
  parseMatrixKeyBackupSessionJson(responseBody: string): string;
  parseMatrixKeyBackupSessionUploadResponseJson(responseBody: string): string;
  parseMatrixKeyBackupErrorJson(responseBody: string): string;
  parseMatrixKeyBackupOwnerScopeGateJson(responseBody: string): string;
  parseMatrixKeyBackupRecoveryGateJson(responseBody: string): string;
  parseMatrixLoginFlowsJson(responseBody: string): string;
  parseMatrixLoginSessionJson(responseBody: string): string;
  parseMatrixAuthMetadataJson(responseBody: string): string;
  buildMatrixAccountManagementRedirectJson(responseBody: string): string;
  reconcileMatrixAccountManagementDeviceDeleteJson(responseBody: string): string;
  parseMatrixMediaContentUriJson(contentUri: string): string;
  parseMatrixMediaUploadResponseJson(responseBody: string): string;
  parseMatrixMessagesResponseJson(responseBody: string): string;
  parseMatrixEventRetrievalRequestDescriptorJson(responseBody: string): string;
  parseMatrixJoinedMembersResponseJson(responseBody: string): string;
  parseMatrixMembersResponseJson(responseBody: string): string;
  parseMatrixTimestampToEventResponseJson(responseBody: string): string;
  parseMatrixRelationsRequestDescriptorJson(responseBody: string): string;
  parseMatrixRelationChunkResponseJson(responseBody: string): string;
  parseMatrixThreadRootsResponseJson(responseBody: string): string;
  parseMatrixReactionEventJson(responseBody: string): string;
  parseMatrixEditEventJson(responseBody: string): string;
  parseMatrixReplyEventJson(responseBody: string): string;
  parseMatrixProfileResponseJson(responseBody: string): string;
  parseMatrixProfileFieldUpdateRequestJson(responseBody: string): string;
  parseMatrixAccountDataContentJson(responseBody: string): string;
  parseMatrixRoomTagJson(responseBody: string): string;
  parseMatrixRoomTagsJson(responseBody: string): string;
  parseMatrixTypingRequestJson(responseBody: string): string;
  parseMatrixTypingContentJson(responseBody: string): string;
  parseMatrixReceiptRequestJson(responseBody: string): string;
  parseMatrixReceiptContentJson(responseBody: string): string;
  parseMatrixReadMarkersRequestJson(responseBody: string): string;
  parseMatrixFullyReadContentJson(responseBody: string): string;
  parseMatrixFilterDefinitionJson(responseBody: string): string;
  parseMatrixFilterCreateResponseJson(responseBody: string): string;
  parseMatrixPresenceRequestJson(responseBody: string): string;
  parseMatrixPresenceContentJson(responseBody: string): string;
  parseMatrixPresenceEventJson(responseBody: string): string;
  parseMatrixCapabilitiesResponseJson(responseBody: string): string;
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

export interface MatrixAuthMetadata {
  issuer?: string;
  account_management_uri?: string;
  account_management_actions_supported: string[];
}

export interface MatrixAccountManagementRedirect {
  uri: string;
  action?: string;
  device_id?: string;
  generic_fallback: boolean;
}

export interface MatrixAccountManagementReconciliation {
  deleted_device_id: string;
  missing_device_id: boolean;
  mark_delete_complete: boolean;
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

export interface MatrixEventRetrievalRequestDescriptor {
  method: string;
  path: string;
  requires_auth: boolean;
  response_parser?: string;
  unsupported_reason?: string;
  adopted_runtime_behavior: boolean;
}

export interface MatrixJoinedMember {
  display_name?: string;
  avatar_url?: string;
}

export interface MatrixJoinedMembersResponse {
  joined: Record<string, MatrixJoinedMember>;
}

export interface MatrixMembersResponse {
  chunk: MatrixClientEvent[];
}

export interface MatrixTimestampToEventResponse {
  event_id: string;
  origin_server_ts: number;
}

export interface MatrixRelationsRequestDescriptor {
  method: string;
  path: string;
  requires_auth: boolean;
  response_parser: "relation_chunk" | "thread_roots";
  adopted_runtime_behavior: boolean;
}

export interface MatrixRelationChunkResponse {
  chunk: MatrixClientEvent[];
  next_batch?: string;
  prev_batch?: string;
}

export interface MatrixThreadRootsResponse {
  chunk: MatrixClientEvent[];
  next_batch?: string;
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

export interface MatrixProfileResponse {
  fields: Record<string, unknown>;
}

export interface MatrixProfileFieldUpdateRequest {
  key_name: string;
  value: unknown;
}

export interface MatrixAccountDataContent {
  content: Record<string, unknown>;
}

export interface MatrixRoomTag {
  order?: number;
}

export interface MatrixRoomTags {
  tags: Record<string, MatrixRoomTag>;
}

export interface MatrixTypingRequest {
  typing: boolean;
  timeout?: number;
}

export interface MatrixTypingContent {
  user_ids: string[];
}

export interface MatrixReceiptRequest {
  thread_id?: string;
}

export interface MatrixReceiptMetadata {
  ts?: number;
  thread_id?: string;
}

export interface MatrixReceiptContent {
  receipts: Record<
    string,
    Record<string, Record<string, MatrixReceiptMetadata>>
  >;
}

export interface MatrixReadMarkersRequest {
  "m.fully_read"?: string;
  "m.read"?: string;
  "m.read.private"?: string;
}

export interface MatrixFullyReadContent {
  event_id: string;
}

export interface MatrixFilterEvent {
  limit?: number;
  types?: string[];
}

export interface MatrixRoomFilter {
  timeline?: MatrixFilterEvent;
  ephemeral?: MatrixFilterEvent;
  account_data?: MatrixFilterEvent;
}

export interface MatrixFilterDefinition {
  event_fields?: string[];
  event_format?: string;
  presence?: MatrixFilterEvent;
  room?: MatrixRoomFilter;
}

export interface MatrixFilterCreateResponse {
  filter_id: string;
}

export interface MatrixPresenceRequest {
  presence: string;
  status_msg?: string;
}

export interface MatrixPresenceContent {
  presence: string;
  last_active_ago?: number;
  currently_active?: boolean;
  status_msg?: string;
}

export interface MatrixPresenceEvent {
  sender: string;
  type: "m.presence";
  content: MatrixPresenceContent;
}

export interface MatrixCapabilitiesResponse {
  capabilities: Record<string, unknown>;
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

export interface MatrixFederationServerName {
  server_name: string;
  host: string;
  port?: number;
}

export interface MatrixFederationWellKnownServer {
  delegated_server_name: string;
  host: string;
  port?: number;
}

export interface MatrixFederationVerifyKey {
  key: string;
}

export interface MatrixFederationOldVerifyKey {
  expired_ts: number;
  key: string;
}

export interface MatrixFederationSigningKey {
  server_name: string;
  verify_keys: Record<string, MatrixFederationVerifyKey>;
  old_verify_keys: Record<string, MatrixFederationOldVerifyKey>;
  valid_until_ts: number;
  signatures: Record<string, Record<string, string>>;
}

export interface MatrixFederationKeyQueryCriteria {
  minimum_valid_until_ts?: number;
}

export interface MatrixFederationKeyQueryRequest {
  server_keys: Record<
    string,
    Record<string, MatrixFederationKeyQueryCriteria>
  >;
}

export interface MatrixFederationKeyQueryResponse {
  server_keys: MatrixFederationSigningKey[];
}

export interface MatrixFederationDestinationResolutionFailure {
  server_name: string;
  stages: string[];
  destination_resolved: boolean;
  federation_request_sent: boolean;
  backoff_recorded: boolean;
}

export interface MatrixVerificationSasFlow {
  transaction_id: string;
  transport: string;
  event_types: string[];
  verified: boolean;
  local_sas_allowed: boolean;
  versions_advertisement_widened: boolean;
}

export interface MatrixVerificationCancel {
  transaction_id: string;
  code: string;
  reason: string;
  verified: boolean;
  versions_advertisement_widened: boolean;
}

export interface MatrixCrossSigningKey {
  user_id: string;
  usage: string[];
  keys: Record<string, string>;
  signatures: Record<string, Record<string, string>>;
}

export interface MatrixCrossSigningDeviceSigningUpload {
  master_key?: MatrixCrossSigningKey;
  self_signing_key?: MatrixCrossSigningKey;
  user_signing_key?: MatrixCrossSigningKey;
}

export interface MatrixCrossSigningSignatureUpload {
  signed_objects: Record<string, Record<string, Record<string, unknown>>>;
}

export interface MatrixCrossSigningInvalidSignatureFailure {
  status: number;
  errcode: string;
  error: string;
}

export interface MatrixCrossSigningMissingTokenGate {
  protected_key_operations_require_token: boolean;
  semantic_errors_suppressed_until_authenticated: boolean;
  auth_precedes_signature_validation: boolean;
  operations: string[];
  errcode: string;
}

export interface MatrixWrongDeviceIdentity {
  user_id: string;
  device_id: string;
  master_key: string;
  device_key: string;
}

export interface MatrixWrongDeviceFailureGate {
  trusted_identity: MatrixWrongDeviceIdentity;
  observed_identity: MatrixWrongDeviceIdentity;
  required_steps: string[];
  required_evidence: string[];
  cancel_code: string;
  device_verified: boolean;
  outbound_session_shared: boolean;
  requires_user_reverification: boolean;
  versions_advertisement_widened: boolean;
}

export interface MatrixDeviceKeysUploadDevice {
  user_id: string;
  device_id: string;
  algorithms: string[];
  keys: Record<string, string>;
  signatures: Record<string, Record<string, string>>;
}

export interface MatrixSignedCurve25519Key {
  key: string;
  fallback: boolean;
  signatures: Record<string, Record<string, string>>;
}

export interface MatrixKeysUploadRequest {
  device_keys?: MatrixDeviceKeysUploadDevice;
  one_time_keys: Record<string, MatrixSignedCurve25519Key>;
  fallback_keys: Record<string, MatrixSignedCurve25519Key>;
  private_key_material_returned: boolean;
}

export interface MatrixKeysUploadResponse {
  one_time_key_counts: Record<string, number>;
  private_key_material_returned: boolean;
}

export interface MatrixKeysClaimRequest {
  one_time_keys: Record<string, Record<string, string>>;
}

export interface MatrixKeysClaimResponse {
  failures: Record<string, Record<string, string>>;
  one_time_keys: Record<
    string,
    Record<string, Record<string, MatrixSignedCurve25519Key>>
  >;
  fallback_key_returned: boolean;
}

export interface MatrixDeviceKeyError {
  status: number;
  errcode: string;
  error: string;
}

export interface MatrixDeviceKeyQueryRequest {
  device_keys: Record<string, string[]>;
  timeout?: number;
}

export interface MatrixDeviceKeyQueryResponse {
  failures: Record<string, Record<string, string>>;
  device_keys: Record<string, Record<string, MatrixDeviceKeysUploadDevice>>;
  private_key_material_returned: boolean;
  trust_decision_made: boolean;
}

export interface MatrixPublicRoomsRequest {
  limit?: number;
  since?: string;
  server?: string;
  generic_search_term?: string;
  include_all_networks?: boolean;
  third_party_instance_id?: string;
}

export interface MatrixPublicRoom {
  room_id: string;
  num_joined_members: number;
  world_readable: boolean;
  guest_can_join: boolean;
  name?: string;
  topic?: string;
  canonical_alias?: string;
  avatar_url?: string;
  join_rule?: string;
  room_type?: string;
}

export interface MatrixPublicRoomsResponse {
  chunk: MatrixPublicRoom[];
  next_batch?: string;
  prev_batch?: string;
  total_room_count_estimate?: number;
}

export interface MatrixDirectoryVisibility {
  visibility: string;
}

export interface MatrixRoomAliases {
  aliases: string[];
}

export interface MatrixInviteRequest {
  user_id: string;
  reason?: string;
}

export interface MatrixInviteStateEvent {
  type: string;
  sender?: string;
  state_key: string;
  content: Record<string, unknown>;
}

export interface MatrixInviteRoom {
  room_id: string;
  events: MatrixInviteStateEvent[];
}

export interface MatrixRoomDirectoryError {
  status: number;
  errcode: string;
  error: string;
}

export interface MatrixModerationRequest {
  user_id: string;
  reason?: string;
}

export interface MatrixRedactionRequest {
  reason?: string;
}

export interface MatrixRedactionResponse {
  event_id: string;
}

export interface MatrixReportRequest {
  reason?: string;
}

export interface MatrixAccountModerationCapability {
  lock: boolean;
  suspend: boolean;
}

export interface MatrixAdminAccountModerationStatus {
  locked?: boolean;
  suspended?: boolean;
}

export interface MatrixModerationError {
  status: number;
  errcode: string;
  error: string;
}

export interface MatrixKeyBackupAuthData {
  public_key: string;
  signatures: Record<string, Record<string, string>>;
}

export interface MatrixKeyBackupVersionCreateResponse {
  version: string;
}

export interface MatrixKeyBackupVersion {
  version?: string;
  algorithm: string;
  auth_data: MatrixKeyBackupAuthData;
}

export interface MatrixKeyBackupSession {
  first_message_index: number;
  forwarded_count: number;
  is_verified: boolean;
  session_data: Record<string, unknown>;
}

export interface MatrixKeyBackupSessionUploadResponse {
  etag: string;
  count: number;
}

export interface MatrixKeyBackupError {
  status: number;
  errcode: string;
  error: string;
  current_version?: string;
}

export interface MatrixKeyBackupOwnerScopeGate {
  owner_scope_enforced: boolean;
  protected_backup_unchanged: boolean;
  checked_steps: string[];
  versions_advertisement_widened: boolean;
}

export interface MatrixKeyBackupRecoveryGate {
  logout_relogin_restore: boolean;
  crypto_stack_required: boolean;
  local_olm_megolm_allowed: boolean;
  required_contracts: string[];
  required_evidence: string[];
  versions_advertisement_widened: boolean;
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
  parseMatrixFederationDestinationResolutionFailure(
    responseBody: string,
  ): ProtocolResult<MatrixFederationDestinationResolutionFailure>;
  parseMatrixFederationKeyQueryRequest(
    responseBody: string,
  ): ProtocolResult<MatrixFederationKeyQueryRequest>;
  parseMatrixFederationKeyQueryResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationKeyQueryResponse>;
  parseMatrixFederationMakeJoinResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationMakeJoinResponse>;
  parseMatrixFederationServerName(
    serverName: string,
  ): ProtocolResult<MatrixFederationServerName>;
  parseMatrixFederationSendJoinResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationSendJoinResponse>;
  parseMatrixFederationSigningKey(
    responseBody: string,
  ): ProtocolResult<MatrixFederationSigningKey>;
  parseMatrixFederationTransaction(
    responseBody: string,
  ): ProtocolResult<MatrixFederationTransaction>;
  parseMatrixFederationTransactionResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFederationTransactionResponse>;
  parseMatrixFederationWellKnownServer(
    responseBody: string,
  ): ProtocolResult<MatrixFederationWellKnownServer>;
  parseMatrixVerificationSasFlow(
    responseBody: string,
  ): ProtocolResult<MatrixVerificationSasFlow>;
  parseMatrixVerificationCancel(
    responseBody: string,
  ): ProtocolResult<MatrixVerificationCancel>;
  parseMatrixCrossSigningDeviceSigningUpload(
    responseBody: string,
  ): ProtocolResult<MatrixCrossSigningDeviceSigningUpload>;
  parseMatrixCrossSigningSignatureUpload(
    responseBody: string,
  ): ProtocolResult<MatrixCrossSigningSignatureUpload>;
  parseMatrixCrossSigningInvalidSignatureFailure(
    responseBody: string,
  ): ProtocolResult<MatrixCrossSigningInvalidSignatureFailure>;
  parseMatrixCrossSigningMissingTokenGate(
    responseBody: string,
  ): ProtocolResult<MatrixCrossSigningMissingTokenGate>;
  parseMatrixWrongDeviceFailureGate(
    responseBody: string,
  ): ProtocolResult<MatrixWrongDeviceFailureGate>;
  parseMatrixKeysUploadRequest(
    responseBody: string,
  ): ProtocolResult<MatrixKeysUploadRequest>;
  parseMatrixKeysUploadResponse(
    responseBody: string,
  ): ProtocolResult<MatrixKeysUploadResponse>;
  parseMatrixKeysClaimRequest(
    responseBody: string,
  ): ProtocolResult<MatrixKeysClaimRequest>;
  parseMatrixKeysClaimResponse(
    responseBody: string,
  ): ProtocolResult<MatrixKeysClaimResponse>;
  parseMatrixDeviceKeyError(
    responseBody: string,
  ): ProtocolResult<MatrixDeviceKeyError>;
  parseMatrixDeviceKeyQueryRequest(
    responseBody: string,
  ): ProtocolResult<MatrixDeviceKeyQueryRequest>;
  parseMatrixDeviceKeyQueryResponse(
    responseBody: string,
  ): ProtocolResult<MatrixDeviceKeyQueryResponse>;
  parseMatrixPublicRoomsRequest(
    responseBody: string,
  ): ProtocolResult<MatrixPublicRoomsRequest>;
  parseMatrixPublicRoomsResponse(
    responseBody: string,
  ): ProtocolResult<MatrixPublicRoomsResponse>;
  parseMatrixDirectoryVisibility(
    responseBody: string,
  ): ProtocolResult<MatrixDirectoryVisibility>;
  parseMatrixRoomAliases(responseBody: string): ProtocolResult<MatrixRoomAliases>;
  parseMatrixInviteRequest(
    responseBody: string,
  ): ProtocolResult<MatrixInviteRequest>;
  parseMatrixInviteRoom(responseBody: string): ProtocolResult<MatrixInviteRoom>;
  parseMatrixRoomDirectoryError(
    responseBody: string,
  ): ProtocolResult<MatrixRoomDirectoryError>;
  parseMatrixModerationRequest(
    responseBody: string,
  ): ProtocolResult<MatrixModerationRequest>;
  parseMatrixRedactionRequest(
    responseBody: string,
  ): ProtocolResult<MatrixRedactionRequest>;
  parseMatrixRedactionResponse(
    responseBody: string,
  ): ProtocolResult<MatrixRedactionResponse>;
  parseMatrixReportRequest(
    responseBody: string,
  ): ProtocolResult<MatrixReportRequest>;
  parseMatrixAccountModerationCapability(
    responseBody: string,
  ): ProtocolResult<MatrixAccountModerationCapability>;
  parseMatrixAdminAccountModerationStatus(
    responseBody: string,
  ): ProtocolResult<MatrixAdminAccountModerationStatus>;
  parseMatrixModerationError(
    responseBody: string,
  ): ProtocolResult<MatrixModerationError>;
  parseMatrixKeyBackupVersionCreateResponse(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupVersionCreateResponse>;
  parseMatrixKeyBackupVersion(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupVersion>;
  parseMatrixKeyBackupSession(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupSession>;
  parseMatrixKeyBackupSessionUploadResponse(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupSessionUploadResponse>;
  parseMatrixKeyBackupError(responseBody: string): ProtocolResult<MatrixKeyBackupError>;
  parseMatrixKeyBackupOwnerScopeGate(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupOwnerScopeGate>;
  parseMatrixKeyBackupRecoveryGate(
    responseBody: string,
  ): ProtocolResult<MatrixKeyBackupRecoveryGate>;
  parseMatrixLoginFlows(responseBody: string): ProtocolResult<MatrixLoginFlows>;
  parseMatrixLoginSession(
    responseBody: string,
  ): ProtocolResult<MatrixLoginSession>;
  parseMatrixAuthMetadata(
    responseBody: string,
  ): ProtocolResult<MatrixAuthMetadata>;
  buildMatrixAccountManagementRedirect(
    responseBody: string,
  ): ProtocolResult<MatrixAccountManagementRedirect>;
  reconcileMatrixAccountManagementDeviceDelete(
    responseBody: string,
  ): ProtocolResult<MatrixAccountManagementReconciliation>;
  parseMatrixMediaContentUri(
    contentUri: string,
  ): ProtocolResult<MatrixMediaContentUri>;
  parseMatrixMediaUploadResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMediaUploadResponse>;
  parseMatrixMessagesResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMessagesResponse>;
  parseMatrixEventRetrievalRequestDescriptor(
    responseBody: string,
  ): ProtocolResult<MatrixEventRetrievalRequestDescriptor>;
  parseMatrixJoinedMembersResponse(
    responseBody: string,
  ): ProtocolResult<MatrixJoinedMembersResponse>;
  parseMatrixMembersResponse(
    responseBody: string,
  ): ProtocolResult<MatrixMembersResponse>;
  parseMatrixTimestampToEventResponse(
    responseBody: string,
  ): ProtocolResult<MatrixTimestampToEventResponse>;
  parseMatrixRelationsRequestDescriptor(
    responseBody: string,
  ): ProtocolResult<MatrixRelationsRequestDescriptor>;
  parseMatrixRelationChunkResponse(
    responseBody: string,
  ): ProtocolResult<MatrixRelationChunkResponse>;
  parseMatrixThreadRootsResponse(
    responseBody: string,
  ): ProtocolResult<MatrixThreadRootsResponse>;
  parseMatrixReactionEvent(responseBody: string): ProtocolResult<MatrixClientEvent>;
  parseMatrixEditEvent(responseBody: string): ProtocolResult<MatrixClientEvent>;
  parseMatrixReplyEvent(responseBody: string): ProtocolResult<MatrixClientEvent>;
  parseMatrixProfileResponse(
    responseBody: string,
  ): ProtocolResult<MatrixProfileResponse>;
  parseMatrixProfileFieldUpdateRequest(
    responseBody: string,
  ): ProtocolResult<MatrixProfileFieldUpdateRequest>;
  parseMatrixAccountDataContent(
    responseBody: string,
  ): ProtocolResult<MatrixAccountDataContent>;
  parseMatrixRoomTag(responseBody: string): ProtocolResult<MatrixRoomTag>;
  parseMatrixRoomTags(responseBody: string): ProtocolResult<MatrixRoomTags>;
  parseMatrixTypingRequest(
    responseBody: string,
  ): ProtocolResult<MatrixTypingRequest>;
  parseMatrixTypingContent(
    responseBody: string,
  ): ProtocolResult<MatrixTypingContent>;
  parseMatrixReceiptRequest(
    responseBody: string,
  ): ProtocolResult<MatrixReceiptRequest>;
  parseMatrixReceiptContent(
    responseBody: string,
  ): ProtocolResult<MatrixReceiptContent>;
  parseMatrixReadMarkersRequest(
    responseBody: string,
  ): ProtocolResult<MatrixReadMarkersRequest>;
  parseMatrixFullyReadContent(
    responseBody: string,
  ): ProtocolResult<MatrixFullyReadContent>;
  parseMatrixFilterDefinition(
    responseBody: string,
  ): ProtocolResult<MatrixFilterDefinition>;
  parseMatrixFilterCreateResponse(
    responseBody: string,
  ): ProtocolResult<MatrixFilterCreateResponse>;
  parseMatrixPresenceRequest(
    responseBody: string,
  ): ProtocolResult<MatrixPresenceRequest>;
  parseMatrixPresenceContent(
    responseBody: string,
  ): ProtocolResult<MatrixPresenceContent>;
  parseMatrixPresenceEvent(
    responseBody: string,
  ): ProtocolResult<MatrixPresenceEvent>;
  parseMatrixCapabilitiesResponse(
    responseBody: string,
  ): ProtocolResult<MatrixCapabilitiesResponse>;
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
    parseMatrixFederationDestinationResolutionFailure(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationDestinationResolutionFailureJson(
          responseBody,
        ),
        "parse envelope",
      );
      return readMatrixFederationDestinationResolutionFailureEnvelope(envelope);
    },
    parseMatrixFederationKeyQueryRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationKeyQueryRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationKeyQueryRequestEnvelope(envelope);
    },
    parseMatrixFederationKeyQueryResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationKeyQueryResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationKeyQueryResponseEnvelope(envelope);
    },
    parseMatrixFederationMakeJoinResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationMakeJoinResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationMakeJoinResponseEnvelope(envelope);
    },
    parseMatrixFederationServerName(serverName: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationServerNameJson(serverName),
        "parse envelope",
      );
      return readMatrixFederationServerNameEnvelope(envelope);
    },
    parseMatrixFederationSendJoinResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationSendJoinResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationSendJoinResponseEnvelope(envelope);
    },
    parseMatrixFederationSigningKey(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationSigningKeyJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationSigningKeyEnvelope(envelope);
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
    parseMatrixFederationWellKnownServer(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFederationWellKnownServerJson(responseBody),
        "parse envelope",
      );
      return readMatrixFederationWellKnownServerEnvelope(envelope);
    },
    parseMatrixVerificationSasFlow(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixVerificationSasFlowJson(responseBody),
        "parse envelope",
      );
      return readMatrixVerificationSasFlowEnvelope(envelope);
    },
    parseMatrixVerificationCancel(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixVerificationCancelJson(responseBody),
        "parse envelope",
      );
      return readMatrixVerificationCancelEnvelope(envelope);
    },
    parseMatrixCrossSigningDeviceSigningUpload(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixCrossSigningDeviceSigningUploadJson(responseBody),
        "parse envelope",
      );
      return readMatrixCrossSigningDeviceSigningUploadEnvelope(envelope);
    },
    parseMatrixCrossSigningSignatureUpload(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixCrossSigningSignatureUploadJson(responseBody),
        "parse envelope",
      );
      return readMatrixCrossSigningSignatureUploadEnvelope(envelope);
    },
    parseMatrixCrossSigningInvalidSignatureFailure(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixCrossSigningInvalidSignatureFailureJson(responseBody),
        "parse envelope",
      );
      return readMatrixCrossSigningInvalidSignatureFailureEnvelope(envelope);
    },
    parseMatrixCrossSigningMissingTokenGate(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixCrossSigningMissingTokenGateJson(responseBody),
        "parse envelope",
      );
      return readMatrixCrossSigningMissingTokenGateEnvelope(envelope);
    },
    parseMatrixWrongDeviceFailureGate(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixWrongDeviceFailureGateJson(responseBody),
        "parse envelope",
      );
      return readMatrixWrongDeviceFailureGateEnvelope(envelope);
    },
    parseMatrixKeysUploadRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeysUploadRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeysUploadRequestEnvelope(envelope);
    },
    parseMatrixKeysUploadResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeysUploadResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeysUploadResponseEnvelope(envelope);
    },
    parseMatrixKeysClaimRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeysClaimRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeysClaimRequestEnvelope(envelope);
    },
    parseMatrixKeysClaimResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeysClaimResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeysClaimResponseEnvelope(envelope);
    },
    parseMatrixDeviceKeyError(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDeviceKeyErrorJson(responseBody),
        "parse envelope",
      );
      return readMatrixDeviceKeyErrorEnvelope(envelope);
    },
    parseMatrixDeviceKeyQueryRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDeviceKeyQueryRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixDeviceKeyQueryRequestEnvelope(envelope);
    },
    parseMatrixDeviceKeyQueryResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDeviceKeyQueryResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixDeviceKeyQueryResponseEnvelope(envelope);
    },
    parseMatrixPublicRoomsRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixPublicRoomsRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixPublicRoomsRequestEnvelope(envelope);
    },
    parseMatrixPublicRoomsResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixPublicRoomsResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixPublicRoomsResponseEnvelope(envelope);
    },
    parseMatrixDirectoryVisibility(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixDirectoryVisibilityJson(responseBody),
        "parse envelope",
      );
      return readMatrixDirectoryVisibilityEnvelope(envelope);
    },
    parseMatrixRoomAliases(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomAliasesJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomAliasesEnvelope(envelope);
    },
    parseMatrixInviteRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixInviteRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixInviteRequestEnvelope(envelope);
    },
    parseMatrixInviteRoom(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixInviteRoomJson(responseBody),
        "parse envelope",
      );
      return readMatrixInviteRoomEnvelope(envelope);
    },
    parseMatrixRoomDirectoryError(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomDirectoryErrorJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomDirectoryErrorEnvelope(envelope);
    },
    parseMatrixModerationRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixModerationRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixModerationRequestEnvelope(envelope);
    },
    parseMatrixRedactionRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRedactionRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixRedactionRequestEnvelope(envelope);
    },
    parseMatrixRedactionResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRedactionResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixRedactionResponseEnvelope(envelope);
    },
    parseMatrixReportRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReportRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixReportRequestEnvelope(envelope);
    },
    parseMatrixAccountModerationCapability(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixAccountModerationCapabilityJson(responseBody),
        "parse envelope",
      );
      return readMatrixAccountModerationCapabilityEnvelope(envelope);
    },
    parseMatrixAdminAccountModerationStatus(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixAdminAccountModerationStatusJson(responseBody),
        "parse envelope",
      );
      return readMatrixAdminAccountModerationStatusEnvelope(envelope);
    },
    parseMatrixModerationError(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixModerationErrorJson(responseBody),
        "parse envelope",
      );
      return readMatrixModerationErrorEnvelope(envelope);
    },
    parseMatrixKeyBackupVersionCreateResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupVersionCreateResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupVersionCreateResponseEnvelope(envelope);
    },
    parseMatrixKeyBackupVersion(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupVersionJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupVersionEnvelope(envelope);
    },
    parseMatrixKeyBackupSession(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupSessionJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupSessionEnvelope(envelope);
    },
    parseMatrixKeyBackupSessionUploadResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupSessionUploadResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupSessionUploadResponseEnvelope(envelope);
    },
    parseMatrixKeyBackupError(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupErrorJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupErrorEnvelope(envelope);
    },
    parseMatrixKeyBackupOwnerScopeGate(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupOwnerScopeGateJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupOwnerScopeGateEnvelope(envelope);
    },
    parseMatrixKeyBackupRecoveryGate(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixKeyBackupRecoveryGateJson(responseBody),
        "parse envelope",
      );
      return readMatrixKeyBackupRecoveryGateEnvelope(envelope);
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
    parseMatrixAuthMetadata(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixAuthMetadataJson(responseBody),
        "parse envelope",
      );
      return readMatrixAuthMetadataEnvelope(envelope);
    },
    buildMatrixAccountManagementRedirect(responseBody: string) {
      const envelope = parseJsonObject(
        binding.buildMatrixAccountManagementRedirectJson(responseBody),
        "parse envelope",
      );
      return readMatrixAccountManagementRedirectEnvelope(envelope);
    },
    reconcileMatrixAccountManagementDeviceDelete(responseBody: string) {
      const envelope = parseJsonObject(
        binding.reconcileMatrixAccountManagementDeviceDeleteJson(responseBody),
        "parse envelope",
      );
      return readMatrixAccountManagementReconciliationEnvelope(envelope);
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
    parseMatrixEventRetrievalRequestDescriptor(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixEventRetrievalRequestDescriptorJson(responseBody),
        "parse envelope",
      );
      return readMatrixEventRetrievalRequestDescriptorEnvelope(envelope);
    },
    parseMatrixJoinedMembersResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixJoinedMembersResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixJoinedMembersResponseEnvelope(envelope);
    },
    parseMatrixMembersResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixMembersResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixMembersResponseEnvelope(envelope);
    },
    parseMatrixTimestampToEventResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixTimestampToEventResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixTimestampToEventResponseEnvelope(envelope);
    },
    parseMatrixRelationsRequestDescriptor(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRelationsRequestDescriptorJson(responseBody),
        "parse envelope",
      );
      return readMatrixRelationsRequestDescriptorEnvelope(envelope);
    },
    parseMatrixRelationChunkResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRelationChunkResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixRelationChunkResponseEnvelope(envelope);
    },
    parseMatrixThreadRootsResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixThreadRootsResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixThreadRootsResponseEnvelope(envelope);
    },
    parseMatrixReactionEvent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReactionEventJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientEventEnvelope(envelope);
    },
    parseMatrixEditEvent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixEditEventJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientEventEnvelope(envelope);
    },
    parseMatrixReplyEvent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReplyEventJson(responseBody),
        "parse envelope",
      );
      return readMatrixClientEventEnvelope(envelope);
    },
    parseMatrixProfileResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixProfileResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixProfileResponseEnvelope(envelope);
    },
    parseMatrixProfileFieldUpdateRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixProfileFieldUpdateRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixProfileFieldUpdateRequestEnvelope(envelope);
    },
    parseMatrixAccountDataContent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixAccountDataContentJson(responseBody),
        "parse envelope",
      );
      return readMatrixAccountDataContentEnvelope(envelope);
    },
    parseMatrixRoomTag(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomTagJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomTagEnvelope(envelope);
    },
    parseMatrixRoomTags(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixRoomTagsJson(responseBody),
        "parse envelope",
      );
      return readMatrixRoomTagsEnvelope(envelope);
    },
    parseMatrixTypingRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixTypingRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixTypingRequestEnvelope(envelope);
    },
    parseMatrixTypingContent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixTypingContentJson(responseBody),
        "parse envelope",
      );
      return readMatrixTypingContentEnvelope(envelope);
    },
    parseMatrixReceiptRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReceiptRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixReceiptRequestEnvelope(envelope);
    },
    parseMatrixReceiptContent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReceiptContentJson(responseBody),
        "parse envelope",
      );
      return readMatrixReceiptContentEnvelope(envelope);
    },
    parseMatrixReadMarkersRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixReadMarkersRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixReadMarkersRequestEnvelope(envelope);
    },
    parseMatrixFullyReadContent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFullyReadContentJson(responseBody),
        "parse envelope",
      );
      return readMatrixFullyReadContentEnvelope(envelope);
    },
    parseMatrixFilterDefinition(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFilterDefinitionJson(responseBody),
        "parse envelope",
      );
      return readMatrixFilterDefinitionEnvelope(envelope);
    },
    parseMatrixFilterCreateResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixFilterCreateResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixFilterCreateResponseEnvelope(envelope);
    },
    parseMatrixPresenceRequest(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixPresenceRequestJson(responseBody),
        "parse envelope",
      );
      return readMatrixPresenceRequestEnvelope(envelope);
    },
    parseMatrixPresenceContent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixPresenceContentJson(responseBody),
        "parse envelope",
      );
      return readMatrixPresenceContentEnvelope(envelope);
    },
    parseMatrixPresenceEvent(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixPresenceEventJson(responseBody),
        "parse envelope",
      );
      return readMatrixPresenceEventEnvelope(envelope);
    },
    parseMatrixCapabilitiesResponse(responseBody: string) {
      const envelope = parseJsonObject(
        binding.parseMatrixCapabilitiesResponseJson(responseBody),
        "parse envelope",
      );
      return readMatrixCapabilitiesResponseEnvelope(envelope);
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

function readMatrixFederationServerNameEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationServerName> {
  return readProtocolResult(envelope, (value) => {
    const serverName: MatrixFederationServerName = {
      server_name: readString(value, "server_name", "invalid_envelope"),
      host: readString(value, "host", "invalid_envelope"),
    };
    readOptionalNumber(value, "port", (port) => {
      serverName.port = port;
    });
    return serverName;
  });
}

function readMatrixFederationWellKnownServerEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationWellKnownServer> {
  return readProtocolResult(envelope, (value) => {
    const wellKnown: MatrixFederationWellKnownServer = {
      delegated_server_name: readString(
        value,
        "delegated_server_name",
        "invalid_envelope",
      ),
      host: readString(value, "host", "invalid_envelope"),
    };
    readOptionalNumber(value, "port", (port) => {
      wellKnown.port = port;
    });
    return wellKnown;
  });
}

function readMatrixFederationSigningKeyEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationSigningKey> {
  return readProtocolResult(envelope, readMatrixFederationSigningKey);
}

function readMatrixFederationKeyQueryRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationKeyQueryRequest> {
  return readProtocolResult(envelope, (value) => ({
    server_keys: readNestedFederationKeyQueryCriteria(
      value,
      "server_keys",
      "federation.key_query_request.server_keys",
    ),
  }));
}

function readMatrixFederationKeyQueryResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationKeyQueryResponse> {
  return readProtocolResult(envelope, (value) => ({
    server_keys: readArray(value, "server_keys", "invalid_envelope").map(
      (entry, index) =>
        readMatrixFederationSigningKey(
          assertRecord(entry, `federation.key_query_response.${index}`),
        ),
    ),
  }));
}

function readMatrixFederationDestinationResolutionFailureEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFederationDestinationResolutionFailure> {
  return readProtocolResult(envelope, (value) => ({
    server_name: readString(value, "server_name", "invalid_envelope"),
    stages: readStringArray(value, "stages", "invalid_envelope"),
    destination_resolved: readBoolean(value, "destination_resolved"),
    federation_request_sent: readBoolean(value, "federation_request_sent"),
    backoff_recorded: readBoolean(value, "backoff_recorded"),
  }));
}

function readMatrixVerificationSasFlowEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixVerificationSasFlow> {
  return readProtocolResult(envelope, (value) => {
    const flow: MatrixVerificationSasFlow = {
      transaction_id: readString(value, "transaction_id", "invalid_envelope"),
      transport: readString(value, "transport", "invalid_envelope"),
      event_types: readStringArray(value, "event_types", "invalid_envelope"),
      verified: readBoolean(value, "verified"),
      local_sas_allowed: readBoolean(value, "local_sas_allowed"),
      versions_advertisement_widened: readBoolean(
        value,
        "versions_advertisement_widened",
      ),
    };
    return flow;
  });
}

function readMatrixVerificationCancelEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixVerificationCancel> {
  return readProtocolResult(envelope, (value) => ({
    transaction_id: readString(value, "transaction_id", "invalid_envelope"),
    code: readString(value, "code", "invalid_envelope"),
    reason: readString(value, "reason", "invalid_envelope"),
    verified: readBoolean(value, "verified"),
    versions_advertisement_widened: readBoolean(
      value,
      "versions_advertisement_widened",
    ),
  }));
}

function readMatrixCrossSigningDeviceSigningUploadEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixCrossSigningDeviceSigningUpload> {
  return readProtocolResult(envelope, (value) => {
    const upload: MatrixCrossSigningDeviceSigningUpload = {};
    readOptionalRecord(value, "master_key", (key) => {
      upload.master_key = readMatrixCrossSigningKey(key);
    });
    readOptionalRecord(value, "self_signing_key", (key) => {
      upload.self_signing_key = readMatrixCrossSigningKey(key);
    });
    readOptionalRecord(value, "user_signing_key", (key) => {
      upload.user_signing_key = readMatrixCrossSigningKey(key);
    });
    return upload;
  });
}

function readMatrixCrossSigningSignatureUploadEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixCrossSigningSignatureUpload> {
  return readProtocolResult(envelope, (value) => {
    const signedObjects: [
      string,
      Record<string, Record<string, unknown>>,
    ][] = [];
    for (const [userId, devices] of Object.entries(
      readRecord(value, "signed_objects", "cross signing signature upload"),
    )) {
      const deviceRecords: [string, Record<string, unknown>][] = [];
      for (const [deviceId, signedObject] of Object.entries(
        assertRecord(devices, `cross_signing.signatures_upload.${userId}`),
      )) {
        deviceRecords.push([
          deviceId,
          assertRecord(
            signedObject,
            `cross_signing.signatures_upload.${userId}.${deviceId}`,
          ),
        ]);
      }
      signedObjects.push([userId, Object.fromEntries(deviceRecords)]);
    }
    return { signed_objects: Object.fromEntries(signedObjects) };
  });
}

function readMatrixCrossSigningInvalidSignatureFailureEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixCrossSigningInvalidSignatureFailure> {
  return readProtocolResult(envelope, (value) => ({
    status: readNumber(value, "status", "invalid_envelope"),
    errcode: readString(value, "errcode", "invalid_envelope"),
    error: readString(value, "error", "invalid_envelope"),
  }));
}

function readMatrixCrossSigningMissingTokenGateEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixCrossSigningMissingTokenGate> {
  return readProtocolResult(envelope, (value) => ({
    protected_key_operations_require_token: readBoolean(
      value,
      "protected_key_operations_require_token",
    ),
    semantic_errors_suppressed_until_authenticated: readBoolean(
      value,
      "semantic_errors_suppressed_until_authenticated",
    ),
    auth_precedes_signature_validation: readBoolean(
      value,
      "auth_precedes_signature_validation",
    ),
    operations: readStringArray(value, "operations", "invalid_envelope"),
    errcode: readString(value, "errcode", "invalid_envelope"),
  }));
}

function readMatrixWrongDeviceFailureGateEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixWrongDeviceFailureGate> {
  return readProtocolResult(envelope, (value) => ({
    trusted_identity: readMatrixWrongDeviceIdentity(
      readRecord(value, "trusted_identity", "wrong device gate"),
    ),
    observed_identity: readMatrixWrongDeviceIdentity(
      readRecord(value, "observed_identity", "wrong device gate"),
    ),
    required_steps: readStringArray(value, "required_steps", "invalid_envelope"),
    required_evidence: readStringArray(
      value,
      "required_evidence",
      "invalid_envelope",
    ),
    cancel_code: readString(value, "cancel_code", "invalid_envelope"),
    device_verified: readBoolean(value, "device_verified"),
    outbound_session_shared: readBoolean(value, "outbound_session_shared"),
    requires_user_reverification: readBoolean(
      value,
      "requires_user_reverification",
    ),
    versions_advertisement_widened: readBoolean(
      value,
      "versions_advertisement_widened",
    ),
  }));
}

function readMatrixKeysUploadRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeysUploadRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixKeysUploadRequest = {
      one_time_keys: readSignedKeyRecord(value, "one_time_keys"),
      fallback_keys: readSignedKeyRecord(value, "fallback_keys"),
      private_key_material_returned: readBoolean(
        value,
        "private_key_material_returned",
      ),
    };
    readOptionalRecord(value, "device_keys", (deviceKeys) => {
      result.device_keys = readMatrixDeviceKeysUploadDevice(deviceKeys);
    });
    return result;
  });
}

function readMatrixKeysUploadResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeysUploadResponse> {
  return readProtocolResult(envelope, (value) => ({
    one_time_key_counts: readNumberRecord(value, "one_time_key_counts"),
    private_key_material_returned: readBoolean(
      value,
      "private_key_material_returned",
    ),
  }));
}

function readMatrixKeysClaimRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeysClaimRequest> {
  return readProtocolResult(envelope, (value) => ({
    one_time_keys: readNestedStringRecord(
      value,
      "one_time_keys",
      "keys claim request",
    ),
  }));
}

function readMatrixKeysClaimResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeysClaimResponse> {
  return readProtocolResult(envelope, (value) => ({
    failures: readNestedStringRecord(value, "failures", "keys claim response"),
    one_time_keys: readClaimedKeysRecord(value, "one_time_keys"),
    fallback_key_returned: readBoolean(value, "fallback_key_returned"),
  }));
}

function readMatrixDeviceKeyErrorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDeviceKeyError> {
  return readProtocolResult(envelope, (value) => ({
    status: readNumber(value, "status", "invalid_envelope"),
    errcode: readString(value, "errcode", "invalid_envelope"),
    error: readString(value, "error", "invalid_envelope"),
  }));
}

function readMatrixDeviceKeyQueryRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDeviceKeyQueryRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixDeviceKeyQueryRequest = {
      device_keys: readStringArrayRecord(value, "device_keys"),
    };
    readOptionalNumber(value, "timeout", (timeout) => {
      result.timeout = timeout;
    });
    return result;
  });
}

function readMatrixDeviceKeyQueryResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDeviceKeyQueryResponse> {
  return readProtocolResult(envelope, (value) => ({
    failures: readNestedStringRecord(value, "failures", "device key query"),
    device_keys: readDeviceKeyQueryDeviceRecord(value, "device_keys"),
    private_key_material_returned: readBoolean(
      value,
      "private_key_material_returned",
    ),
    trust_decision_made: readBoolean(value, "trust_decision_made"),
  }));
}

function readMatrixPublicRoomsRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixPublicRoomsRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixPublicRoomsRequest = {};
    readOptionalNumber(value, "limit", (limit) => {
      result.limit = limit;
    });
    readOptionalString(value, "since", (since) => {
      result.since = since;
    });
    readOptionalString(value, "server", (server) => {
      result.server = server;
    });
    readOptionalString(value, "generic_search_term", (term) => {
      result.generic_search_term = term;
    });
    readOptionalBoolean(value, "include_all_networks", (includeAllNetworks) => {
      result.include_all_networks = includeAllNetworks;
    });
    readOptionalString(value, "third_party_instance_id", (id) => {
      result.third_party_instance_id = id;
    });
    return result;
  });
}

function readMatrixPublicRoomsResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixPublicRoomsResponse> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixPublicRoomsResponse = {
      chunk: readRecordArray(value, "chunk", "invalid_envelope").map((room) => {
        const publicRoom: MatrixPublicRoom = {
          room_id: readString(room, "room_id", "invalid_envelope"),
          num_joined_members: readNumber(
            room,
            "num_joined_members",
            "invalid_envelope",
          ),
          world_readable: readBoolean(room, "world_readable"),
          guest_can_join: readBoolean(room, "guest_can_join"),
        };
        for (const field of [
          "name",
          "topic",
          "canonical_alias",
          "avatar_url",
          "join_rule",
          "room_type",
        ] as const) {
          readOptionalString(room, field, (entry) => {
            publicRoom[field] = entry;
          });
        }
        return publicRoom;
      }),
    };
    readOptionalString(value, "next_batch", (token) => {
      result.next_batch = token;
    });
    readOptionalString(value, "prev_batch", (token) => {
      result.prev_batch = token;
    });
    readOptionalNumber(value, "total_room_count_estimate", (count) => {
      result.total_room_count_estimate = count;
    });
    return result;
  });
}

function readMatrixDirectoryVisibilityEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixDirectoryVisibility> {
  return readProtocolResult(envelope, (value) => ({
    visibility: readString(value, "visibility", "invalid_envelope"),
  }));
}

function readMatrixRoomAliasesEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomAliases> {
  return readProtocolResult(envelope, (value) => ({
    aliases: readStringArray(value, "aliases", "invalid_envelope"),
  }));
}

function readMatrixInviteRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixInviteRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixInviteRequest = {
      user_id: readString(value, "user_id", "invalid_envelope"),
    };
    readOptionalString(value, "reason", (reason) => {
      result.reason = reason;
    });
    return result;
  });
}

function readMatrixInviteRoomEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixInviteRoom> {
  return readProtocolResult(envelope, (value) => ({
    room_id: readString(value, "room_id", "invalid_envelope"),
    events: readRecordArray(value, "events", "invalid_envelope").map((event) => {
      const result: MatrixInviteStateEvent = {
        type: readString(event, "type", "invalid_envelope"),
        state_key: readString(event, "state_key", "invalid_envelope"),
        content: readRecord(event, "content", "invite state event"),
      };
      readOptionalString(event, "sender", (sender) => {
        result.sender = sender;
      });
      return result;
    }),
  }));
}

function readMatrixRoomDirectoryErrorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomDirectoryError> {
  return readProtocolResult(envelope, (value) => ({
    status: readNumber(value, "status", "invalid_envelope"),
    errcode: readString(value, "errcode", "invalid_envelope"),
    error: readString(value, "error", "invalid_envelope"),
  }));
}

function readMatrixModerationRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixModerationRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixModerationRequest = {
      user_id: readString(value, "user_id", "invalid_envelope"),
    };
    readOptionalString(value, "reason", (reason) => {
      result.reason = reason;
    });
    return result;
  });
}

function readMatrixRedactionRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRedactionRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixRedactionRequest = {};
    readOptionalString(value, "reason", (reason) => {
      result.reason = reason;
    });
    return result;
  });
}

function readMatrixRedactionResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRedactionResponse> {
  return readProtocolResult(envelope, (value) => ({
    event_id: readString(value, "event_id", "invalid_envelope"),
  }));
}

function readMatrixReportRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixReportRequest> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixReportRequest = {};
    readOptionalString(value, "reason", (reason) => {
      result.reason = reason;
    });
    return result;
  });
}

function readMatrixAccountModerationCapabilityEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAccountModerationCapability> {
  return readProtocolResult(envelope, (value) => ({
    lock: readBoolean(value, "lock"),
    suspend: readBoolean(value, "suspend"),
  }));
}

function readMatrixAdminAccountModerationStatusEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAdminAccountModerationStatus> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixAdminAccountModerationStatus = {};
    readOptionalBoolean(value, "locked", (locked) => {
      result.locked = locked;
    });
    readOptionalBoolean(value, "suspended", (suspended) => {
      result.suspended = suspended;
    });
    return result;
  });
}

function readMatrixModerationErrorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixModerationError> {
  return readProtocolResult(envelope, (value) => ({
    status: readNumber(value, "status", "invalid_envelope"),
    errcode: readString(value, "errcode", "invalid_envelope"),
    error: readString(value, "error", "invalid_envelope"),
  }));
}

function readStringArrayRecord(
  source: Record<string, unknown>,
  field: string,
): Record<string, string[]> {
  const entries: [string, string[]][] = [];
  for (const [key, value] of Object.entries(readRecord(source, field, field))) {
    if (!Array.isArray(value) || value.some((entry) => typeof entry !== "string")) {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        `${field}.${key} must be a string array`,
      );
    }
    entries.push([key, value]);
  }
  return Object.fromEntries(entries);
}

function readDeviceKeyQueryDeviceRecord(
  source: Record<string, unknown>,
  field: string,
): Record<string, Record<string, MatrixDeviceKeysUploadDevice>> {
  const users: [string, Record<string, MatrixDeviceKeysUploadDevice>][] = [];
  for (const [userId, devices] of Object.entries(
    readRecord(source, field, "device key query"),
  )) {
    const deviceEntries: [string, MatrixDeviceKeysUploadDevice][] = [];
    for (const [deviceId, device] of Object.entries(
      assertRecord(devices, `${field}.${userId}`),
    )) {
      deviceEntries.push([
        deviceId,
        readMatrixDeviceKeysUploadDevice(
          assertRecord(device, `${field}.${userId}.${deviceId}`),
        ),
      ]);
    }
    users.push([userId, Object.fromEntries(deviceEntries)]);
  }
  return Object.fromEntries(users);
}

function readMatrixDeviceKeysUploadDevice(
  value: Record<string, unknown>,
): MatrixDeviceKeysUploadDevice {
  return {
    user_id: readString(value, "user_id", "invalid_envelope"),
    device_id: readString(value, "device_id", "invalid_envelope"),
    algorithms: readStringArray(value, "algorithms", "invalid_envelope"),
    keys: readKeyPreservingStringRecord(
      readRecord(value, "keys", "device keys upload"),
    ),
    signatures: readNestedStringRecord(
      value,
      "signatures",
      "device keys upload",
    ),
  };
}

function readSignedKeyRecord(
  source: Record<string, unknown>,
  field: string,
): Record<string, MatrixSignedCurve25519Key> {
  const keys: [string, MatrixSignedCurve25519Key][] = [];
  for (const [keyId, key] of Object.entries(readRecord(source, field, field))) {
    keys.push([
      keyId,
      readMatrixSignedCurve25519Key(assertRecord(key, `${field}.${keyId}`)),
    ]);
  }
  return Object.fromEntries(keys);
}

function readMatrixSignedCurve25519Key(
  value: Record<string, unknown>,
): MatrixSignedCurve25519Key {
  return {
    key: readString(value, "key", "invalid_envelope"),
    fallback: readBoolean(value, "fallback"),
    signatures: readNestedStringRecord(value, "signatures", "signed key"),
  };
}

function readClaimedKeysRecord(
  source: Record<string, unknown>,
  field: string,
): Record<string, Record<string, Record<string, MatrixSignedCurve25519Key>>> {
  const users: [
    string,
    Record<string, Record<string, MatrixSignedCurve25519Key>>,
  ][] = [];
  for (const [userId, devices] of Object.entries(
    readRecord(source, field, "keys claim response"),
  )) {
    const deviceEntries: [string, Record<string, MatrixSignedCurve25519Key>][] =
      [];
    for (const [deviceId, keys] of Object.entries(
      assertRecord(devices, `${field}.${userId}`),
    )) {
      const keyEntries: [string, MatrixSignedCurve25519Key][] = [];
      for (const [keyId, key] of Object.entries(
        assertRecord(keys, `${field}.${userId}.${deviceId}`),
      )) {
        keyEntries.push([
          keyId,
          readMatrixSignedCurve25519Key(
            assertRecord(key, `${field}.${userId}.${deviceId}.${keyId}`),
          ),
        ]);
      }
      deviceEntries.push([deviceId, Object.fromEntries(keyEntries)]);
    }
    users.push([userId, Object.fromEntries(deviceEntries)]);
  }
  return Object.fromEntries(users);
}

function readMatrixKeyBackupVersionCreateResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupVersionCreateResponse> {
  return readProtocolResult(envelope, (value) => ({
    version: readString(value, "version", "invalid_envelope"),
  }));
}

function readMatrixKeyBackupVersionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupVersion> {
  return readProtocolResult(envelope, readMatrixKeyBackupVersion);
}

function readMatrixKeyBackupVersion(
  value: Record<string, unknown>,
): MatrixKeyBackupVersion {
  const result: MatrixKeyBackupVersion = {
    algorithm: readString(value, "algorithm", "invalid_envelope"),
    auth_data: readMatrixKeyBackupAuthData(
      readRecord(value, "auth_data", "key backup version"),
    ),
  };
  readOptionalString(value, "version", (version) => {
    result.version = version;
  });
  return result;
}

function readMatrixKeyBackupAuthData(
  value: Record<string, unknown>,
): MatrixKeyBackupAuthData {
  return {
    public_key: readString(value, "public_key", "invalid_envelope"),
    signatures: readNestedStringRecord(
      value,
      "signatures",
      "key_backup.auth_data.signatures",
    ),
  };
}

function readMatrixKeyBackupSessionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupSession> {
  return readProtocolResult(envelope, (value) => ({
    first_message_index: readNumber(value, "first_message_index", "invalid_envelope"),
    forwarded_count: readNumber(value, "forwarded_count", "invalid_envelope"),
    is_verified: readBoolean(value, "is_verified"),
    session_data: readRecord(value, "session_data", "key backup session"),
  }));
}

function readMatrixKeyBackupSessionUploadResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupSessionUploadResponse> {
  return readProtocolResult(envelope, (value) => ({
    etag: readString(value, "etag", "invalid_envelope"),
    count: readNumber(value, "count", "invalid_envelope"),
  }));
}

function readMatrixKeyBackupErrorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupError> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixKeyBackupError = {
      status: readNumber(value, "status", "invalid_envelope"),
      errcode: readString(value, "errcode", "invalid_envelope"),
      error: readString(value, "error", "invalid_envelope"),
    };
    readOptionalString(value, "current_version", (currentVersion) => {
      result.current_version = currentVersion;
    });
    return result;
  });
}

function readMatrixKeyBackupOwnerScopeGateEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupOwnerScopeGate> {
  return readProtocolResult(envelope, (value) => ({
    owner_scope_enforced: readBoolean(value, "owner_scope_enforced"),
    protected_backup_unchanged: readBoolean(value, "protected_backup_unchanged"),
    checked_steps: readStringArray(value, "checked_steps", "invalid_envelope"),
    versions_advertisement_widened: readBoolean(
      value,
      "versions_advertisement_widened",
    ),
  }));
}

function readMatrixKeyBackupRecoveryGateEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixKeyBackupRecoveryGate> {
  return readProtocolResult(envelope, (value) => ({
    logout_relogin_restore: readBoolean(value, "logout_relogin_restore"),
    crypto_stack_required: readBoolean(value, "crypto_stack_required"),
    local_olm_megolm_allowed: readBoolean(value, "local_olm_megolm_allowed"),
    required_contracts: readStringArray(value, "required_contracts", "invalid_envelope"),
    required_evidence: readStringArray(value, "required_evidence", "invalid_envelope"),
    versions_advertisement_widened: readBoolean(
      value,
      "versions_advertisement_widened",
    ),
  }));
}

function readMatrixCrossSigningKey(
  value: Record<string, unknown>,
): MatrixCrossSigningKey {
  const signatures: [string, Record<string, string>][] = [];
  for (const [userId, signatureMap] of Object.entries(
    readRecord(value, "signatures", "cross signing key"),
  )) {
    signatures.push([
      userId,
      readKeyPreservingStringRecord(
        assertRecord(signatureMap, `cross_signing.key.signatures.${userId}`),
      ),
    ]);
  }
  return {
    user_id: readString(value, "user_id", "invalid_envelope"),
    usage: readStringArray(value, "usage", "invalid_envelope"),
    keys: readKeyPreservingStringRecord(
      readRecord(value, "keys", "cross signing key"),
    ),
    signatures: Object.fromEntries(signatures),
  };
}

function readMatrixWrongDeviceIdentity(
  value: Record<string, unknown>,
): MatrixWrongDeviceIdentity {
  return {
    user_id: readString(value, "user_id", "invalid_envelope"),
    device_id: readString(value, "device_id", "invalid_envelope"),
    master_key: readString(value, "master_key", "invalid_envelope"),
    device_key: readString(value, "device_key", "invalid_envelope"),
  };
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

function readMatrixAuthMetadataEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAuthMetadata> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixAuthMetadata = {
      account_management_actions_supported: readStringArray(
        value,
        "account_management_actions_supported",
      ),
    };
    readOptionalString(value, "issuer", (issuer) => {
      result.issuer = issuer;
    });
    readOptionalString(value, "account_management_uri", (uri) => {
      result.account_management_uri = uri;
    });
    return result;
  });
}

function readMatrixAccountManagementRedirectEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAccountManagementRedirect> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixAccountManagementRedirect = {
      uri: readString(value, "uri", "invalid_envelope"),
      generic_fallback: readBoolean(value, "generic_fallback"),
    };
    readOptionalString(value, "action", (action) => {
      result.action = action;
    });
    readOptionalString(value, "device_id", (deviceId) => {
      result.device_id = deviceId;
    });
    return result;
  });
}

function readMatrixAccountManagementReconciliationEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAccountManagementReconciliation> {
  return readProtocolResult(envelope, (value) => ({
    deleted_device_id: readString(value, "deleted_device_id", "invalid_envelope"),
    missing_device_id: readBoolean(value, "missing_device_id"),
    mark_delete_complete: readBoolean(value, "mark_delete_complete"),
  }));
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

function readMatrixEventRetrievalRequestDescriptorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixEventRetrievalRequestDescriptor> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixEventRetrievalRequestDescriptor = {
      method: readString(value, "method", "invalid_envelope"),
      path: readString(value, "path", "invalid_envelope"),
      requires_auth: readBoolean(value, "requires_auth"),
      adopted_runtime_behavior: readBoolean(value, "adopted_runtime_behavior"),
    };
    readOptionalString(value, "response_parser", (responseParser) => {
      result.response_parser = responseParser;
    });
    readOptionalString(value, "unsupported_reason", (unsupportedReason) => {
      result.unsupported_reason = unsupportedReason;
    });
    return result;
  });
}

function readMatrixJoinedMembersResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixJoinedMembersResponse> {
  return readProtocolResult(envelope, (value) => {
    const joined = readRecord(value, "joined", "invalid_envelope");
    return {
      joined: Object.fromEntries(
        Object.entries(joined).map(([userId, member]) => [
          userId,
          readMatrixJoinedMember(assertRecord(member, `joined.${userId}`)),
        ]),
      ),
    };
  });
}

function readMatrixJoinedMember(
  value: Record<string, unknown>,
): MatrixJoinedMember {
  const result: MatrixJoinedMember = {};
  readOptionalString(value, "display_name", (displayName) => {
    result.display_name = displayName;
  });
  readOptionalString(value, "avatar_url", (avatarUrl) => {
    result.avatar_url = avatarUrl;
  });
  return result;
}

function readMatrixMembersResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixMembersResponse> {
  return readProtocolResult(envelope, (value) => ({
    chunk: readArray(value, "chunk", "invalid_envelope").map((entry, index) =>
      readMatrixClientEvent(assertRecord(entry, `chunk.${index}`)),
    ),
  }));
}

function readMatrixTimestampToEventResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixTimestampToEventResponse> {
  return readProtocolResult(envelope, (value) => ({
    event_id: readString(value, "event_id", "invalid_envelope"),
    origin_server_ts: readNumber(
      value,
      "origin_server_ts",
      "invalid_envelope",
    ),
  }));
}

function readMatrixRelationsRequestDescriptorEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRelationsRequestDescriptor> {
  return readProtocolResult(envelope, (value) => {
    const responseParser = readString(
      value,
      "response_parser",
      "invalid_envelope",
    );
    if (responseParser !== "relation_chunk" && responseParser !== "thread_roots") {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        "Expected response_parser to be relation_chunk or thread_roots.",
      );
    }
    return {
      method: readString(value, "method", "invalid_envelope"),
      path: readString(value, "path", "invalid_envelope"),
      requires_auth: readBoolean(value, "requires_auth"),
      response_parser: responseParser,
      adopted_runtime_behavior: readBoolean(value, "adopted_runtime_behavior"),
    };
  });
}

function readMatrixRelationChunkResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRelationChunkResponse> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixRelationChunkResponse = {
      chunk: readArray(value, "chunk", "invalid_envelope").map((entry, index) =>
        readMatrixClientEvent(assertRecord(entry, `chunk.${index}`)),
      ),
    };
    readOptionalString(value, "next_batch", (nextBatch) => {
      result.next_batch = nextBatch;
    });
    readOptionalString(value, "prev_batch", (prevBatch) => {
      result.prev_batch = prevBatch;
    });
    return result;
  });
}

function readMatrixThreadRootsResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixThreadRootsResponse> {
  return readProtocolResult(envelope, (value) => {
    const result: MatrixThreadRootsResponse = {
      chunk: readArray(value, "chunk", "invalid_envelope").map((entry, index) =>
        readMatrixClientEvent(assertRecord(entry, `chunk.${index}`)),
      ),
    };
    readOptionalString(value, "next_batch", (nextBatch) => {
      result.next_batch = nextBatch;
    });
    return result;
  });
}

function readMatrixProfileResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixProfileResponse> {
  return readProtocolResult(envelope, (value) => ({
    fields: readRecord(value, "fields", "profile response"),
  }));
}

function readMatrixProfileFieldUpdateRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixProfileFieldUpdateRequest> {
  return readProtocolResult(envelope, (value) => ({
    key_name: readString(value, "key_name", "invalid_envelope"),
    value: value.value,
  }));
}

function readMatrixAccountDataContentEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixAccountDataContent> {
  return readProtocolResult(envelope, (value) => ({
    content: readRecord(value, "content", "account data content"),
  }));
}

function readMatrixRoomTagEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomTag> {
  return readProtocolResult(envelope, readMatrixRoomTag);
}

function readMatrixRoomTagsEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixRoomTags> {
  return readProtocolResult(envelope, (value) => {
    const tags: Record<string, MatrixRoomTag> = {};
    for (const [tag, entry] of Object.entries(
      readRecord(value, "tags", "room tags"),
    )) {
      tags[tag] = readMatrixRoomTag(assertRecord(entry, `tags.${tag}`));
    }
    return { tags };
  });
}

function readMatrixRoomTag(value: Record<string, unknown>): MatrixRoomTag {
  const tag: MatrixRoomTag = {};
  readOptionalFiniteNumber(value, "order", (order) => {
    tag.order = order;
  });
  return tag;
}

function readMatrixTypingRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixTypingRequest> {
  return readProtocolResult(envelope, (value) => {
    const request: MatrixTypingRequest = {
      typing: readBoolean(value, "typing"),
    };
    readOptionalNumber(value, "timeout", (timeout) => {
      request.timeout = timeout;
    });
    return request;
  });
}

function readMatrixTypingContentEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixTypingContent> {
  return readProtocolResult(envelope, (value) => ({
    user_ids: readStringArray(value, "user_ids", "invalid_envelope"),
  }));
}

function readMatrixReceiptRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixReceiptRequest> {
  return readProtocolResult(envelope, (value) => {
    const request: MatrixReceiptRequest = {};
    readOptionalString(value, "thread_id", (threadId) => {
      request.thread_id = threadId;
    });
    return request;
  });
}

function readMatrixReceiptContentEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixReceiptContent> {
  return readProtocolResult(envelope, (value) => ({
    receipts: readReceiptContent(readRecord(value, "receipts", "receipt content")),
  }));
}

function readReceiptContent(
  value: Record<string, unknown>,
): MatrixReceiptContent["receipts"] {
  const receipts: MatrixReceiptContent["receipts"] = {};
  for (const [eventId, receiptTypes] of Object.entries(value)) {
    const receiptTypeRecord = assertRecord(receiptTypes, `receipts.${eventId}`);
    receipts[eventId] = {};
    for (const [receiptType, users] of Object.entries(receiptTypeRecord)) {
      const userRecord = assertRecord(users, `receipts.${eventId}.${receiptType}`);
      receipts[eventId][receiptType] = {};
      for (const [userId, metadata] of Object.entries(userRecord)) {
        const metadataRecord = assertRecord(
          metadata,
          `receipts.${eventId}.${receiptType}.${userId}`,
        );
        const parsed: MatrixReceiptMetadata = {};
        readOptionalNumber(metadataRecord, "ts", (ts) => {
          parsed.ts = ts;
        });
        readOptionalString(metadataRecord, "thread_id", (threadId) => {
          parsed.thread_id = threadId;
        });
        receipts[eventId][receiptType][userId] = parsed;
      }
    }
  }
  return receipts;
}

function readMatrixReadMarkersRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixReadMarkersRequest> {
  return readProtocolResult(envelope, (value) => {
    const request: MatrixReadMarkersRequest = {};
    readOptionalString(value, "m.fully_read", (eventId) => {
      request["m.fully_read"] = eventId;
    });
    readOptionalString(value, "m.read", (eventId) => {
      request["m.read"] = eventId;
    });
    readOptionalString(value, "m.read.private", (eventId) => {
      request["m.read.private"] = eventId;
    });
    return request;
  });
}

function readMatrixFullyReadContentEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFullyReadContent> {
  return readProtocolResult(envelope, (value) => ({
    event_id: readString(value, "event_id", "invalid_envelope"),
  }));
}

function readMatrixFilterDefinitionEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFilterDefinition> {
  return readProtocolResult(envelope, readMatrixFilterDefinition);
}

function readMatrixFilterDefinition(
  value: Record<string, unknown>,
): MatrixFilterDefinition {
  const filter: MatrixFilterDefinition = {};
  if (value.event_fields !== undefined) {
    filter.event_fields = readStringArray(
      value,
      "event_fields",
      "invalid_envelope",
    );
  }
  readOptionalString(value, "event_format", (eventFormat) => {
    filter.event_format = eventFormat;
  });
  readOptionalRecord(value, "presence", (presence) => {
    filter.presence = readMatrixFilterEvent(presence);
  });
  readOptionalRecord(value, "room", (room) => {
    const roomFilter: MatrixRoomFilter = {};
    readOptionalRecord(room, "timeline", (timeline) => {
      roomFilter.timeline = readMatrixFilterEvent(timeline);
    });
    readOptionalRecord(room, "ephemeral", (ephemeral) => {
      roomFilter.ephemeral = readMatrixFilterEvent(ephemeral);
    });
    readOptionalRecord(room, "account_data", (accountData) => {
      roomFilter.account_data = readMatrixFilterEvent(accountData);
    });
    filter.room = roomFilter;
  });
  return filter;
}

function readMatrixFilterEvent(value: Record<string, unknown>): MatrixFilterEvent {
  const event: MatrixFilterEvent = {};
  readOptionalNumber(value, "limit", (limit) => {
    event.limit = limit;
  });
  if (value.types !== undefined) {
    event.types = readStringArray(value, "types", "invalid_envelope");
  }
  return event;
}

function readMatrixFilterCreateResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixFilterCreateResponse> {
  return readProtocolResult(envelope, (value) => ({
    filter_id: readString(value, "filter_id", "invalid_envelope"),
  }));
}

function readMatrixPresenceRequestEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixPresenceRequest> {
  return readProtocolResult(envelope, (value) => {
    const request: MatrixPresenceRequest = {
      presence: readString(value, "presence", "invalid_envelope"),
    };
    readOptionalString(value, "status_msg", (statusMsg) => {
      request.status_msg = statusMsg;
    });
    return request;
  });
}

function readMatrixPresenceContentEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixPresenceContent> {
  return readProtocolResult(envelope, readMatrixPresenceContent);
}

function readMatrixPresenceContent(
  value: Record<string, unknown>,
): MatrixPresenceContent {
  const content: MatrixPresenceContent = {
    presence: readString(value, "presence", "invalid_envelope"),
  };
  readOptionalNumber(value, "last_active_ago", (lastActiveAgo) => {
    content.last_active_ago = lastActiveAgo;
  });
  readOptionalBoolean(value, "currently_active", (currentlyActive) => {
    content.currently_active = currentlyActive;
  });
  readOptionalString(value, "status_msg", (statusMsg) => {
    content.status_msg = statusMsg;
  });
  return content;
}

function readMatrixPresenceEventEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixPresenceEvent> {
  return readProtocolResult(envelope, (value) => {
    const eventType = readString(value, "type", "invalid_envelope");
    if (eventType !== "m.presence") {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        "type must be m.presence",
      );
    }
    return {
      sender: readString(value, "sender", "invalid_envelope"),
      type: eventType,
      content: readMatrixPresenceContent(
        readRecord(value, "content", "presence event"),
      ),
    };
  });
}

function readMatrixCapabilitiesResponseEnvelope(
  envelope: Record<string, unknown>,
): ProtocolResult<MatrixCapabilitiesResponse> {
  return readProtocolResult(envelope, (value) => ({
    capabilities: readRecord(value, "capabilities", "capabilities response"),
  }));
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

function readOptionalRecord(
  source: Record<string, unknown>,
  field: string,
  apply: (value: Record<string, unknown>) => void,
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  apply(assertRecord(value, field));
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

function readOptionalFiniteNumber(
  source: Record<string, unknown>,
  field: string,
  apply: (value: number) => void,
): void {
  const value = source[field];
  if (value === null || value === undefined) {
    return;
  }
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new HouraProtocolCoreFacadeError(
      "invalid_envelope",
      `${field} must be a finite number`,
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

function readMatrixFederationSigningKey(
  value: Record<string, unknown>,
): MatrixFederationSigningKey {
  return {
    server_name: readString(value, "server_name", "invalid_envelope"),
    verify_keys: readFederationVerifyKeys(
      value,
      "verify_keys",
      "federation.signing_key.verify_keys",
    ),
    old_verify_keys: readFederationOldVerifyKeys(
      value,
      "old_verify_keys",
      "federation.signing_key.old_verify_keys",
    ),
    valid_until_ts: readNumber(value, "valid_until_ts", "invalid_envelope"),
    signatures: readNestedStringRecord(
      value,
      "signatures",
      "federation.signing_key.signatures",
    ),
  };
}

function readFederationVerifyKeys(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, MatrixFederationVerifyKey> {
  const keys: [string, MatrixFederationVerifyKey][] = [];
  for (const [keyId, key] of Object.entries(readRecord(source, field, context))) {
    keys.push([
      keyId,
      {
        key: readString(assertRecord(key, `${context}.${keyId}`), "key", "invalid_envelope"),
      },
    ]);
  }
  return Object.fromEntries(keys);
}

function readFederationOldVerifyKeys(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, MatrixFederationOldVerifyKey> {
  const keys: [string, MatrixFederationOldVerifyKey][] = [];
  for (const [keyId, key] of Object.entries(readRecord(source, field, context))) {
    const record = assertRecord(key, `${context}.${keyId}`);
    keys.push([
      keyId,
      {
        expired_ts: readNumber(record, "expired_ts", "invalid_envelope"),
        key: readString(record, "key", "invalid_envelope"),
      },
    ]);
  }
  return Object.fromEntries(keys);
}

function readNestedStringRecord(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, Record<string, string>> {
  const result: Record<string, Record<string, string>> = {};
  for (const [outerKey, inner] of Object.entries(readRecord(source, field, context))) {
    const innerResult: Record<string, string> = {};
    for (const [innerKey, value] of Object.entries(
      assertRecord(inner, `${context}.${outerKey}`),
    )) {
      if (typeof value !== "string") {
        throw new HouraProtocolCoreFacadeError(
          "invalid_envelope",
          `${context}.${outerKey}.${innerKey} must be a string`,
        );
      }
      defineRecordValue(innerResult, innerKey, value);
    }
    defineRecordValue(result, outerKey, innerResult);
  }
  return result;
}

function defineRecordValue<T>(
  target: Record<string, T>,
  key: string,
  value: T,
): void {
  Object.defineProperty(target, key, {
    value,
    enumerable: true,
    configurable: true,
    writable: true,
  });
}

function readNestedFederationKeyQueryCriteria(
  source: Record<string, unknown>,
  field: string,
  context: string,
): Record<string, Record<string, MatrixFederationKeyQueryCriteria>> {
  const servers: [string, Record<string, MatrixFederationKeyQueryCriteria>][] =
    [];
  for (const [serverName, keyCriteria] of Object.entries(
    readRecord(source, field, context),
  )) {
    const keys: [string, MatrixFederationKeyQueryCriteria][] = [];
    for (const [keyId, criteria] of Object.entries(
      assertRecord(keyCriteria, `${context}.${serverName}`),
    )) {
      const record = assertRecord(criteria, `${context}.${serverName}.${keyId}`);
      const parsed: MatrixFederationKeyQueryCriteria = {};
      readOptionalNumber(record, "minimum_valid_until_ts", (minimumValidUntilTs) => {
        parsed.minimum_valid_until_ts = minimumValidUntilTs;
      });
      keys.push([keyId, parsed]);
    }
    servers.push([serverName, Object.fromEntries(keys)]);
  }
  return Object.fromEntries(servers);
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

function readNumberRecord(
  source: Record<string, unknown>,
  field: string,
): Record<string, number> {
  const entries: [string, number][] = [];
  for (const [key, value] of Object.entries(readRecord(source, field, field))) {
    if (typeof value !== "number" || !Number.isInteger(value)) {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        `${field}.${key} must be an integer`,
      );
    }
    entries.push([key, value]);
  }
  return Object.fromEntries(entries);
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

function readKeyPreservingStringRecord(
  source: Record<string, unknown>,
): Record<string, string> {
  const entries: [string, string][] = [];
  for (const [key, value] of Object.entries(source)) {
    if (typeof value !== "string") {
      throw new HouraProtocolCoreFacadeError(
        "invalid_envelope",
        `record.${key} must be a string`,
      );
    }
    entries.push([key, value]);
  }
  return Object.fromEntries(entries);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
