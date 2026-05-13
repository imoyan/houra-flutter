/// Base class for typed Houra SDK exceptions.
abstract class HouraException implements Exception {
  const HouraException(this.message);

  /// Human-readable failure summary.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a request fails before an HTTP response is received.
final class HouraTransportException extends HouraException {
  const HouraTransportException(super.message, {this.cause, this.stackTrace});

  /// Original transport-layer cause, when available.
  final Object? cause;

  /// Original stack trace for [cause], when available.
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
  }) : super(_httpMessage(statusCode, uri, code, serverMessage));

  /// HTTP status code returned by the server.
  final int statusCode;

  /// Fully resolved request URI.
  final Uri uri;

  /// Raw response body. Hosts should avoid logging it when it may contain
  /// sensitive application data.
  final String responseBody;

  /// Contract error code parsed from the response body, when present.
  final String? code;

  /// Contract error message parsed from the response body, when present.
  final String? serverMessage;

  /// Short, whitespace-normalized response body for diagnostics.
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
  String? code,
  String? serverMessage,
) {
  final parts = [
    'HTTP $statusCode from $uri',
    if (code != null) code,
    if (serverMessage != null) serverMessage,
  ];
  return parts.where((part) => part.isNotEmpty).join(': ');
}
