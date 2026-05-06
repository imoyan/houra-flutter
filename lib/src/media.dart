import 'models.dart';
import 'transport.dart';

/// Media endpoints for metadata and base64 upload.
final class OkakaMediaClient {
  const OkakaMediaClient(this._transport);

  final OkakaTransport _transport;

  Future<OkakaMediaUpload> uploadBase64({
    required String accessToken,
    required String filename,
    required String contentType,
    required String bytesBase64,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'POST',
        pathSegments: const ['_chawan', 'client', 'media'],
        accessToken: accessToken,
        body: {
          'filename': filename,
          'content_type': contentType,
          'bytes_base64': bytesBase64,
        },
      ),
    );
    return OkakaMediaUpload.fromJson(response.jsonObject);
  }

  Future<OkakaMediaMetadata> getMetadata({
    required String accessToken,
    required String mediaId,
  }) async {
    final response = await _transport.send(
      OkakaRequest(
        method: 'GET',
        pathSegments: ['_chawan', 'client', 'media', mediaId],
        accessToken: accessToken,
      ),
    );
    return OkakaMediaMetadata.fromJson(response.jsonObject);
  }
}
