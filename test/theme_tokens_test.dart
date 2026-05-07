import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houra/houra.dart';

void main() {
  test('smoke theme resolves shared light and dark tokens', () {
    final tokens = HouraThemeTokens.fromJsonString(
      File('design/themes/smoke.json').readAsStringSync(),
    );

    final light = tokens.resolve(HouraThemeVariant.light);
    final dark = tokens.resolve(HouraThemeVariant.dark);

    expect(tokens.name, 'smoke');
    expect(light.colorHex('background'), '#F7FAFC');
    expect(dark.colorHex('background'), '#182026');
    expect(light.colorHex('primary'), '#3D7C9F');
    expect(dark.colorHex('text'), '#F7FAFC');
  });

  test('theme parser rejects unknown references and cycles', () {
    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'broken',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          'primary': {'light': 'missing', 'dark': '#000000'},
        },
      }),
      throwsA(isA<HouraThemeFormatException>()),
    );

    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'cycle',
        'version': '0.1.0',
        'defs': {'a': 'b', 'b': 'a'},
        'theme': {
          'primary': {'light': 'a', 'dark': '#000000'},
        },
      }),
      throwsA(isA<HouraThemeFormatException>()),
    );
  });

  test('Flutter adapter maps resolved tokens to ThemeData', () {
    final tokens = HouraThemeTokens.fromJsonString(
      File('design/themes/smoke.json').readAsStringSync(),
    );
    final theme = HouraFlutterTheme.themeData(
      tokens.resolve(HouraThemeVariant.dark),
    );

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFF3D7C9F));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF182026));
    expect(theme.cardColor, const Color(0xFF2F3B45));
  });
}
