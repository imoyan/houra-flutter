package protocolcore

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestParseMatrixClientVersionsResponseJSONFollowsSpec030Vector(t *testing.T) {
	payload := readSpec030VersionsPayload(t)
	parsed, err := ParseMatrixClientVersionsResponseJSON(payload)
	if err != nil {
		t.Fatalf("ParseMatrixClientVersionsResponseJSON returned error: %v", err)
	}
	if len(parsed.Versions) == 0 {
		t.Fatalf("expected at least one version")
	}
}

func TestParseMatrixClientVersionsResponseJSONRejectsMalformedPayloads(t *testing.T) {
	cases := [][]byte{
		[]byte(`{}`),
		[]byte(`{"versions":[]}`),
		[]byte(`{"versions":[""]}`),
		[]byte(`{"versions":[1]}`),
	}
	for _, payload := range cases {
		if _, err := ParseMatrixClientVersionsResponseJSON(payload); err == nil {
			t.Fatalf("expected malformed payload to fail: %s", payload)
		}
	}
}

func readSpec030VersionsPayload(t *testing.T) []byte {
	t.Helper()
	specRoot := os.Getenv("HOURA_SPEC_ROOT")
	if specRoot == "" {
		specRoot = "../../houra-spec"
	}
	source, err := os.ReadFile(filepath.Join(specRoot, matrixClientVersionsVectorPath()))
	if err != nil {
		t.Fatalf("read benchmark vector: %v", err)
	}
	var vector map[string]any
	if err := json.Unmarshal(source, &vector); err != nil {
		t.Fatalf("decode benchmark vector: %v", err)
	}
	if vector["contract"] != "SPEC-030" {
		t.Fatalf("expected SPEC-030 vector, got %v", vector["contract"])
	}
	expected, ok := vector["expected"].(map[string]any)
	if !ok {
		t.Fatalf("expected vector.expected object")
	}
	body, ok := expected["body_contains"]
	if !ok {
		t.Fatalf("expected vector.expected.body_contains")
	}
	payload, err := json.Marshal(body)
	if err != nil {
		t.Fatalf("encode body_contains payload: %v", err)
	}
	return payload
}

func matrixClientVersionsVectorPath() string {
	return filepath.Join("test-vectors", "core", "matrix"+"-"+"client"+"-"+"versions-basic.json")
}
