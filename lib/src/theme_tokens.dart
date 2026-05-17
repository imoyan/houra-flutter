import 'dart:convert';

import 'errors.dart';

/// Light or dark variant for a shared theme token file.
enum HouraThemeVariant { light, dark }

/// Platform-neutral shared theme token set.
final class HouraThemeTokens {
  HouraThemeTokens({
    required this.name,
    required this.version,
    required Map<String, String> defs,
    required Map<String, HouraThemeColorToken> theme,
  })  : defs = Map.unmodifiable(defs),
        theme = Map.unmodifiable(theme);

  final String name;
  final String version;
  final Map<String, String> defs;
  final Map<String, HouraThemeColorToken> theme;

  factory HouraThemeTokens.fromJsonString(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw HouraThemeFormatException('Theme JSON is invalid: $error');
    }
    if (decoded is! Map<String, Object?>) {
      throw const HouraThemeFormatException('Theme root must be an object.');
    }
    return HouraThemeTokens.fromJson(decoded);
  }

  factory HouraThemeTokens.fromJson(Map<String, Object?> json) {
    _rejectUnexpectedKeys(
      json,
      const {'\$schema', 'name', 'version', 'defs', 'theme'},
      'Theme root',
    );
    final defs = _readStringMap(json, 'defs');
    final rawTheme = json['theme'];
    if (rawTheme is! Map<String, Object?> || rawTheme.isEmpty) {
      throw const HouraThemeFormatException(
        'Theme field "theme" must be a non-empty object.',
      );
    }

    final theme = <String, HouraThemeColorToken>{};
    for (final entry in rawTheme.entries) {
      final tokenName = _readTokenName(entry.key, 'Theme token');
      final value = entry.value;
      if (value is! Map<String, Object?>) {
        throw HouraThemeFormatException(
          'Theme token "${entry.key}" must be an object.',
        );
      }
      _rejectUnexpectedKeys(
        value,
        const {'light', 'dark'},
        'Theme token "$tokenName"',
      );
      theme[tokenName] = HouraThemeColorToken(
        light: _readRequiredString(value, 'light'),
        dark: _readRequiredString(value, 'dark'),
      );
    }

    final tokens = HouraThemeTokens(
      name: _readRequiredString(json, 'name'),
      version: _readRequiredString(json, 'version'),
      defs: defs,
      theme: theme,
    );
    tokens.resolve(HouraThemeVariant.light);
    tokens.resolve(HouraThemeVariant.dark);
    return tokens;
  }

  /// Resolves references in [defs] into concrete hex colors.
  HouraResolvedTheme resolve(HouraThemeVariant variant) {
    final colors = <String, String>{};
    for (final entry in theme.entries) {
      final raw = switch (variant) {
        HouraThemeVariant.light => entry.value.light,
        HouraThemeVariant.dark => entry.value.dark,
      };
      colors[entry.key] = _resolveColor(raw, <String>{});
    }
    return HouraResolvedTheme(
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
      throw HouraThemeFormatException(
        'Unknown theme color reference "$normalized".',
      );
    }
    if (!stack.add(normalized)) {
      throw HouraThemeFormatException(
        'Cyclic theme color reference "$normalized".',
      );
    }
    return _resolveColor(referenced, stack);
  }
}

/// Light/dark pair for one platform-neutral color token.
final class HouraThemeColorToken {
  const HouraThemeColorToken({required this.light, required this.dark});

  final String light;
  final String dark;
}

/// Concrete theme values after reference resolution.
final class HouraResolvedTheme {
  HouraResolvedTheme({
    required this.name,
    required this.version,
    required this.variant,
    required Map<String, String> colors,
  }) : colors = Map.unmodifiable(colors);

  final String name;
  final String version;
  final HouraThemeVariant variant;
  final Map<String, String> colors;

  String colorHex(String token) {
    final color = colors[token];
    if (color == null) {
      throw HouraThemeFormatException('Unknown resolved color token "$token".');
    }
    return color;
  }
}

Map<String, String> _readStringMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map<String, Object?>) {
    throw HouraThemeFormatException('Theme field "$key" must be an object.');
  }
  final result = <String, String>{};
  for (final entry in value.entries) {
    final definitionName = _readTokenName(entry.key, 'Theme definition');
    final item = entry.value;
    if (item is! String || item.trim().isEmpty) {
      throw HouraThemeFormatException(
        'Theme definition "${entry.key}" must be a non-empty string.',
      );
    }
    result[definitionName] = item;
  }
  return result;
}

String _readTokenName(String value, String context) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw HouraThemeFormatException('$context name must be non-empty.');
  }
  if (value != normalized) {
    throw HouraThemeFormatException(
      '$context name must not contain leading or trailing whitespace.',
    );
  }
  return normalized;
}

String _readRequiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw HouraThemeFormatException(
    'Theme field "$key" must be a non-empty string.',
  );
}

void _rejectUnexpectedKeys(
  Map<String, Object?> json,
  Set<String> allowedKeys,
  String context,
) {
  String? unexpected;
  for (final key in json.keys) {
    if (!allowedKeys.contains(key)) {
      unexpected = key;
      break;
    }
  }
  if (unexpected != null) {
    throw HouraThemeFormatException(
      '$context contains unsupported field "$unexpected".',
    );
  }
}

bool _isHexColor(String value) {
  return RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(value);
}
