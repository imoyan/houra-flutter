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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn artifact_manifest_marks_wasm_binding_kind() {
        let json = houra_artifact_manifest_json();

        assert_eq!(
            json,
            "{\"manifest_schema_version\":1,\"crate_name\":\"houra-protocol-core\",\"crate_version\":\"0.1.0\",\"abi_version\":1,\"protocol_boundary\":\"pure-protocol-core\",\"supported_specs\":[\"SPEC-030\"],\"supported_binding_kinds\":[\"wasm\"]}"
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
}
