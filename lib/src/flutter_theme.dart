import 'package:flutter/material.dart';

import 'theme_tokens.dart';

/// Flutter adapter for platform-neutral Okaka theme tokens.
final class OkakaFlutterTheme {
  const OkakaFlutterTheme._();

  static ThemeData themeData(OkakaResolvedTheme theme) {
    final brightness = switch (theme.variant) {
      OkakaThemeVariant.light => Brightness.light,
      OkakaThemeVariant.dark => Brightness.dark,
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

  static TextTheme _textTheme(
    OkakaResolvedTheme theme,
    Brightness brightness,
  ) {
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

Color _color(String hex) {
  final value = hex.substring(1);
  final argb = value.length == 6 ? 'FF$value' : value;
  return Color(int.parse(argb, radix: 16));
}
