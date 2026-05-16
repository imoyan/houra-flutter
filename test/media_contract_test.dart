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
    final vector = readVector(
      'test-vectors/media/download-metadata-basic.json',
    );
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

  test('Matrix media repository parsers follow SPEC-095 vector', () {
    final vector = readVector(
      'test-vectors/media/matrix-media-repository-breadth.json',
    );
    final event = objectFrom(vector.raw, 'event');
    final descriptors = event['request_descriptors'] as List<Object?>;
    final responses = objectFrom(event, 'sample_responses');

    final parsedDescriptors = descriptors
        .map((descriptor) => (descriptor as Map).cast<String, Object?>())
        .map(HouraMatrixMediaRequestDescriptor.fromJson)
        .toList();
    expect(parsedDescriptors, hasLength(vector.expected['descriptor_count']));
    expect(parsedDescriptors.first.id, 'media-config');
    expect(parsedDescriptors.first.responseParser, 'media_config');

    final config = HouraMatrixMediaConfig.fromJson(
      objectFrom(responses, 'media_config'),
    );
    expect(config.uploadSize, vector.expected['upload_size']);

    final preview = HouraMatrixMediaPreviewMetadata.fromJson(
      objectFrom(responses, 'preview_url'),
    );
    expect(preview.imageUri, vector.expected['preview_image_uri']);

    final thumbnail = HouraMatrixMediaThumbnailMetadata.fromJson(
      objectFrom(responses, 'thumbnail_metadata'),
    );
    expect(thumbnail.contentUri, vector.expected['thumbnail_uri']);
    expect(thumbnail.method, 'scale');

    final uploadCreate = HouraMatrixMediaAsyncUploadMetadata.fromJson(
      objectFrom(responses, 'upload_create'),
    );
    expect(uploadCreate.contentUri, vector.expected['upload_create_uri']);

    final disposition = HouraMatrixMediaContentDisposition.parse(
      responses['content_disposition'] as String,
    );
    expect(disposition.filename, vector.expected['safe_filename']);

    expect(
      () => HouraMatrixMediaContentDisposition.parse(
        responses['unsafe_content_disposition'] as String,
      ),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixMediaContentDisposition.parse(
        'attachment; filename="avatar%2Epng"',
      ),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixMediaRequestDescriptor.fromJson({
        'id': 'media-config-invalid-query',
        'method': 'GET',
        'path': '/_matrix/client/v1/media/config',
        'path_params': <String, Object?>{},
        'query_params': {'url': 'https://example.test/article'},
        'requires_auth': true,
        'adopted_runtime_behavior': false,
        'response_parser': 'media_config',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixMediaRequestDescriptor.fromJson({
        'id': 'media-preview-url-missing-url',
        'method': 'GET',
        'path': '/_matrix/client/v1/media/preview_url',
        'path_params': <String, Object?>{},
        'query_params': {'ts': 1710000000000},
        'requires_auth': true,
        'adopted_runtime_behavior': false,
        'response_parser': 'media_preview_url',
      }),
      throwsA(isA<HouraResponseFormatException>()),
    );
    expect(
      () => HouraMatrixMediaThumbnailMetadata.fromJson({
        'content_uri': 'mxc://example.test/thumb1',
        'content_type': 'image/png',
        'width': 64,
        'height': 64,
        'method': 'stretch',
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
