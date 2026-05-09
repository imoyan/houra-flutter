import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clean roots do not contain legacy or private wording', () {
    final roots = _cleanRoots();
    final forbidden = [
      _word([65, 84, 79]),
      _word([121, 117, 115, 117, 107, 101]),
      _word([109, 97, 116, 114, 105, 120, 45, 99, 108, 105, 101, 110, 116]),
      _word([
        112,
        97,
        99,
        107,
        97,
        103,
        101,
        115,
        47,
        99,
        108,
        105,
        101,
        110,
        116
      ]),
      _word([97, 112, 112, 115, 47]),
      _word([119, 111, 114, 107, 102, 108, 111, 119]),
      _word([99, 111, 110, 115, 117, 109, 101, 114]),
    ];

    final violations = <String>[];
    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || _isIgnored(entity)) {
          continue;
        }
        final contents = _readText(entity);
        if (contents == null) {
          continue;
        }
        final lowerContents = contents.toLowerCase();
        for (final term in forbidden) {
          if (lowerContents.contains(term.toLowerCase())) {
            violations.add('${entity.path}: $term');
          }
        }
      }
    }

    expect(violations, isEmpty);
  });
}

List<Directory> _cleanRoots() {
  return [Directory.current];
}

bool _isIgnored(File file) {
  final path = file.uri.path;
  return path.contains('/.dart_tool/') ||
      path.contains('/build/') ||
      path.contains('/.git/') ||
      path.contains('/target/') ||
      path.endsWith('/.git') ||
      path.endsWith('/pubspec.lock') ||
      path.endsWith('/test/oss_hygiene_test.dart');
}

String _word(List<int> codes) => String.fromCharCodes(codes);

String? _readText(File file) {
  try {
    return file.readAsStringSync();
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}
