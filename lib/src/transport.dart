import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'errors.dart';

final class HouraRequest {
  HouraRequest({
    required this.method,
    required this.pathSegments,
    Map<String, String> queryParameters = const {},
    Map<String, String> headers = const {},
    String? accessToken,
    Object? body,
  })  : queryParameters = _validateQueryParameters(queryParameters),
        headers = Map.unmodifiable(headers),
        accessToken = _validateAccessToken(accessToken),
        body = body == null ? null : _validateJsonBody(body);

  final String method;
  final List<String> pathSegments;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final String? accessToken;
  final Object? body;
}

final class HouraResponse {
  const HouraResponse({
    required this.statusCode,
    required this.uri,
    required this.json,
    required this.body,
  });

  final int statusCode;
  final Uri uri;
  final Object? json;
  final String body;

  Map<String, Object?> get jsonObject {
    final value = json;
    if (value is Map<String, Object?>) {
      return value;
    }
    throw HouraResponseFormatException('Expected JSON object from $uri.');
  }
}

final class HouraTransport {
  HouraTransport({
    required Uri serverBaseUri,
    http.Client? httpClient,
    Duration requestTimeout = const Duration(seconds: 60),
  })  : _serverBaseUri = _normalizeServerBaseUri(serverBaseUri),
        _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null,
        _requestTimeout = requestTimeout;

  final Uri _serverBaseUri;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  final Duration _requestTimeout;

  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  Future<Map<String, Object?>> getJsonObject(List<String> pathSegments) async {
    final response = await send(
      HouraRequest(method: 'GET', pathSegments: pathSegments),
    );
    return response.jsonObject;
  }

  Future<HouraResponse> send(HouraRequest request) async {
    final uri = _buildUri(request);
    final http.Response response;
    try {
      response = await _sendOnce(uri, request).timeout(_requestTimeout);
    } on HouraTransportException {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw HouraTransportException(
        'Request failed before response.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _tryDecodeResponseJson(response.body);
      final errorFields = _errorFields(decoded);
      throw HouraHttpException(
        statusCode: response.statusCode,
        uri: uri,
        responseBody: response.body,
        code: errorFields.code,
        serverMessage: errorFields.message,
      );
    }

    final decoded = _decodeResponseJson(response.body, uri);
    return HouraResponse(
      statusCode: response.statusCode,
      uri: uri,
      json: decoded,
      body: response.body,
    );
  }

  Future<http.Response> _sendOnce(Uri uri, HouraRequest request) {
    final body = request.body;
    final headers = _headersFor(request);
    return switch (request.method) {
      'GET' => _httpClient.get(uri, headers: headers),
      'POST' => _httpClient.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      'PUT' => _httpClient.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      'DELETE' => _httpClient.delete(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      _ => throw HouraTransportException(
          'Unsupported HTTP method: ${request.method}.',
        ),
    };
  }

  Map<String, String> _headersFor(HouraRequest request) {
    final headers = <String, String>{...request.headers};
    final accessToken = request.accessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    if (request.body != null) {
      headers['Content-Type'] = headers['Content-Type'] ?? 'application/json';
    }
    return headers;
  }

  Object? _decodeResponseJson(String body, Uri uri) {
    if (body.trim().isEmpty) {
      return null;
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (error) {
      throw HouraResponseFormatException(
        'Response body from $uri was not valid JSON: $error',
      );
    }
    return decoded;
  }

  Object? _tryDecodeResponseJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  Uri _buildUri(HouraRequest request) {
    final baseSegments = _serverBaseUri.pathSegments.where(
      (segment) => segment.isNotEmpty,
    );
    return Uri(
      scheme: _serverBaseUri.scheme,
      host: _serverBaseUri.host,
      port: _serverBaseUri.hasPort ? _serverBaseUri.port : null,
      pathSegments: [...baseSegments, ...request.pathSegments],
      queryParameters:
          request.queryParameters.isEmpty ? null : request.queryParameters,
    );
  }
}

Map<String, String> _validateQueryParameters(
  Map<String, String> queryParameters,
) {
  if (queryParameters.containsKey('access_token')) {
    throw HouraTransportException(
      'Use Authorization Bearer instead of access_token query parameters.',
    );
  }
  return Map.unmodifiable(queryParameters);
}

({String? code, String? message}) _errorFields(Object? decoded) {
  if (decoded is! Map<String, Object?>) {
    return (code: null, message: null);
  }
  return (
    code: _optionalNonEmptyString(decoded['code']) ??
        _optionalNonEmptyString(decoded['errcode']),
    message: _optionalNonEmptyString(decoded['message']) ??
        _optionalNonEmptyString(decoded['error']),
  );
}

String? _optionalNonEmptyString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return null;
}

String? _validateAccessToken(String? accessToken) {
  if (accessToken != null && accessToken.trim().isEmpty) {
    throw HouraTransportException('accessToken must be non-empty.');
  }
  return accessToken;
}

Object _validateJsonBody(Object body) {
  if (body is Map<String, Object?> ||
      body is List<Object?> ||
      body is String ||
      body is num ||
      body is bool) {
    return body;
  }
  throw HouraTransportException('Request body must be JSON encodable.');
}

Uri _normalizeServerBaseUri(Uri uri) {
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    throw HouraTransportException('Server base URI must use http or https.');
  }
  if (uri.host.isEmpty) {
    throw HouraTransportException('Server base URI must include a host.');
  }
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    pathSegments: uri.pathSegments.where((segment) => segment.isNotEmpty),
  );
}
