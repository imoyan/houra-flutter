import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('Matrix push parser helpers follow SPEC-098 vector', () {
    final vector = readVector(
      'test-vectors/core/matrix-push-parser-helper-breadth.json',
    );
    expect(vector.raw['contract'], 'SPEC-098');

    final event = objectFrom(vector.raw, 'event');
    final cases = event['cases'] as List<Object?>;
    final parsedCases = cases
        .map((item) => (item as Map).cast<String, Object?>())
        .map(HouraMatrixPushParserEvidenceCase.fromJson)
        .toList();
    expect(parsedCases, hasLength(vector.expected['case_count']));
    expect(
      parsedCases.where((item) => item.result == 'accepted'),
      hasLength(vector.expected['accepted_case_count']),
    );
    expect(
      parsedCases.where((item) => item.result == 'rejected'),
      hasLength(vector.expected['rejected_case_count']),
    );
    expect(
      parsedCases.map((item) => item.kind),
      containsAll([
        'pusher_descriptor',
        'push_rule_descriptor',
        'sync_visibility_descriptor',
        'malformed_descriptor',
        'redaction_helper',
      ]),
    );

    final pusher = HouraMatrixPushPusherDescriptor.fromJson({
      'kind': 'http_pusher',
      'app_id': 'dev.houra.app',
      'app_display_name': 'Houra',
      'device_display_name': 'Device',
      'lang': 'en',
      'profile_tag': 'main',
      'format': 'event_id_only',
      'url': 'https://push.example.test/_matrix/push/v1/notify',
      'replacement_policy': 'replace_by_app_id_pushkey',
    });
    expect(pusher.url.path, '/_matrix/push/v1/notify');
    expect(pusher.format, 'event_id_only');

    final rule = HouraMatrixPushRuleDescriptor.fromJson({
      'kind': 'content',
      'rule_id': 'cake-rule',
      'enabled': true,
      'conditions': [
        {'kind': 'event_match', 'key': 'content.body', 'pattern': 'cake'},
      ],
      'actions': [
        'notify',
        {'set_tweak': 'sound', 'value': 'default'},
      ],
      'tweaks': {'sound': 'default'},
    });
    expect(rule.ruleId, 'cake-rule');
    expect(rule.actions, hasLength(2));

    final redacted = const HouraMatrixPushEvidenceRedactor().redact({
      'pushkey': 'raw-pushkey',
      'nested': {'vendor_token': 'raw-token'},
      'kept': 'metadata',
    });
    expect(redacted['pushkey'], 'push-redacted');
    expect((redacted['nested']! as Map)['vendor_token'], 'push-redacted');
    expect(redacted['kept'], 'metadata');
  });

  test('Matrix push parser helpers reject malformed SPEC-098 inputs', () {
    expect(
      () => HouraMatrixPushPusherDescriptor.fromJson({
        'kind': 'http_pusher',
        'app_id': 'dev.houra.app',
        'app_display_name': 'Houra',
        'device_display_name': 'Device',
        'lang': 'en',
        'url': 'http://push.example.test/_matrix/push/v1/notify',
        'replacement_policy': 'replace_by_app_id_pushkey',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixPushPusherDescriptor.fromJson({
        'kind': 'http_pusher',
        'app_id': 'dev.houra.app',
        'app_display_name': 'Houra',
        'device_display_name': 'Device',
        'lang': 'en',
        'url': 'https://user@push.example.test/_matrix/push/v1/notify#x',
        'replacement_policy': 'replace_by_app_id_pushkey',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixPushRuleDescriptor.fromJson({
        'kind': 'content',
        'rule_id': '.reserved',
        'enabled': true,
        'conditions': <Object?>[],
        'actions': ['notify'],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixPushRuleDescriptor.fromJson({
        'kind': 'override',
        'rule_id': 'bad-action',
        'enabled': true,
        'conditions': <Object?>[],
        'actions': [
          {'value': 'default'},
        ],
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}
