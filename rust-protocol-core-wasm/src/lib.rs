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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn artifact_manifest_marks_wasm_binding_kind() {
        let json = houra_artifact_manifest_json();

        assert_eq!(
            json,
            "{\"manifest_schema_version\":1,\"crate_name\":\"houra-protocol-core\",\"crate_version\":\"0.1.0\",\"abi_version\":1,\"protocol_boundary\":\"pure-protocol-core\",\"supported_specs\":[\"SPEC-030\",\"SPEC-031\"],\"supported_binding_kinds\":[\"wasm\"]}"
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
}
