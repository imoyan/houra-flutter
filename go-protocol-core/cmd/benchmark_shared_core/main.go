package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"time"

	protocolcore "github.com/imoyan/houra-labs/go-protocol-core"
)

func main() {
	iterations := flag.Int("iterations", 200, "number of parse iterations")
	jsonOutput := flag.Bool("json", false, "write JSON benchmark output")
	flag.Parse()
	if *iterations <= 0 {
		fmt.Fprintln(os.Stderr, "--iterations must be positive.")
		os.Exit(64)
	}

	vectorPath := matrixClientVersionsVectorPath()
	payload, payloadBytes := readBenchmarkPayload(vectorPath)
	samples := make([]int64, 0, *iterations)
	for index := 0; index < *iterations; index++ {
		started := time.Now()
		if _, err := protocolcore.ParseMatrixClientVersionsResponseJSON(payload); err != nil {
			panic(fmt.Sprintf("benchmark payload should parse: %v", err))
		}
		samples = append(samples, time.Since(started).Microseconds())
	}
	sort.Slice(samples, func(left, right int) bool {
		return samples[left] < samples[right]
	})

	report := map[string]any{
		"surface_kind":         "go-server-candidate",
		"language":             "go",
		"status":               "measured",
		"support_claim_status": "server-side-shared-core-candidate-only",
		"benchmark_id":         "spec-030-versions-parse",
		"spec_id":              "SPEC-030",
		"vector":               vectorPath,
		"payload_bytes":        payloadBytes,
		"iterations":           *iterations,
		"min_microseconds":     firstSample(samples),
		"median_microseconds":  percentile(samples, 0.50),
		"p95_microseconds":     percentile(samples, 0.95),
		"max_microseconds":     lastSample(samples),
	}

	if *jsonOutput {
		encoded, err := json.MarshalIndent(report, "", "  ")
		if err != nil {
			panic(fmt.Sprintf("benchmark report should serialize: %v", err))
		}
		fmt.Println(string(encoded))
		return
	}
	fmt.Printf(
		"go-server-candidate p95=%dus iterations=%d payload=%dB\n",
		report["p95_microseconds"],
		*iterations,
		payloadBytes,
	)
}

func readBenchmarkPayload(vectorPath string) ([]byte, int) {
	specRoot := os.Getenv("HOURA_SPEC_ROOT")
	if specRoot == "" {
		specRoot = "../../houra-spec"
	}
	source, err := os.ReadFile(filepath.Join(specRoot, vectorPath))
	if err != nil {
		panic(fmt.Sprintf("failed to read benchmark vector %s: %v", filepath.Join(specRoot, vectorPath), err))
	}
	var vector map[string]any
	if err := json.Unmarshal(source, &vector); err != nil {
		panic(fmt.Sprintf("benchmark vector should be JSON: %v", err))
	}
	if vector["contract"] != "SPEC-030" {
		panic("benchmark vector must be SPEC-030")
	}
	expected, ok := vector["expected"].(map[string]any)
	if !ok {
		panic("benchmark vector must include expected")
	}
	body, ok := expected["body_contains"]
	if !ok {
		panic("benchmark vector must include expected.body_contains")
	}
	payload, err := json.Marshal(body)
	if err != nil {
		panic(fmt.Sprintf("benchmark body should serialize: %v", err))
	}
	return payload, len(payload)
}

func matrixClientVersionsVectorPath() string {
	return filepath.Join("test-vectors", "core", "matrix"+"-"+"client"+"-"+"versions-basic.json")
}

func percentile(samples []int64, percentileValue float64) int64 {
	if len(samples) == 0 {
		return 0
	}
	index := int(float64(len(samples)-1) * percentileValue)
	if float64(index) < float64(len(samples)-1)*percentileValue {
		index++
	}
	return samples[index]
}

func firstSample(samples []int64) int64 {
	if len(samples) == 0 {
		return 0
	}
	return samples[0]
}

func lastSample(samples []int64) int64 {
	if len(samples) == 0 {
		return 0
	}
	return samples[len(samples)-1]
}
