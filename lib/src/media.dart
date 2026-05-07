import 'models.dart';
import 'transport.dart';

/// Media endpoints for metadata and base64 upload.
final class HouraMediaClient {
  const HouraMediaClient(this._transport);

  final HouraTransport _transport;

  Future<HouraMediaUpload> uploadBase64({
    required String accessToken,
    required String filename,
    required String contentType,
    required String bytesBase64,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_ichi-go', 'client', 'media'],
        accessToken: accessToken,
        body: {
          'filename': filename,
          'content_type': contentType,
          'bytes_base64': bytesBase64,
        },
      ),
    );
    return HouraMediaUpload.fromJson(response.jsonObject);
  }

  Future<HouraMediaMetadata> getMetadata({
    required String accessToken,
    required String mediaId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: ['_ichi-go', 'client', 'media', mediaId],
        accessToken: accessToken,
      ),
    );
    return HouraMediaMetadata.fromJson(response.jsonObject);
  }
}
