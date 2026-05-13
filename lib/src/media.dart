import 'models.dart';
import 'transport.dart';

/// Media endpoints for metadata and base64 upload.
final class HouraMediaClient {
  const HouraMediaClient(this._transport);

  final HouraTransport _transport;

  /// Uploads a base64 payload and returns the server media descriptor.
  ///
  /// Media transport and storage remain host-owned. This helper only maps the
  /// covered SPEC-020 request and response shape.
  Future<HouraMediaUpload> uploadBase64({
    required String accessToken,
    required String filename,
    required String contentType,
    required String bytesBase64,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'POST',
        pathSegments: const ['_houra', 'client', 'media'],
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

  /// Fetches media metadata for a server-owned media ID.
  Future<HouraMediaMetadata> getMetadata({
    required String accessToken,
    required String mediaId,
  }) async {
    final response = await _transport.send(
      HouraRequest(
        method: 'GET',
        pathSegments: ['_houra', 'client', 'media', mediaId],
        accessToken: accessToken,
      ),
    );
    return HouraMediaMetadata.fromJson(response.jsonObject);
  }
}
