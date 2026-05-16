import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Room Version event-format artifacts follow SPEC-078 and SPEC-083', () {
    final inventory = readVector(
      'test-vectors/rooms/matrix-room-versions-full-algorithm-gap-inventory.json',
    );
    expect(inventory.raw['contract'], 'SPEC-078');
    final roomVersions = HouraMatrixRoomVersionsGapInventory.fromJson(
      inventory.raw,
    );
    expect(roomVersions.releaseScopeDecision.advertisementAllowed, isFalse);

    final eventFormatLane = roomVersions.lane(
      'per-version-event-format-id-hash-signature-limit-breadth',
    );
    expect(
      eventFormatLane.endpointExamples,
      containsAll([
        'event hash validation',
        'event signature validation',
        'canonical JSON',
        'redacted event content retention',
      ]),
    );
    expect(eventFormatLane.advertisementAllowed, isFalse);

    final artifactVector = readVector(
      'test-vectors/events/matrix-room-version-event-decision-artifacts.json',
    );
    expect(artifactVector.raw['contract'], 'SPEC-083');
    final artifact = HouraMatrixRoomVersionEventDecisionArtifact.fromJson(
      artifactVector.raw,
    );
    expect(artifact.roomVersion, artifactVector.expected['room_version']);
    expect(artifact.decisions,
        hasLength(artifactVector.expected['decision_count']));
    expect(
      artifact.resourceBounds.maxBatchDecisions,
      artifactVector.expected['max_batch_decisions'],
    );
    expect(artifact.releaseEvidenceRules.versionsAdvertisementWidened, isFalse);
    expect(
        artifact.releaseEvidenceRules.fullRoomVersionAlgorithmClaimed, isFalse);

    final rejected = artifact.decisions.singleWhere(
      (decision) => decision.outcome == 'rejected',
    );
    expect(rejected.visibleIn.anyVisible, isFalse);

    final tooManyDecisions = Map<String, Object?>.from(artifactVector.raw);
    final event =
        Map<String, Object?>.from(objectFrom(tooManyDecisions, 'event'));
    final decisions = event['decisions'] as List<Object?>;
    event['decisions'] = List<Object?>.filled(
      artifact.resourceBounds.maxBatchDecisions + 1,
      decisions.first,
    );
    tooManyDecisions['event'] = event;
    expect(
      () => HouraMatrixRoomVersionEventDecisionArtifact.fromJson(
        tooManyDecisions,
      ),
      throwsA(isA<HouraResponseFormatException>()),
    );

    final widened = Map<String, Object?>.from(artifactVector.raw);
    final widenedEvent =
        Map<String, Object?>.from(objectFrom(widened, 'event'));
    widenedEvent['resource_bounds'] = {
      ...objectFrom(widenedEvent, 'resource_bounds'),
      'network_lookup_allowed': true,
    };
    widened['event'] = widenedEvent;
    expect(
      () => HouraMatrixRoomVersionEventDecisionArtifact.fromJson(widened),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });

  test(
      'Room Version auth and state-resolution fixture runners stay fail closed',
      () {
    final vector = readVector(
      'test-vectors/rooms/matrix-room-versions-full-algorithm-gap-inventory.json',
    );
    final inventory = HouraMatrixRoomVersionsGapInventory.fromJson(vector.raw);

    final auth = inventory.runAuthRuleFixtureInventory();
    expect(auth.runner, 'room-version-auth-rule-fixture-runner');
    expect(auth.laneId, 'authorization-rules-breadth');
    expect(auth.advertisementAllowed, isFalse);
    expect(auth.matchedExamples, hasLength(4));

    final state = inventory.runStateResolutionFixtureInventory();
    expect(state.runner, 'room-version-state-resolution-fixture-runner');
    expect(state.laneId, 'state-resolution-algorithm-breadth');
    expect(state.advertisementAllowed, isFalse);
    expect(state.matchedExamples, hasLength(6));
  });

  test('E2EE full-breadth parser artifact inventory follows SPEC-079', () {
    final vector = readVector(
      'test-vectors/messaging/matrix-olm-megolm-full-e2ee-gap-inventory.json',
    );
    expect(vector.raw['contract'], 'SPEC-079');
    final inventory = HouraMatrixE2eeGapInventory.fromJson(vector.raw);

    expect(inventory.releaseScopeDecision.domain, 'Olm & Megolm');
    expect(inventory.releaseScopeDecision.advertisementAllowed, isFalse);
    expect(
        inventory.releaseEvidenceRules.versionsAdvertisementWidened, isFalse);
    expect(inventory.coveredSubsetContracts, contains('SPEC-054'));

    final runner = inventory.runParserArtifactInventory();
    expect(runner.runner, 'e2ee-parser-artifact-fixture-runner');
    expect(
      runner.laneId,
      'shared-parser-artifacts-security-release-evidence-breadth',
    );
    expect(runner.advertisementAllowed, isFalse);
    expect(runner.matchedExamples, hasLength(4));

    final lane = inventory
        .lane('shared-parser-artifacts-security-release-evidence-breadth');
    expect(lane.ownerRepos, contains('houra-labs'));
    expect(lane.relatedContracts, hasLength(4));
  });
}
