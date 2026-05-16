import 'package:flutter_test/flutter_test.dart';

import '../example/main.dart' as example;

void main() {
  test('example runs the public SDK surface against a fake host server',
      () async {
    final logs = <String>[];

    final summary = await example.runSdkUsageExample(log: logs.add);

    expect(summary.apiVersion, '0.2.0-example');
    expect(summary.loginFlowTypes, ['houra.login.password']);
    expect(summary.userId, '@alice:example.test');
    expect(summary.roomNames, ['Demo room']);
    expect(summary.timelineBodies, ['Welcome to Houra']);
    expect(summary.sentEventId, 'event-2');
    expect(summary.mediaFilename, 'sample.txt');
    expect(summary.nextBatch, 'sync-2');
    expect(summary.lightBackground, '#F7FAFC');
    expect(logs, contains('Next sync token: sync-2'));
  });
}
