import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:houra/houra.dart';

import 'vector_test_support.dart';

void main() {
  test('uploadBase64 follows SPEC-020 vector', () async {
    final vector = readVector('test-vectors/media/upload-basic.json');
    final requestBody = objectFrom(vector.request, 'body');
    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final upload = await client.media.uploadBase64(
      accessToken: 'token-1',
      filename: requestBody['filename'] as String,
      contentType: requestBody['content_type'] as String,
      bytesBase64: requestBody['bytes_base64'] as String,
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(observed.headers['authorization'], 'Bearer token-1');
    expect(jsonDecode(observed.body), requestBody);
    expect(upload.mediaId, vector.bodyContains['media_id']);
    expect(upload.contentUri, vector.bodyContains['content_uri']);
  });

  test('getMetadata follows SPEC-020 vector', () async {
    final vector =
        readVector('test-vectors/media/download-metadata-basic.json');
    late http.Request observed;
    final client = _client((request) async {
      observed = request;
      return http.Response(jsonEncode(vector.bodyContains), 200);
    });

    final metadata = await client.media.getMetadata(
      accessToken: 'token-1',
      mediaId: 'media1',
    );

    expect(observed.method, vector.request['method']);
    expect(observed.url.path, vector.request['path']);
    expect(metadata.mediaId, vector.bodyContains['media_id']);
    expect(metadata.filename, vector.bodyContains['filename']);
    expect(metadata.contentType, vector.bodyContains['content_type']);
    expect(metadata.downloadUrl, vector.bodyContains['download_url']);
  });

  test('media parsers reject malformed responses', () {
    expect(
      () => HouraMediaUpload.fromJson({'media_id': 'media1'}),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMediaMetadata.fromJson({
        'media_id': 'media1',
        'content_type': 'image/png',
        'download_url': '',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
  });
}

HouraClient _client(Future<http.Response> Function(http.Request) handler) {
  return HouraClient(
    serverBaseUri: Uri.parse('https://example.test'),
    httpClient: MockClient(handler),
  );
}
