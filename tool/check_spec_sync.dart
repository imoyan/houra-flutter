import 'dart:io';

void main() {
  final failures = <String>[];
  checkSdkBoundary(failures);
  checkCanonicalSpecRoot(failures);
  checkDesignSync(failures);
  checkVectorReferences(failures);
  checkDocReferences(failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Spec sync check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
  }
}

void checkSdkBoundary(List<String> failures) {
  const allowedTopLevel = {
    '.github',
    '.gitignore',
    'AGENTS.md',
    'LICENSE',
    'README.md',
    'design',
    'example',
    'lib',
    'pubspec.yaml',
    'test',
    'tool',
  };
  const allowedToolFiles = {'check_spec_sync.dart'};
  const canonicalOnlyEntries = {
    'contracts',
    'test-vectors',
    'SOURCE_OF_TRUTH.md',
    'REFERENCE_POLICY.md',
    'FEATURE_PROFILES.md',
    'MODULE_DEPENDENCIES.md',
    'CONTRACT_MODULE_MAP.md',
  };

  for (final entity in Directory.current.listSync()) {
    final name = entityName(entity);
    if (isGeneratedEntry(name)) {
      continue;
    }
    if (!allowedTopLevel.contains(name)) {
      failures.add('Unexpected top-level entry in SDK root: $name');
    }
    if (canonicalOnlyEntries.contains(name)) {
      failures.add('Canonical spec entry must not be copied into SDK root: '
          '$name');
    }
  }

  final toolRoot = Directory('tool');
  if (!toolRoot.existsSync()) {
    failures.add('Missing tool directory.');
    return;
  }
  for (final entity in toolRoot.listSync()) {
    final name = entityName(entity);
    if (entity is! File || !allowedToolFiles.contains(name)) {
      failures.add(
          'Unexpected SDK tool entry: ${relativePath(entity, Directory.current)}');
    }
  }
}

void checkCanonicalSpecRoot(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  if (!specRoot.existsSync()) {
    failures.add('Missing sibling spec root: ${specRoot.path}');
    return;
  }

  final script = File('${specRoot.path}/tool/check_spec.dart');
  if (!script.existsSync()) {
    failures.add('Missing canonical spec check: ${script.path}');
    return;
  }

  final result = Process.runSync(
    'dart',
    ['tool/check_spec.dart'],
    workingDirectory: specRoot.path,
  );
  if (result.exitCode != 0) {
    failures.add('Canonical spec check failed: dart tool/check_spec.dart');
    addCommandOutput('stdout', result.stdout, failures);
    addCommandOutput('stderr', result.stderr, failures);
  }
}

void checkDesignSync(List<String> failures) {
  final localRoot = Directory('design');
  final specRoot = canonicalSpecRoot();
  final canonicalRoot = Directory('${specRoot.path}/design');

  if (!localRoot.existsSync()) {
    failures.add('Missing local design directory: ${localRoot.path}');
    return;
  }
  if (!canonicalRoot.existsSync()) {
    failures.add('Missing canonical design directory: ${canonicalRoot.path}');
    return;
  }

  final localFiles = filesByRelativePath(localRoot);
  final canonicalFiles = filesByRelativePath(canonicalRoot);
  for (final relativePath in canonicalFiles.keys) {
    final local = localFiles[relativePath];
    final canonical = canonicalFiles[relativePath]!;
    if (local == null) {
      failures.add('Missing bundled design file: design/$relativePath');
      continue;
    }
    if (local.readAsStringSync() != canonical.readAsStringSync()) {
      failures.add(
        'design/$relativePath differs from '
        '${specRoot.path}/design/$relativePath',
      );
    }
  }
  for (final relativePath in localFiles.keys) {
    if (!canonicalFiles.containsKey(relativePath)) {
      failures.add('Bundled design file has no canonical source: '
          'design/$relativePath');
    }
  }
}

void checkVectorReferences(List<String> failures) {
  final testRoot = Directory('test');
  if (!testRoot.existsSync()) {
    failures.add('Missing test directory.');
    return;
  }

  final readVectorPattern = RegExp(r'''readVector\(\s*['"]([^'"]+)['"]\s*\)''');
  final directSpecVectorPattern = RegExp(
    r'''(?:\.\./)?chawan-product-spec/test-vectors/[^'"\s)]+''',
  );
  for (final file in dartFilesUnder(testRoot)) {
    final source = file.readAsStringSync();
    final relativeTestPath = relativePath(file, Directory.current);
    for (final match in readVectorPattern.allMatches(source)) {
      final vectorPath = match.group(1)!;
      final specRoot = canonicalSpecRoot();
      final canonical = File('${specRoot.path}/$vectorPath');
      if (!canonical.existsSync()) {
        failures.add('$relativeTestPath references missing vector: '
            '${specRoot.path}/$vectorPath');
      }
    }

    if (file.path.endsWith('vector_test_support.dart')) {
      continue;
    }
    for (final match in directSpecVectorPattern.allMatches(source)) {
      failures.add('$relativeTestPath should use readVector(...) for '
          'canonical vector reference: ${match.group(0)}');
    }
  }
}

void checkDocReferences(List<String> failures) {
  final specRoot = canonicalSpecRoot();
  if (!specRoot.existsSync()) {
    failures.add('Missing sibling spec root: ${specRoot.path}');
    return;
  }

  final contractIds = <String>{};
  final contractRoot = Directory('${specRoot.path}/contracts');
  if (!contractRoot.existsSync()) {
    failures.add('Missing canonical contract directory: ${contractRoot.path}');
    return;
  }
  for (final file in contractRoot.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    final match = RegExp(r'^(SPEC-\d{3})-.*\.md$').firstMatch(name);
    if (match != null) {
      contractIds.add(match.group(1)!);
    }
  }

  final docFiles = [
    File('README.md'),
    File('AGENTS.md'),
  ];
  final specReferencePattern = RegExp(r'\bSPEC-\d{3}\b');
  final relativeSpecPathPattern = RegExp(
    r'''`?(\.\./chawan-product-spec(?:/[A-Za-z0-9._/\-]+)?)`?''',
  );

  for (final doc in docFiles) {
    if (!doc.existsSync()) {
      failures.add('Missing documentation file: ${doc.path}');
      continue;
    }
    final source = doc.readAsStringSync();
    for (final match in specReferencePattern.allMatches(source)) {
      final specId = match.group(0)!;
      if (!contractIds.contains(specId)) {
        failures.add('${doc.path} references missing contract: $specId');
      }
    }
    for (final match in relativeSpecPathPattern.allMatches(source)) {
      final path = match.group(1)!;
      if (!File(path).existsSync() && !Directory(path).existsSync()) {
        failures.add('${doc.path} references missing spec path: $path');
      }
    }
  }
}

Directory canonicalSpecRoot() {
  final fromEnv = Platform.environment['CHAWAN_SPEC_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory('../chawan-product-spec');
}

Map<String, File> filesByRelativePath(Directory root) {
  final files = <String, File>{};
  for (final file in root.listSync(recursive: true).whereType<File>()) {
    files[relativePath(file, root)] = file;
  }
  return files;
}

Iterable<File> dartFilesUnder(Directory root) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String relativePath(FileSystemEntity entity, Directory root) {
  final rootPath = root.absolute.uri.path.endsWith('/')
      ? root.absolute.uri.path
      : '${root.absolute.uri.path}/';
  final entityPath = entity.absolute.uri.path;
  if (!entityPath.startsWith(rootPath)) {
    return Uri.decodeComponent(entityPath);
  }
  return Uri.decodeComponent(entityPath.substring(rootPath.length));
}

void addCommandOutput(String label, Object? output, List<String> failures) {
  final text = output?.toString().trim();
  if (text == null || text.isEmpty) {
    return;
  }
  failures.add('$label: ${text.split('\n').take(6).join(' | ')}');
}

String entityName(FileSystemEntity entity) {
  final segments =
      entity.uri.pathSegments.where((segment) => segment.isNotEmpty);
  if (segments.isEmpty) {
    return entity.path;
  }
  return segments.last;
}

bool isGeneratedEntry(String name) {
  return name == '.git' ||
      name == '.dart_tool' ||
      name == 'build' ||
      name == 'pubspec.lock';
}
