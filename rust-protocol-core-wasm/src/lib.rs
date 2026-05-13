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

#[wasm_bindgen(js_name = parseMatrixMessagesResponseJson)]
pub fn parse_matrix_messages_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_messages_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixSyncResponseJson)]
pub fn parse_matrix_sync_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_sync_response_json(response_body.as_bytes())
}

#[wasm_bindgen(js_name = parseMatrixMediaContentUriJson)]
pub fn parse_matrix_media_content_uri_json(content_uri: &str) -> String {
    houra_protocol_core::parse_matrix_media_content_uri_json(content_uri)
}

#[wasm_bindgen(js_name = parseMatrixMediaUploadResponseJson)]
pub fn parse_matrix_media_upload_response_json(response_body: &str) -> String {
    houra_protocol_core::parse_matrix_media_upload_response_json(response_body.as_bytes())
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
            .any(|spec| spec == "SPEC-056"));
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
    fn matrix_federation_parsers_delegate_to_core_json_envelopes() {
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
