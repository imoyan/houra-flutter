import 'package:okaka/okaka.dart';

Future<void> main() async {
  final client = OkakaClient(serverBaseUri: Uri.parse('https://example.test'));
  try {
    final versions = await client.discovery.fetchVersions();
    final flows = await client.auth.fetchLoginFlows();
    print('API version: ${versions.apiVersion}');
    print('Login flows: ${flows.flows.map((flow) => flow.type).join(', ')}');
  } finally {
    client.close();
  }
}
