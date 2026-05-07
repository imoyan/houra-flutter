/// Base class for houra SDK exceptions.
abstract class HouraException implements Exception {
  const HouraException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a request fails before an HTTP response is received.
final class HouraTransportException extends HouraException {
  const HouraTransportException(
    super.message, {
    this.cause,
    this.stackTrace,
  });

  final Object? cause;
  final StackTrace? stackTrace;
}

/// Thrown when an HTTP response has a non-success status code.
final class HouraHttpException extends HouraException {
  HouraHttpException({
    required this.statusCode,
    required this.uri,
    required this.responseBody,
    this.code,
    this.serverMessage,
  }) : super(
          _httpMessage(statusCode, uri, responseBody, code, serverMessage),
        );

  final int statusCode;
  final Uri uri;
  final String responseBody;
  final String? code;
  final String? serverMessage;

  String get responseBodySummary => _summarize(responseBody);
}

/// Thrown when a successful response does not match the expected contract.
final class HouraResponseFormatException extends HouraException {
  const HouraResponseFormatException(super.message);
}

/// Thrown when a shared theme token file is malformed.
final class HouraThemeFormatException extends HouraException {
  const HouraThemeFormatException(super.message);
}

String _summarize(String body) {
  final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= 200) {
    return normalized;
  }
  return '${normalized.substring(0, 197)}...';
}

String _httpMessage(
  int statusCode,
  Uri uri,
  String responseBody,
  String? code,
  String? serverMessage,
) {
  final parts = [
    'HTTP $statusCode from $uri',
    if (code != null) code,
    if (serverMessage != null) serverMessage,
    _summarize(responseBody),
  ];
  return parts.where((part) => part.isNotEmpty).join(': ');
}
