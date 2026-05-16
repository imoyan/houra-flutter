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
        116,
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
          if (_containsForbiddenTerm(lowerContents, term) &&
              !_isAllowedForbiddenTerm(entity, term, lowerContents)) {
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
      path.contains('/dist/') ||
      path.contains('/.git/') ||
      path.contains('/node_modules/') ||
      path.contains('/target/') ||
      path.endsWith('/.git') ||
      path.endsWith('/pubspec.lock') ||
      path.endsWith('/test/oss_hygiene_test.dart');
}

bool _isAllowedForbiddenTerm(File file, String term, String lowerContents) {
  final path = file.uri.path;
  final consumer = _word([99, 111, 110, 115, 117, 109, 101, 114]);
  if (term != consumer) {
    return false;
  }
  return (path.endsWith('/design/ui.surface.schema.json') ||
          path.endsWith('/design/ui-surfaces/product-mvp.json')) &&
      lowerContents.contains('consumer_repos');
}

bool _containsForbiddenTerm(String lowerContents, String term) {
  final legacyAtoToken = _word([65, 84, 79]);
  final lowerTerm = term.toLowerCase();
  if (term != legacyAtoToken) {
    return lowerContents.contains(lowerTerm);
  }
  return _containsAsciiToken(lowerContents, lowerTerm);
}

bool _containsAsciiToken(String contents, String token) {
  var searchOffset = 0;
  while (searchOffset < contents.length) {
    final index = contents.indexOf(token, searchOffset);
    if (index == -1) {
      return false;
    }
    final before =
        index == 0 || !_isAsciiAlphaNumeric(contents.codeUnitAt(index - 1));
    final afterIndex = index + token.length;
    final after = afterIndex == contents.length ||
        !_isAsciiAlphaNumeric(contents.codeUnitAt(afterIndex));
    if (before && after) {
      return true;
    }
    searchOffset = index + token.length;
  }
  return false;
}

bool _isAsciiAlphaNumeric(int codeUnit) {
  return (codeUnit >= 97 && codeUnit <= 122) ||
      (codeUnit >= 48 && codeUnit <= 57);
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
