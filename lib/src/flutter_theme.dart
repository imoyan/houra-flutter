import 'package:flutter/material.dart';

import 'errors.dart';
import 'theme_tokens.dart';

/// Flutter adapter for platform-neutral Houra theme tokens.
final class HouraFlutterTheme {
  const HouraFlutterTheme._();

  /// Platform-neutral color tokens consumed by the Flutter adapter.
  static const requiredColorTokens = <String>[
    'primary',
    'secondary',
    'accent',
    'error',
    'surface',
    'text',
    'border',
    'background',
    'surfaceRaised',
    'focus',
    'shadow',
    'textMuted',
  ];

  static ThemeData themeData(HouraResolvedTheme theme) {
    final colors = _FlutterThemeColors.from(theme);
    final brightness = switch (theme.variant) {
      HouraThemeVariant.light => Brightness.light,
      HouraThemeVariant.dark => Brightness.dark,
    };
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
    ).copyWith(
      primary: colors.primary,
      secondary: colors.secondary,
      tertiary: colors.accent,
      error: colors.error,
      surface: colors.surface,
      onSurface: colors.text,
      outline: colors.border,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surfaceRaised,
      dividerColor: colors.border,
      focusColor: colors.focus,
      shadowColor: colors.shadow,
      textTheme: _textTheme(colors, brightness),
      useMaterial3: true,
    );
  }

  static TextTheme _textTheme(
    _FlutterThemeColors colors,
    Brightness brightness,
  ) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return base.apply(
      bodyColor: colors.text,
      displayColor: colors.text,
      decorationColor: colors.textMuted,
    );
  }
}

final class _FlutterThemeColors {
  _FlutterThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.error,
    required this.surface,
    required this.text,
    required this.border,
    required this.background,
    required this.surfaceRaised,
    required this.focus,
    required this.shadow,
    required this.textMuted,
  });

  factory _FlutterThemeColors.from(HouraResolvedTheme theme) {
    final missing = HouraFlutterTheme.requiredColorTokens
        .where((token) => !theme.colors.containsKey(token))
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw HouraThemeFormatException(
        'Resolved theme is missing Flutter color token(s): '
        '${missing.join(', ')}.',
      );
    }

    return _FlutterThemeColors(
      primary: _color('primary', theme.colorHex('primary')),
      secondary: _color('secondary', theme.colorHex('secondary')),
      accent: _color('accent', theme.colorHex('accent')),
      error: _color('error', theme.colorHex('error')),
      surface: _color('surface', theme.colorHex('surface')),
      text: _color('text', theme.colorHex('text')),
      border: _color('border', theme.colorHex('border')),
      background: _color('background', theme.colorHex('background')),
      surfaceRaised: _color('surfaceRaised', theme.colorHex('surfaceRaised')),
      focus: _color('focus', theme.colorHex('focus')),
      shadow: _color('shadow', theme.colorHex('shadow')),
      textMuted: _color('textMuted', theme.colorHex('textMuted')),
    );
  }

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color error;
  final Color surface;
  final Color text;
  final Color border;
  final Color background;
  final Color surfaceRaised;
  final Color focus;
  final Color shadow;
  final Color textMuted;
}

final _hexColorPattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

Color _color(String token, String hex) {
  if (!_hexColorPattern.hasMatch(hex)) {
    throw HouraThemeFormatException(
      'Flutter theme token "$token" must resolve to #RRGGBB or #AARRGGBB.',
    );
  }
  final value = hex.substring(1);
  final argb = value.length == 6 ? 'FF$value' : value;
  return Color(int.parse(argb, radix: 16));
}
