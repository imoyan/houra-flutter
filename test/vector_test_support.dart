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
  return ContractVector(readJsonObject('${_specRoot().path}/$path'));
}

Map<String, Object?> readJsonObject(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is Map) {
    return decoded.cast<String, Object?>();
  }
  fail('$path must contain a JSON object.');
}

Directory _specRoot() {
  final fromEnv = Platform.environment['CHAWAN_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory('../chawan-product-spec');
}

Map<String, Object?> objectFrom(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  fail('$key must be a JSON object.');
}
