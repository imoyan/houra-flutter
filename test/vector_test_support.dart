import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final class ContractVector {
  const ContractVector(this.raw);

  final Map<String, Object?> raw;

  Map<String, Object?> get request => optionalObject('request');

  Map<String, Object?> get expected => optionalObject('expected');

  Map<String, Object?> get bodyContains =>
      objectFrom(expected, 'body_contains');

  Map<String, Object?> optionalObject(String key) {
    final value = raw[key];
    if (value == null) {
      return const <String, Object?>{};
    }
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    fail('$key must be a JSON object.');
  }
}

ContractVector readVector(String path) {
  final root = requireCanonicalSpecRoot();
  return ContractVector(readJsonObject('${root.path}/$path'));
}

Map<String, Object?> readJsonObject(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is Map) {
    return decoded.cast<String, Object?>();
  }
  fail('$path must contain a JSON object.');
}

Directory canonicalSpecRoot({
  Map<String, String>? environment,
  String defaultPath = '../houra-spec',
}) {
  final fromEnv = (environment ?? Platform.environment)['HOURA_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory(defaultPath);
}

Directory requireCanonicalSpecRoot({
  Map<String, String>? environment,
  String defaultPath = '../houra-spec',
}) {
  final root = canonicalSpecRoot(
    environment: environment,
    defaultPath: defaultPath,
  );
  if (!root.existsSync()) {
    fail(
      'Canonical houra-spec checkout not found at ${root.path}. '
      'Set HOURA_SPEC_ROOT to the canonical houra-spec checkout before '
      'running spec-dependent tests.',
    );
  }
  if (!Directory('${root.path}/test-vectors').existsSync()) {
    fail(
      'Canonical houra-spec checkout at ${root.path} is missing '
      'test-vectors/. Set HOURA_SPEC_ROOT to the canonical houra-spec '
      'checkout before running spec-dependent tests.',
    );
  }
  return root;
}

Map<String, Object?> objectFrom(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  fail('$key must be a JSON object.');
}
