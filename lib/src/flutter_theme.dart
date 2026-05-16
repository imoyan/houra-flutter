import 'package:flutter/material.dart';

import 'errors.dart';
import 'theme_tokens.dart';

const _materialThemeColorTokens = {
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
};

/// Flutter adapter for platform-neutral Houra theme tokens.
final class HouraFlutterTheme {
  const HouraFlutterTheme._();

  static ThemeData themeData(HouraResolvedTheme theme) {
    _requireMaterialThemeTokens(theme);
    final brightness = switch (theme.variant) {
      HouraThemeVariant.light => Brightness.light,
      HouraThemeVariant.dark => Brightness.dark,
    };
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _color(theme.colorHex('primary')),
      brightness: brightness,
    ).copyWith(
      primary: _color(theme.colorHex('primary')),
      secondary: _color(theme.colorHex('secondary')),
      tertiary: _color(theme.colorHex('accent')),
      error: _color(theme.colorHex('error')),
      surface: _color(theme.colorHex('surface')),
      onSurface: _color(theme.colorHex('text')),
      outline: _color(theme.colorHex('border')),
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _color(theme.colorHex('background')),
      cardColor: _color(theme.colorHex('surfaceRaised')),
      dividerColor: _color(theme.colorHex('border')),
      focusColor: _color(theme.colorHex('focus')),
      shadowColor: _color(theme.colorHex('shadow')),
      textTheme: _textTheme(theme, brightness),
      useMaterial3: true,
    );
  }

  static TextTheme _textTheme(HouraResolvedTheme theme, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return base.apply(
      bodyColor: _color(theme.colorHex('text')),
      displayColor: _color(theme.colorHex('text')),
      decorationColor: _color(theme.colorHex('textMuted')),
    );
  }
}

void _requireMaterialThemeTokens(HouraResolvedTheme theme) {
  final missing = _materialThemeColorTokens
      .where((token) => !theme.colors.containsKey(token))
      .toList(growable: false);
  if (missing.isEmpty) {
    return;
  }
  throw HouraThemeFormatException(
    'Resolved theme is missing required Flutter color tokens: '
    '${missing.join(', ')}.',
  );
}

Color _color(String hex) {
  final value = hex.substring(1);
  final argb = value.length == 6 ? 'FF$value' : value;
  return Color(int.parse(argb, radix: 16));
}
