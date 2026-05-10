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
  } finally {
    client.close();
  }
}
