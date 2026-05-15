use wasm_bindgen::prelude::*;

const WASM_BINDING_KIND: &str = "wasm";

#[wasm_bindgen(js_name = houraArtifactManifestJson)]
pub fn houra_artifact_manifest_json() -> String {
    houra_protocol_core::artifact_manifest_json_for_binding_kinds(&[WASM_BINDING_KIND])
}

#[wasm_bindgen(js_name = parseMatrixClientVersionsResponseJson)]
pub fn parse_matrix_client_versions_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_client_versions_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixErrorEnvelopeJson)]
pub fn parse_matrix_error_envelope_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_error_envelope_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = validateMatrixFoundationIdentifiersJson)]
pub fn validate_matrix_foundation_identifiers_json(value: &str) -> String {
    houra_protocol_core::validate_matrix_foundation_identifiers_json(value.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixLoginFlowsJson)]
pub fn parse_matrix_login_flows_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_login_flows_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixLoginSessionJson)]
pub fn parse_matrix_login_session_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_login_session_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixAuthMetadataJson)]
pub fn parse_matrix_auth_metadata_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_auth_metadata_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = buildMatrixAccountManagementRedirectJson)]
pub fn build_matrix_account_management_redirect_json(request_body: &str) -> String {
    houra_protocol_core::build_matrix_account_management_redirect_json(request_body.as_bytes())
}

#[wasm_bindgen(js_name = reconcileMatrixAccountManagementDeviceDeleteJson)]
pub fn reconcile_matrix_account_management_device_delete_json(response_body: &str) -> String {
    houra_protocol_core::reconcile_matrix_account_management_device_delete_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixWhoamiJson)]
pub fn parse_matrix_whoami_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_whoami_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRegistrationAvailabilityJson)]
pub fn parse_matrix_registration_availability_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_registration_availability_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRegistrationSessionJson)]
pub fn parse_matrix_registration_session_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_registration_session_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixUserInteractiveAuthRequiredJson)]
pub fn parse_matrix_user_interactive_auth_required_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_user_interactive_auth_required_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRegistrationTokenValidityJson)]
pub fn parse_matrix_registration_token_validity_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_registration_token_validity_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDeviceJson)]
pub fn parse_matrix_device_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_device_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDevicesJson)]
pub fn parse_matrix_devices_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_devices_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomIdResponseJson)]
pub fn parse_matrix_room_id_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_id_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixEventIdResponseJson)]
pub fn parse_matrix_event_id_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_event_id_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixClientEventJson)]
pub fn parse_matrix_client_event_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_client_event_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomStateJson)]
pub fn parse_matrix_room_state_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_state_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixPublicRoomsRequestJson)]
pub fn parse_matrix_public_rooms_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_public_rooms_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixPublicRoomsResponseJson)]
pub fn parse_matrix_public_rooms_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_public_rooms_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDirectoryVisibilityJson)]
pub fn parse_matrix_directory_visibility_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_directory_visibility_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomAliasesJson)]
pub fn parse_matrix_room_aliases_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_aliases_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixInviteRequestJson)]
pub fn parse_matrix_invite_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_invite_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixInviteRoomJson)]
pub fn parse_matrix_invite_room_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_invite_room_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomDirectoryErrorJson)]
pub fn parse_matrix_room_directory_error_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_directory_error_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixMessagesResponseJson)]
pub fn parse_matrix_messages_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_messages_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixEventRetrievalRequestDescriptorJson)]
pub fn parse_matrix_event_retrieval_request_descriptor_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_event_retrieval_request_descriptor_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixJoinedMembersResponseJson)]
pub fn parse_matrix_joined_members_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_joined_members_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixMembersResponseJson)]
pub fn parse_matrix_members_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_members_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixTimestampToEventResponseJson)]
pub fn parse_matrix_timestamp_to_event_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_timestamp_to_event_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRelationsRequestDescriptorJson)]
pub fn parse_matrix_relations_request_descriptor_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_relations_request_descriptor_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixSyncRequestDescriptorJson)]
pub fn parse_matrix_sync_request_descriptor_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_sync_request_descriptor_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRelationChunkResponseJson)]
pub fn parse_matrix_relation_chunk_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_relation_chunk_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixThreadRootsResponseJson)]
pub fn parse_matrix_thread_roots_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_thread_roots_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReactionEventJson)]
pub fn parse_matrix_reaction_event_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_reaction_event_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixEditEventJson)]
pub fn parse_matrix_edit_event_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_edit_event_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReplyEventJson)]
pub fn parse_matrix_reply_event_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_reply_event_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixSyncResponseJson)]
pub fn parse_matrix_sync_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_sync_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixProfileResponseJson)]
pub fn parse_matrix_profile_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_profile_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixProfileFieldUpdateRequestJson)]
pub fn parse_matrix_profile_field_update_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_profile_field_update_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixAccountDataContentJson)]
pub fn parse_matrix_account_data_content_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_account_data_content_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomTagJson)]
pub fn parse_matrix_room_tag_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_tag_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRoomTagsJson)]
pub fn parse_matrix_room_tags_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_room_tags_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixTypingRequestJson)]
pub fn parse_matrix_typing_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_typing_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixTypingContentJson)]
pub fn parse_matrix_typing_content_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_typing_content_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReceiptRequestJson)]
pub fn parse_matrix_receipt_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_receipt_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReceiptContentJson)]
pub fn parse_matrix_receipt_content_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_receipt_content_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReadMarkersRequestJson)]
pub fn parse_matrix_read_markers_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_read_markers_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFullyReadContentJson)]
pub fn parse_matrix_fully_read_content_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_fully_read_content_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFilterDefinitionJson)]
pub fn parse_matrix_filter_definition_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_filter_definition_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFilterCreateResponseJson)]
pub fn parse_matrix_filter_create_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_filter_create_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixPresenceRequestJson)]
pub fn parse_matrix_presence_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_presence_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixPresenceContentJson)]
pub fn parse_matrix_presence_content_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_presence_content_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixPresenceEventJson)]
pub fn parse_matrix_presence_event_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_presence_event_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixCapabilitiesResponseJson)]
pub fn parse_matrix_capabilities_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_capabilities_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixMediaContentUriJson)]
pub fn parse_matrix_media_content_uri_json(content_uri: &str) -> String {
    houra_protocol_core::parse_matrix_media_content_uri_json(content_uri)
}

#[wasm_bindgen(js_name = parseMatrixMediaUploadResponseJson)]
pub fn parse_matrix_media_upload_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_media_upload_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationServerNameJson)]
pub fn parse_matrix_federation_server_name_json(server_name: &str) -> String {
    houra_protocol_core::parse_matrix_federation_server_name_json(server_name)
}

#[wasm_bindgen(js_name = parseMatrixFederationWellKnownServerJson)]
pub fn parse_matrix_federation_well_known_server_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_well_known_server_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationSigningKeyJson)]
pub fn parse_matrix_federation_signing_key_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_signing_key_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationKeyQueryRequestJson)]
pub fn parse_matrix_federation_key_query_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_key_query_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationKeyQueryResponseJson)]
pub fn parse_matrix_federation_key_query_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_key_query_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationDestinationResolutionFailureJson)]
pub fn parse_matrix_federation_destination_resolution_failure_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_destination_resolution_failure_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixFederationTransactionJson)]
pub fn parse_matrix_federation_transaction_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_transaction_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationTransactionResponseJson)]
pub fn parse_matrix_federation_transaction_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_transaction_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationMakeJoinResponseJson)]
pub fn parse_matrix_federation_make_join_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_make_join_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationSendJoinResponseJson)]
pub fn parse_matrix_federation_send_join_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_send_join_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationInviteRequestJson)]
pub fn parse_matrix_federation_invite_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_invite_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixFederationInviteResponseJson)]
pub fn parse_matrix_federation_invite_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_federation_invite_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixVerificationSasFlowJson)]
pub fn parse_matrix_verification_sas_flow_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_verification_sas_flow_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixVerificationCancelJson)]
pub fn parse_matrix_verification_cancel_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_verification_cancel_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixCrossSigningDeviceSigningUploadJson)]
pub fn parse_matrix_cross_signing_device_signing_upload_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_cross_signing_device_signing_upload_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixCrossSigningSignatureUploadJson)]
pub fn parse_matrix_cross_signing_signature_upload_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_cross_signing_signature_upload_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixCrossSigningInvalidSignatureFailureJson)]
pub fn parse_matrix_cross_signing_invalid_signature_failure_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_cross_signing_invalid_signature_failure_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixCrossSigningMissingTokenGateJson)]
pub fn parse_matrix_cross_signing_missing_token_gate_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_cross_signing_missing_token_gate_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixWrongDeviceFailureGateJson)]
pub fn parse_matrix_wrong_device_failure_gate_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_wrong_device_failure_gate_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeysUploadRequestJson)]
pub fn parse_matrix_keys_upload_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_keys_upload_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeysUploadResponseJson)]
pub fn parse_matrix_keys_upload_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_keys_upload_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeysClaimRequestJson)]
pub fn parse_matrix_keys_claim_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_keys_claim_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeysClaimResponseJson)]
pub fn parse_matrix_keys_claim_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_keys_claim_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDeviceKeyErrorJson)]
pub fn parse_matrix_device_key_error_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_device_key_error_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDeviceKeyQueryRequestJson)]
pub fn parse_matrix_device_key_query_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_device_key_query_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixDeviceKeyQueryResponseJson)]
pub fn parse_matrix_device_key_query_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_device_key_query_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixModerationRequestJson)]
pub fn parse_matrix_moderation_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_moderation_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRedactionRequestJson)]
pub fn parse_matrix_redaction_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_redaction_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixRedactionResponseJson)]
pub fn parse_matrix_redaction_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_redaction_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixReportRequestJson)]
pub fn parse_matrix_report_request_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_report_request_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixAccountModerationCapabilityJson)]
pub fn parse_matrix_account_moderation_capability_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_account_moderation_capability_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixAdminAccountModerationStatusJson)]
pub fn parse_matrix_admin_account_moderation_status_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_admin_account_moderation_status_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixModerationErrorJson)]
pub fn parse_matrix_moderation_error_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_moderation_error_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupVersionCreateResponseJson)]
pub fn parse_matrix_key_backup_version_create_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_version_create_response_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupVersionJson)]
pub fn parse_matrix_key_backup_version_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_version_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupSessionJson)]
pub fn parse_matrix_key_backup_session_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_session_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupSessionUploadResponseJson)]
pub fn parse_matrix_key_backup_session_upload_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_session_upload_response_json(
        response_body.as_bytes(),
    )
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupErrorJson)]
pub fn parse_matrix_key_backup_error_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_error_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupOwnerScopeGateJson)]
pub fn parse_matrix_key_backup_owner_scope_gate_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_owner_scope_gate_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixKeyBackupRecoveryGateJson)]
pub fn parse_matrix_key_backup_recovery_gate_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_key_backup_recovery_gate_json(response_body.as_bytes())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn artifact_manifest_marks_wasm_binding_kind() {
        let json = houra_artifact_manifest_json();
        let manifest: serde_json::Value =
            serde_json::from_str(&json).expect("manifest JSON should parse");

        assert_eq!(
            manifest["supported_binding_kinds"],
            serde_json::json!(["wasm"])
        );
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-040"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-045"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-046"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-047"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-051"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-053"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-054"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-055"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-056"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-090"));
        assert!(manifest["supported_specs"]
            .as_array()
            .expect("supported_specs should be an array")
            .iter()
            .any(|spec| spec == "SPEC-093"));
        assert_eq!(
            json,
            houra_protocol_core::artifact_manifest_json_for_binding_kinds(&["wasm"])
        );
    }

    #[test]
    fn parse_response_delegates_to_core_json_envelope() {
        let json = parse_matrix_client_versions_response_json("{\"versions\":[\"v1.18\"]}");

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"versions\":[\"v1.18\"],\"unstable_features\":{}},\"error\":null}"
        );
    }

    #[test]
    fn matrix_error_parse_delegates_to_core_json_envelope() {
        let json = parse_matrix_error_envelope_json("{\"errcode\":\"M_BAD_JSON\"}");

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"errcode\":\"M_BAD_JSON\",\"error\":null,\"retry_after_ms\":null},\"error\":null}"
        );
    }

    #[test]
    fn foundation_validation_delegates_to_core_json_envelope() {
        let json = validate_matrix_foundation_identifiers_json(
            "{\"user_id\":\"@alice:example.org\",\"room_id\":\"!roomid:example.org\",\"room_alias\":\"#general:example.org\",\"event_id\":\"$eventid:example.org\",\"server_name\":\"example.org\",\"content_uri\":\"mxc://example.org/mediaid\",\"event_type\":\"m.room.message\",\"origin_server_ts\":1710000000000}",
        );

        assert_eq!(
            json,
            "{\"ok\":true,\"value\":{\"valid\":true},\"error\":null}"
        );
    }

    #[test]
    fn matrix_auth_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_login_flows_json("{\"flows\":[{\"type\":\"m.login.password\"}]}"),
            "{\"ok\":true,\"value\":{\"flows\":[{\"type\":\"m.login.password\"}]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_login_session_json(
                "{\"user_id\":\"@alice:example.test\",\"access_token\":\"token-1\",\"device_id\":\"DEVICE1\",\"home_server\":\"example.test\"}",
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@alice:example.test\",\"access_token\":\"token-1\",\"device_id\":\"DEVICE1\",\"home_server\":\"example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_whoami_json(
                "{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"is_guest\":false}",
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"is_guest\":false},\"error\":null}"
        );
    }

    #[test]
    fn matrix_media_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_media_content_uri_json("mxc://example.test/media1"),
            "{\"ok\":true,\"value\":{\"server_name\":\"example.test\",\"media_id\":\"media1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_media_upload_response_json(
                "{\"content_uri\":\"mxc://example.test/media1\"}",
            ),
            "{\"ok\":true,\"value\":{\"content_uri\":\"mxc://example.test/media1\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_profile_account_data_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_profile_response_json(
                "{\"displayname\":\"Alice\",\"avatar_url\":\"mxc://example.test/avatar-alice\",\"m.tz\":\"Asia/Tokyo\"}",
            ),
            "{\"ok\":true,\"value\":{\"fields\":{\"avatar_url\":\"mxc://example.test/avatar-alice\",\"displayname\":\"Alice\",\"m.tz\":\"Asia/Tokyo\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_profile_field_update_request_json(
                "{\"displayname\":\"Alice Example\"}",
            ),
            "{\"ok\":true,\"value\":{\"key_name\":\"displayname\",\"value\":\"Alice Example\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_account_data_content_json(
                "{\"theme\":\"dark\",\"density\":\"compact\"}",
            ),
            "{\"ok\":true,\"value\":{\"content\":{\"density\":\"compact\",\"theme\":\"dark\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_tag_json("{\"order\":0.25}"),
            "{\"ok\":true,\"value\":{\"order\":0.25},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_tags_json("{\"tags\":{\"m.favourite\":{\"order\":0.25}}}"),
            "{\"ok\":true,\"value\":{\"tags\":{\"m.favourite\":{\"order\":0.25}}},\"error\":null}"
        );
    }

    #[test]
    fn matrix_receipts_typing_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_typing_request_json("{\"typing\":true,\"timeout\":30000}"),
            "{\"ok\":true,\"value\":{\"typing\":true,\"timeout\":30000},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_typing_content_json("{\"user_ids\":[\"@alice:example.test\"]}"),
            "{\"ok\":true,\"value\":{\"user_ids\":[\"@alice:example.test\"]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_receipt_request_json("{\"thread_id\":\"main\"}"),
            "{\"ok\":true,\"value\":{\"thread_id\":\"main\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_receipt_content_json(
                "{\"$event1:example.test\":{\"m.read\":{\"@alice:example.test\":{\"ts\":1710000001000,\"thread_id\":\"main\"}}}}",
            ),
            "{\"ok\":true,\"value\":{\"receipts\":{\"$event1:example.test\":{\"m.read\":{\"@alice:example.test\":{\"ts\":1710000001000,\"thread_id\":\"main\"}}}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_read_markers_request_json(
                "{\"m.fully_read\":\"$event1:example.test\",\"m.read\":\"$event2:example.test\",\"m.read.private\":\"$event2:example.test\"}",
            ),
            "{\"ok\":true,\"value\":{\"m.fully_read\":\"$event1:example.test\",\"m.read\":\"$event2:example.test\",\"m.read.private\":\"$event2:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_fully_read_content_json("{\"event_id\":\"$event1:example.test\"}"),
            "{\"ok\":true,\"value\":{\"event_id\":\"$event1:example.test\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_filters_presence_capabilities_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_filter_definition_json(
                "{\"event_fields\":[\"type\",\"content\"],\"event_format\":\"client\",\"presence\":{\"types\":[\"m.presence\"]},\"room\":{\"timeline\":{\"limit\":20,\"types\":[\"m.room.message\"]}}}",
            ),
            "{\"ok\":true,\"value\":{\"event_fields\":[\"type\",\"content\"],\"event_format\":\"client\",\"presence\":{\"types\":[\"m.presence\"]},\"room\":{\"timeline\":{\"limit\":20,\"types\":[\"m.room.message\"]}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_filter_create_response_json("{\"filter_id\":\"filter1\"}"),
            "{\"ok\":true,\"value\":{\"filter_id\":\"filter1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_presence_request_json(
                "{\"presence\":\"online\",\"status_msg\":\"Available\"}",
            ),
            "{\"ok\":true,\"value\":{\"presence\":\"online\",\"status_msg\":\"Available\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_presence_content_json(
                "{\"presence\":\"online\",\"currently_active\":true,\"status_msg\":\"Available\"}",
            ),
            "{\"ok\":true,\"value\":{\"presence\":\"online\",\"currently_active\":true,\"status_msg\":\"Available\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_presence_event_json(
                "{\"sender\":\"@alice:example.test\",\"type\":\"m.presence\",\"content\":{\"presence\":\"online\"}}",
            ),
            "{\"ok\":true,\"value\":{\"sender\":\"@alice:example.test\",\"type\":\"m.presence\",\"content\":{\"presence\":\"online\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_capabilities_response_json(
                "{\"capabilities\":{\"m.change_password\":{\"enabled\":true},\"m.room_versions\":{\"default\":\"12\",\"available\":{\"12\":\"stable\"}}}}",
            ),
            "{\"ok\":true,\"value\":{\"capabilities\":{\"m.change_password\":{\"enabled\":true},\"m.room_versions\":{\"available\":{\"12\":\"stable\"},\"default\":\"12\"}}},\"error\":null}"
        );
    }

    #[test]
    fn matrix_federation_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_federation_server_name_json("delegated.example.test:8448"),
            "{\"ok\":true,\"value\":{\"server_name\":\"delegated.example.test:8448\",\"host\":\"delegated.example.test\",\"port\":8448},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_well_known_server_json(
                "{\"m.server\":\"delegated.example.test:8448\"}",
            ),
            "{\"ok\":true,\"value\":{\"delegated_server_name\":\"delegated.example.test:8448\",\"host\":\"delegated.example.test\",\"port\":8448},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_signing_key_json(
                "{\"server_name\":\"example.test\",\"verify_keys\":{\"ed25519:auto1\":{\"key\":\"public\"}},\"old_verify_keys\":{},\"valid_until_ts\":1779011408000,\"signatures\":{\"example.test\":{\"ed25519:auto1\":\"signature\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"server_name\":\"example.test\",\"verify_keys\":{\"ed25519:auto1\":{\"key\":\"public\"}},\"old_verify_keys\":{},\"valid_until_ts\":1779011408000,\"signatures\":{\"example.test\":{\"ed25519:auto1\":\"signature\"}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_key_query_request_json(
                "{\"server_keys\":{\"example.test\":{\"ed25519:auto1\":{\"minimum_valid_until_ts\":1779011408000}}}}",
            ),
            "{\"ok\":true,\"value\":{\"server_keys\":{\"example.test\":{\"ed25519:auto1\":{\"minimum_valid_until_ts\":1779011408000}}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_key_query_response_json(
                "{\"server_keys\":[{\"server_name\":\"example.test\",\"verify_keys\":{\"ed25519:auto1\":{\"key\":\"public\"}},\"old_verify_keys\":{},\"valid_until_ts\":1779011408000,\"signatures\":{\"example.test\":{\"ed25519:auto1\":\"signature\"}}}]}",
            ),
            "{\"ok\":true,\"value\":{\"server_keys\":[{\"server_name\":\"example.test\",\"verify_keys\":{\"ed25519:auto1\":{\"key\":\"public\"}},\"old_verify_keys\":{},\"valid_until_ts\":1779011408000,\"signatures\":{\"example.test\":{\"ed25519:auto1\":\"signature\"}}}]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_destination_resolution_failure_json(
                "{\"event\":{\"server_name\":\"broken.example.test\",\"steps\":[{\"stage\":\"failure_cache\",\"result\":{\"destination_resolved\":false,\"federation_request_sent\":false,\"backoff_recorded\":true}}]}}",
            ),
            "{\"ok\":true,\"value\":{\"server_name\":\"broken.example.test\",\"stages\":[\"failure_cache\"],\"destination_resolved\":false,\"federation_request_sent\":false,\"backoff_recorded\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_transaction_json(
                "{\"origin\":\"remote.example.test\",\"origin_server_ts\":1778408851000,\"pdus\":[],\"edus\":[]}",
            ),
            "{\"ok\":true,\"value\":{\"origin\":\"remote.example.test\",\"origin_server_ts\":1778408851000,\"pdus\":[],\"edus\":[]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_transaction_response_json(
                "{\"pdus\":{\"$event1:remote.example.test\":{}}}",
            ),
            "{\"ok\":true,\"value\":{\"pdus\":{\"$event1:remote.example.test\":{}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_make_join_response_json(
                "{\"room_version\":\"12\",\"event\":{\"type\":\"m.room.member\",\"content\":{\"membership\":\"join\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"room_version\":\"12\",\"event\":{\"content\":{\"membership\":\"join\"},\"type\":\"m.room.member\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_send_join_response_json(
                "{\"origin\":\"example.test\",\"state\":[],\"auth_chain\":[],\"event\":{\"type\":\"m.room.member\",\"content\":{\"membership\":\"join\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"origin\":\"example.test\",\"state\":[],\"auth_chain\":[],\"event\":{\"content\":{\"membership\":\"join\"},\"type\":\"m.room.member\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_invite_request_json(
                "{\"room_version\":\"12\",\"event\":{\"type\":\"m.room.member\",\"content\":{\"membership\":\"invite\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"room_version\":\"12\",\"event\":{\"content\":{\"membership\":\"invite\"},\"type\":\"m.room.member\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_federation_invite_response_json(
                "{\"event\":{\"type\":\"m.room.member\",\"content\":{\"membership\":\"invite\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"event\":{\"content\":{\"membership\":\"invite\"},\"type\":\"m.room.member\"}},\"error\":null}"
        );
    }

    #[test]
    fn matrix_verification_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_verification_sas_flow_json(
                "{\"transport\":\"to_device\",\"transaction_id\":\"verif-txn-1\",\"steps\":[{\"type\":\"m.key.verification.request\",\"to_device\":true,\"content\":{\"transaction_id\":\"verif-txn-1\"}},{\"required\":true,\"result\":{\"verified\":true}}]}"
            ),
            "{\"ok\":true,\"value\":{\"transaction_id\":\"verif-txn-1\",\"transport\":\"to_device\",\"event_types\":[\"m.key.verification.request\"],\"verified\":true,\"local_sas_allowed\":false,\"versions_advertisement_widened\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_verification_cancel_json(
                "{\"transaction_id\":\"verif-txn-mismatch\",\"steps\":[{\"type\":\"m.key.verification.cancel\",\"to_device\":true,\"content\":{\"code\":\"m.mismatched_sas\",\"reason\":\"Short authentication string did not match\",\"transaction_id\":\"verif-txn-mismatch\"}},{\"result\":{\"verified\":false}}]}"
            ),
            "{\"ok\":true,\"value\":{\"transaction_id\":\"verif-txn-mismatch\",\"code\":\"m.mismatched_sas\",\"reason\":\"Short authentication string did not match\",\"verified\":false,\"versions_advertisement_widened\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_cross_signing_device_signing_upload_json(
                "{\"master_key\":{\"user_id\":\"@alice:example.test\",\"usage\":[\"master\"],\"keys\":{\"ed25519:master\":\"master-public\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:ALICE1\":\"signature\"}}}}"
            ),
            "{\"ok\":true,\"value\":{\"master_key\":{\"user_id\":\"@alice:example.test\",\"usage\":[\"master\"],\"keys\":{\"ed25519:master\":\"master-public\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:ALICE1\":\"signature\"}}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_cross_signing_invalid_signature_failure_json(
                "{\"status\":400,\"error\":{\"errcode\":\"M_INVALID_SIGNATURE\",\"error\":\"Invalid signature\"}}"
            ),
            "{\"ok\":true,\"value\":{\"status\":400,\"errcode\":\"M_INVALID_SIGNATURE\",\"error\":\"Invalid signature\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_device_key_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_keys_upload_request_json(
                "{\"device_keys\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"algorithms\":[\"m.olm.v1.curve25519-aes-sha2\",\"m.megolm.v1.aes-sha2\"],\"keys\":{\"curve25519:DEVICE1\":\"curve25519-public-device1\",\"ed25519:DEVICE1\":\"ed25519-public-device1\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-device1\"}}},\"one_time_keys\":{\"signed_curve25519:otk1\":{\"key\":\"one-time-public-key-1\",\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-otk1\"}}}},\"fallback_keys\":{\"signed_curve25519:fb1\":{\"key\":\"fallback-public-key-1\",\"fallback\":true,\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-fb1\"}}}}}",
            ),
            "{\"ok\":true,\"value\":{\"device_keys\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"algorithms\":[\"m.olm.v1.curve25519-aes-sha2\",\"m.megolm.v1.aes-sha2\"],\"keys\":{\"curve25519:DEVICE1\":\"curve25519-public-device1\",\"ed25519:DEVICE1\":\"ed25519-public-device1\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-device1\"}}},\"one_time_keys\":{\"signed_curve25519:otk1\":{\"key\":\"one-time-public-key-1\",\"fallback\":false,\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-otk1\"}}}},\"fallback_keys\":{\"signed_curve25519:fb1\":{\"key\":\"fallback-public-key-1\",\"fallback\":true,\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-fb1\"}}}},\"private_key_material_returned\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_keys_upload_response_json(
                "{\"one_time_key_counts\":{\"signed_curve25519\":1}}"
            ),
            "{\"ok\":true,\"value\":{\"one_time_key_counts\":{\"signed_curve25519\":1},\"private_key_material_returned\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_keys_claim_request_json(
                "{\"one_time_keys\":{\"@alice:example.test\":{\"DEVICE1\":\"signed_curve25519\"}}}",
            ),
            "{\"ok\":true,\"value\":{\"one_time_keys\":{\"@alice:example.test\":{\"DEVICE1\":\"signed_curve25519\"}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_keys_claim_response_json(
                "{\"failures\":{},\"one_time_keys\":{\"@alice:example.test\":{\"DEVICE1\":{\"signed_curve25519:fb1\":{\"key\":\"fallback-public-key-1\",\"fallback\":true,\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-fb1\"}}}}}}}",
            ),
            "{\"ok\":true,\"value\":{\"failures\":{},\"one_time_keys\":{\"@alice:example.test\":{\"DEVICE1\":{\"signed_curve25519:fb1\":{\"key\":\"fallback-public-key-1\",\"fallback\":true,\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-fb1\"}}}}}},\"fallback_key_returned\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_device_key_error_json(
                "{\"status\":400,\"error\":{\"errcode\":\"M_INVALID_PARAM\",\"error\":\"Unsupported one-time key algorithm.\"}}",
            ),
            "{\"ok\":true,\"value\":{\"status\":400,\"errcode\":\"M_INVALID_PARAM\",\"error\":\"Unsupported one-time key algorithm.\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_device_key_query_request_json(
                "{\"device_keys\":{\"@alice:example.test\":[\"DEVICE1\"]},\"timeout\":10000}",
            ),
            "{\"ok\":true,\"value\":{\"device_keys\":{\"@alice:example.test\":[\"DEVICE1\"]},\"timeout\":10000},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_device_key_query_response_json(
                "{\"failures\":{},\"device_keys\":{\"@alice:example.test\":{\"DEVICE1\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"algorithms\":[\"m.olm.v1.curve25519-aes-sha2\",\"m.megolm.v1.aes-sha2\"],\"keys\":{\"curve25519:DEVICE1\":\"curve25519-public-device1\",\"ed25519:DEVICE1\":\"ed25519-public-device1\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-device1\"}}}}}}",
            ),
            "{\"ok\":true,\"value\":{\"failures\":{},\"device_keys\":{\"@alice:example.test\":{\"DEVICE1\":{\"user_id\":\"@alice:example.test\",\"device_id\":\"DEVICE1\",\"algorithms\":[\"m.olm.v1.curve25519-aes-sha2\",\"m.megolm.v1.aes-sha2\"],\"keys\":{\"curve25519:DEVICE1\":\"curve25519-public-device1\",\"ed25519:DEVICE1\":\"ed25519-public-device1\"},\"signatures\":{\"@alice:example.test\":{\"ed25519:DEVICE1\":\"signature-device1\"}}}}},\"private_key_material_returned\":false,\"trust_decision_made\":false},\"error\":null}"
        );
    }

    #[test]
    fn matrix_room_directory_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_public_rooms_request_json(
                "{\"limit\":10,\"filter\":{\"generic_search_term\":\"project\"},\"include_all_networks\":false}",
            ),
            "{\"ok\":true,\"value\":{\"limit\":10,\"generic_search_term\":\"project\",\"include_all_networks\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_public_rooms_response_json(
                "{\"chunk\":[{\"room_id\":\"!room:example.test\",\"num_joined_members\":2,\"world_readable\":false,\"guest_can_join\":false,\"canonical_alias\":\"#project:example.test\",\"join_rule\":\"public\"}],\"total_room_count_estimate\":1}",
            ),
            "{\"ok\":true,\"value\":{\"chunk\":[{\"room_id\":\"!room:example.test\",\"num_joined_members\":2,\"world_readable\":false,\"guest_can_join\":false,\"canonical_alias\":\"#project:example.test\",\"join_rule\":\"public\"}],\"total_room_count_estimate\":1},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_directory_visibility_json("{\"visibility\":\"public\"}"),
            "{\"ok\":true,\"value\":{\"visibility\":\"public\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_aliases_json("{\"aliases\":[\"#project:example.test\"]}"),
            "{\"ok\":true,\"value\":{\"aliases\":[\"#project:example.test\"]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_invite_request_json(
                "{\"user_id\":\"@bob:example.test\",\"reason\":\"Join the project room\"}",
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@bob:example.test\",\"reason\":\"Join the project room\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_invite_room_json(
                "{\"room_id\":\"!room:example.test\",\"invite_state\":{\"events\":[{\"type\":\"m.room.member\",\"sender\":\"@alice:example.test\",\"state_key\":\"@bob:example.test\",\"content\":{\"membership\":\"invite\"}}]}}",
            ),
            "{\"ok\":true,\"value\":{\"room_id\":\"!room:example.test\",\"events\":[{\"type\":\"m.room.member\",\"sender\":\"@alice:example.test\",\"state_key\":\"@bob:example.test\",\"content\":{\"membership\":\"invite\"}}]},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_directory_error_json(
                "{\"status\":403,\"error\":{\"errcode\":\"M_FORBIDDEN\",\"error\":\"No permission\"}}",
            ),
            "{\"ok\":true,\"value\":{\"status\":403,\"errcode\":\"M_FORBIDDEN\",\"error\":\"No permission\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_moderation_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_moderation_request_json(
                "{\"user_id\":\"@bob:example.test\",\"reason\":\"Off topic\"}",
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@bob:example.test\",\"reason\":\"Off topic\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_redaction_request_json("{\"reason\":\"Remove spam\"}"),
            "{\"ok\":true,\"value\":{\"reason\":\"Remove spam\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_redaction_response_json("{\"event_id\":\"$redaction1:example.test\"}"),
            "{\"ok\":true,\"value\":{\"event_id\":\"$redaction1:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_report_request_json("{\"reason\":\"Room contains spam\"}"),
            "{\"ok\":true,\"value\":{\"reason\":\"Room contains spam\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_account_moderation_capability_json(
                "{\"capabilities\":{\"m.account_moderation\":{\"lock\":true,\"suspend\":true}}}",
            ),
            "{\"ok\":true,\"value\":{\"lock\":true,\"suspend\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_admin_account_moderation_status_json("{\"locked\":true}"),
            "{\"ok\":true,\"value\":{\"locked\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_moderation_error_json(
                "{\"status\":403,\"error\":{\"errcode\":\"M_FORBIDDEN\",\"error\":\"No permission\"}}",
            ),
            "{\"ok\":true,\"value\":{\"status\":403,\"errcode\":\"M_FORBIDDEN\",\"error\":\"No permission\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_key_backup_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_key_backup_version_create_response_json("{\"version\":\"1\"}"),
            "{\"ok\":true,\"value\":{\"version\":\"1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_version_json(
                "{\"version\":\"1\",\"algorithm\":\"m.megolm_backup.v1.curve25519-aes-sha2\",\"auth_data\":{\"public_key\":\"curve25519-public\",\"signatures\":{\"@alice:example.test\":{\"ed25519:ALICE1\":\"signature\"}}}}",
            ),
            "{\"ok\":true,\"value\":{\"version\":\"1\",\"algorithm\":\"m.megolm_backup.v1.curve25519-aes-sha2\",\"auth_data\":{\"public_key\":\"curve25519-public\",\"signatures\":{\"@alice:example.test\":{\"ed25519:ALICE1\":\"signature\"}}}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_session_json(
                "{\"first_message_index\":1,\"forwarded_count\":0,\"is_verified\":true,\"session_data\":{\"ephemeral\":\"ephemeral\",\"ciphertext\":\"ciphertext\",\"mac\":\"mac\"}}",
            ),
            "{\"ok\":true,\"value\":{\"first_message_index\":1,\"forwarded_count\":0,\"is_verified\":true,\"session_data\":{\"ciphertext\":\"ciphertext\",\"ephemeral\":\"ephemeral\",\"mac\":\"mac\"}},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_session_upload_response_json(
                "{\"etag\":\"etag-1\",\"count\":1}"
            ),
            "{\"ok\":true,\"value\":{\"etag\":\"etag-1\",\"count\":1},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_error_json(
                "{\"status\":403,\"error\":{\"errcode\":\"M_WRONG_ROOM_KEYS_VERSION\",\"error\":\"Wrong room keys version.\",\"current_version\":\"1\"}}",
            ),
            "{\"ok\":true,\"value\":{\"status\":403,\"errcode\":\"M_WRONG_ROOM_KEYS_VERSION\",\"error\":\"Wrong room keys version.\",\"current_version\":\"1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_owner_scope_gate_json(
                "{\"steps\":[{\"id\":\"alice-read-own-backup\",\"expected_status\":404,\"expected_error\":{\"errcode\":\"M_NOT_FOUND\"},\"must_not_disclose_protected_backup\":true},{\"id\":\"bob-read-alice-backup\",\"expected_status\":404,\"expected_error\":{\"errcode\":\"M_NOT_FOUND\"},\"must_not_disclose_protected_backup\":true},{\"id\":\"bob-overwrite-alice-backup\",\"expected_status\":404,\"expected_error\":{\"errcode\":\"M_NOT_FOUND\"},\"must_not_mutate_protected_backup\":true},{\"id\":\"alice-read-backup-after-bob-attempt\",\"expected_status\":404,\"expected_error\":{\"errcode\":\"M_NOT_FOUND\"},\"must_not_disclose_protected_backup\":true}]}",
            ),
            "{\"ok\":true,\"value\":{\"owner_scope_enforced\":true,\"protected_backup_unchanged\":true,\"checked_steps\":[\"alice-read-own-backup\",\"bob-read-alice-backup\",\"bob-overwrite-alice-backup\",\"alice-read-backup-after-bob-attempt\"],\"versions_advertisement_widened\":false},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_key_backup_recovery_gate_json(
                "{\"crypto_stack_required\":true,\"local_olm_megolm_allowed\":false,\"required_contracts\":[\"SPEC-050\",\"SPEC-052\",\"SPEC-053\"],\"required_evidence\":[\"decrypted_event_matches_pre_logout_plaintext\"],\"steps\":[{\"required\":true},{\"required\":true},{\"required\":true},{\"required\":true},{\"required\":true},{\"required\":true}]}",
            ),
            "{\"ok\":true,\"value\":{\"logout_relogin_restore\":true,\"crypto_stack_required\":true,\"local_olm_megolm_allowed\":false,\"required_contracts\":[\"SPEC-050\",\"SPEC-052\",\"SPEC-053\"],\"required_evidence\":[\"decrypted_event_matches_pre_logout_plaintext\"],\"versions_advertisement_widened\":false},\"error\":null}"
        );
    }

    #[test]
    fn matrix_registration_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_registration_availability_json("{\"available\":true}"),
            "{\"ok\":true,\"value\":{\"available\":true},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_registration_session_json(
                "{\"user_id\":\"@charlie:example.test\",\"access_token\":\"token-register\",\"device_id\":\"DEVICE2\",\"home_server\":\"example.test\"}",
            ),
            "{\"ok\":true,\"value\":{\"user_id\":\"@charlie:example.test\",\"access_token\":\"token-register\",\"device_id\":\"DEVICE2\",\"home_server\":\"example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_user_interactive_auth_required_json(
                "{\"completed\":[],\"flows\":[{\"stages\":[\"m.login.dummy\"]}],\"params\":{},\"session\":\"reg-session-1\"}",
            ),
            "{\"ok\":true,\"value\":{\"completed\":[],\"flows\":[{\"stages\":[\"m.login.dummy\"]}],\"params\":{},\"session\":\"reg-session-1\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_registration_token_validity_json("{\"valid\":false}"),
            "{\"ok\":true,\"value\":{\"valid\":false},\"error\":null}"
        );
    }

    #[test]
    fn matrix_device_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_device_json(
                "{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000}",
            ),
            "{\"ok\":true,\"value\":{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_devices_json(
                "{\"devices\":[{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000}]}",
            ),
            "{\"ok\":true,\"value\":{\"devices\":[{\"device_id\":\"DEVICE1\",\"display_name\":\"Alice phone\",\"last_seen_ip\":\"203.0.113.10\",\"last_seen_ts\":1710000000000}]},\"error\":null}"
        );
    }

    #[test]
    fn matrix_room_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_room_id_response_json("{\"room_id\":\"!room:example.test\"}"),
            "{\"ok\":true,\"value\":{\"room_id\":\"!room:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_client_event_json(
                "{\"event_id\":\"$name:example.test\",\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"origin_server_ts\":1710000000000,\"type\":\"m.room.name\",\"state_key\":\"\",\"content\":{\"name\":\"General\"}}",
            ),
            "{\"ok\":true,\"value\":{\"content\":{\"name\":\"General\"},\"event_id\":\"$name:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":\"\",\"type\":\"m.room.name\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_room_state_json(
                "[{\"event_id\":\"$name:example.test\",\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"origin_server_ts\":1710000000000,\"type\":\"m.room.name\",\"state_key\":\"\",\"content\":{\"name\":\"General\"}}]",
            ),
            "{\"ok\":true,\"value\":{\"events\":[{\"content\":{\"name\":\"General\"},\"event_id\":\"$name:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":\"\",\"type\":\"m.room.name\"}]},\"error\":null}"
        );
    }

    #[test]
    fn matrix_messaging_parsers_delegate_to_core_json_envelopes() {
        assert_eq!(
            parse_matrix_event_id_response_json("{\"event_id\":\"$event1:example.test\"}"),
            "{\"ok\":true,\"value\":{\"event_id\":\"$event1:example.test\"},\"error\":null}"
        );
        assert_eq!(
            parse_matrix_messages_response_json(
                "{\"chunk\":[{\"event_id\":\"$event1:example.test\",\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"origin_server_ts\":1710000000000,\"type\":\"m.room.message\",\"content\":{\"msgtype\":\"m.text\",\"body\":\"Hello Matrix\"}}],\"start\":\"t1\"}",
            ),
            "{\"ok\":true,\"value\":{\"chunk\":[{\"content\":{\"body\":\"Hello Matrix\",\"msgtype\":\"m.text\"},\"event_id\":\"$event1:example.test\",\"origin_server_ts\":1710000000000,\"room_id\":\"!room:example.test\",\"sender\":\"@alice:example.test\",\"state_key\":null,\"type\":\"m.room.message\"}],\"start\":\"t1\"},\"error\":null}"
        );
    }

    #[test]
    fn matrix_sync_parser_delegates_to_core_json_envelope() {
        assert_eq!(
            parse_matrix_sync_response_json(
                "{\"next_batch\":\"s1\",\"account_data\":{\"events\":[]},\"rooms\":{\"join\":{},\"invite\":{},\"leave\":{}}}",
            ),
            "{\"ok\":true,\"value\":{\"next_batch\":\"s1\",\"account_data\":{\"events\":[]},\"rooms\":{\"join\":{},\"invite\":{},\"leave\":{}}},\"error\":null}"
        );
    }
}
