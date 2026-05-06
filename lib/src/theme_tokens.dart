import 'dart:convert';

import 'errors.dart';

/// Light or dark variant for a shared theme token file.
enum OkakaThemeVariant { light, dark }

/// Platform-neutral shared theme token set.
final class OkakaThemeTokens {
  OkakaThemeTokens({
    required this.name,
    required this.version,
    required Map<String, String> defs,
    required Map<String, OkakaThemeColorToken> theme,
  })  : defs = Map.unmodifiable(defs),
        theme = Map.unmodifiable(theme);

  final String name;
  final String version;
  final Map<String, String> defs;
  final Map<String, OkakaThemeColorToken> theme;

  factory OkakaThemeTokens.fromJsonString(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw OkakaThemeFormatException('Theme JSON is invalid: $error');
    }
    if (decoded is! Map<String, Object?>) {
      throw const OkakaThemeFormatException('Theme root must be an object.');
    }
    return OkakaThemeTokens.fromJson(decoded);
  }

  factory OkakaThemeTokens.fromJson(Map<String, Object?> json) {
    final defs = _readStringMap(json, 'defs');
    final rawTheme = json['theme'];
    if (rawTheme is! Map<String, Object?> || rawTheme.isEmpty) {
      throw const OkakaThemeFormatException(
        'Theme field "theme" must be a non-empty object.',
      );
    }

    final theme = <String, OkakaThemeColorToken>{};
    for (final entry in rawTheme.entries) {
      final value = entry.value;
      if (value is! Map<String, Object?>) {
        throw OkakaThemeFormatException(
          'Theme token "${entry.key}" must be an object.',
        );
      }
      theme[entry.key] = OkakaThemeColorToken(
        light: _readRequiredString(value, 'light'),
        dark: _readRequiredString(value, 'dark'),
      );
    }

    final tokens = OkakaThemeTokens(
      name: _readRequiredString(json, 'name'),
      version: _readRequiredString(json, 'version'),
      defs: defs,
      theme: theme,
    );
    tokens.resolve(OkakaThemeVariant.light);
    tokens.resolve(OkakaThemeVariant.dark);
    return tokens;
  }

  /// Resolves references in [defs] into concrete hex colors.
  OkakaResolvedTheme resolve(OkakaThemeVariant variant) {
    final colors = <String, String>{};
    for (final entry in theme.entries) {
      final raw = switch (variant) {
        OkakaThemeVariant.light => entry.value.light,
        OkakaThemeVariant.dark => entry.value.dark,
      };
      colors[entry.key] = _resolveColor(raw, <String>{});
    }
    return OkakaResolvedTheme(
      name: name,
      version: version,
      variant: variant,
      colors: colors,
    );
  }

  String _resolveColor(String value, Set<String> stack) {
    final normalized = value.trim();
    if (_isHexColor(normalized)) {
      return normalized.toUpperCase();
    }
    final referenced = defs[normalized];
    if (referenced == null) {
      throw OkakaThemeFormatException(
        'Unknown theme color reference "$normalized".',
      );
    }
    if (!stack.add(normalized)) {
      throw OkakaThemeFormatException(
        'Cyclic theme color reference "$normalized".',
      );
    }
    return _resolveColor(referenced, stack);
  }
}

/// Light/dark pair for one platform-neutral color token.
final class OkakaThemeColorToken {
  const OkakaThemeColorToken({required this.light, required this.dark});

  final String light;
  final String dark;
}

/// Concrete theme values after reference resolution.
final class OkakaResolvedTheme {
  OkakaResolvedTheme({
    required this.name,
    required this.version,
    required this.variant,
    required Map<String, String> colors,
  }) : colors = Map.unmodifiable(colors);

  final String name;
  final String version;
  final OkakaThemeVariant variant;
  final Map<String, String> colors;

  String colorHex(String token) {
    final color = colors[token];
    if (color == null) {
      throw OkakaThemeFormatException('Unknown resolved color token "$token".');
    }
    return color;
  }
}

Map<String, String> _readStringMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map<String, Object?>) {
    throw OkakaThemeFormatException('Theme field "$key" must be an object.');
  }
  final result = <String, String>{};
  for (final entry in value.entries) {
    final item = entry.value;
    if (item is! String || item.trim().isEmpty) {
      throw OkakaThemeFormatException(
        'Theme definition "${entry.key}" must be a non-empty string.',
      );
    }
    result[entry.key] = item;
  }
  return result;
}

String _readRequiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw OkakaThemeFormatException(
    'Theme field "$key" must be a non-empty string.',
  );
}

bool _isHexColor(String value) {
  return RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(value);
}
