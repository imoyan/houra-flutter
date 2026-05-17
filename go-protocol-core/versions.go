package protocolcore

import (
	"encoding/json"
	"fmt"
)

type MatrixClientVersionsResponse struct {
	Versions         []string        `json:"versions"`
	UnstableFeatures map[string]bool `json:"unstable_features"`
}

func ParseMatrixClientVersionsResponseJSON(payload []byte) (MatrixClientVersionsResponse, error) {
	var decoded MatrixClientVersionsResponse
	if err := json.Unmarshal(payload, &decoded); err != nil {
		return MatrixClientVersionsResponse{}, err
	}
	if len(decoded.Versions) == 0 {
		return MatrixClientVersionsResponse{}, fmt.Errorf("versions must be non-empty")
	}
	for index, version := range decoded.Versions {
		if version == "" {
			return MatrixClientVersionsResponse{}, fmt.Errorf("versions[%d] must be non-empty", index)
		}
	}
	if decoded.UnstableFeatures == nil {
		decoded.UnstableFeatures = map[string]bool{}
	}
	return decoded, nil
}
