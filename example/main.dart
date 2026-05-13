import 'dart:io';

import 'package:houra/houra.dart';

Future<void> main() async {
  final serverBaseUri = Uri.parse(
    Platform.environment['HOURA_BASE_URL'] ?? 'http://localhost:3000',
  );
  final client = HouraClient(serverBaseUri: serverBaseUri);
  try {
    final versions = await client.discovery.fetchVersions();
    final flows = await client.auth.fetchLoginFlows();
    print('API version: ${versions.apiVersion}');
    print('Login flows: ${flows.flows.map((flow) => flow.type).join(', ')}');
  } on HouraHttpException catch (error) {
    final details = [
      'status=${error.statusCode}',
      if (error.code != null) 'code=${error.code}',
      if (error.serverMessage != null) 'message=${error.serverMessage}',
    ].join(' ');
    stderr.writeln('Houra HTTP error: $details');
    exitCode = 1;
  } on HouraException catch (error) {
    stderr.writeln('Houra SDK error: ${error.message}');
    exitCode = 1;
  } finally {
    client.close();
  }
}
