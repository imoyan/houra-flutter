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

  test('theme parser resolves nested references and normalizes hex values', () {
    final tokens = HouraThemeTokens.fromJson({
      'name': 'references',
      'version': '0.1.0',
      'defs': {'ink': '#abcdef', 'foreground': 'ink'},
      'theme': {
        'text': {'light': 'foreground', 'dark': '#123456'},
      },
    });

    expect(tokens.resolve(HouraThemeVariant.light).colorHex('text'), '#ABCDEF');
    expect(tokens.resolve(HouraThemeVariant.dark).colorHex('text'), '#123456');
  });

  test('theme parser rejects unknown references, cycles, and incomplete pairs',
      () {
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

    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'incomplete',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          'primary': {'light': '#FFFFFF'},
        },
      }),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('"dark"'),
        ),
      ),
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

  test('Flutter adapter keeps each mapped token on its Material field', () {
    final tokens = HouraThemeTokens.fromJson(_adapterBoundaryTheme());
    final theme = HouraFlutterTheme.themeData(
      tokens.resolve(HouraThemeVariant.light),
    );

    expect(theme.colorScheme.primary, const Color(0xFF111111));
    expect(theme.colorScheme.secondary, const Color(0xFF222222));
    expect(theme.colorScheme.tertiary, const Color(0xFF333333));
    expect(theme.colorScheme.error, const Color(0xFF444444));
    expect(theme.colorScheme.surface, const Color(0xFF555555));
    expect(theme.colorScheme.onSurface, const Color(0xFF666666));
    expect(theme.colorScheme.outline, const Color(0xFF777777));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF888888));
    expect(theme.cardColor, const Color(0xFF999999));
    expect(theme.dividerColor, const Color(0xFF777777));
    expect(theme.focusColor, const Color(0xFFAAAAAA));
    expect(theme.shadowColor, const Color(0xFFBBBBBB));
    expect(theme.textTheme.bodyMedium?.color, const Color(0xFF666666));
    expect(
        theme.textTheme.bodyMedium?.decorationColor, const Color(0xFFCCCCCC));
  });

  test('Flutter adapter fails closed when required mapped tokens are missing',
      () {
    final tokens = HouraThemeTokens.fromJson({
      'name': 'missing-adapter-token',
      'version': '0.1.0',
      'defs': <String, Object?>{},
      'theme': {
        for (final token in _flutterMappedTokens.where(
          (token) => token != 'textMuted',
        ))
          token: {'light': '#111111', 'dark': '#EEEEEE'},
      },
    });

    expect(
      () =>
          HouraFlutterTheme.themeData(tokens.resolve(HouraThemeVariant.light)),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('textMuted'),
        ),
      ),
    );
  });
}

const _flutterMappedTokens = {
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

Map<String, Object?> _adapterBoundaryTheme() {
  return {
    'name': 'adapter-boundary',
    'version': '0.1.0',
    'defs': <String, Object?>{},
    'theme': {
      'primary': {'light': '#111111', 'dark': '#111111'},
      'secondary': {'light': '#222222', 'dark': '#222222'},
      'accent': {'light': '#333333', 'dark': '#333333'},
      'error': {'light': '#444444', 'dark': '#444444'},
      'surface': {'light': '#555555', 'dark': '#555555'},
      'text': {'light': '#666666', 'dark': '#666666'},
      'border': {'light': '#777777', 'dark': '#777777'},
      'background': {'light': '#888888', 'dark': '#888888'},
      'surfaceRaised': {'light': '#999999', 'dark': '#999999'},
      'focus': {'light': '#AAAAAA', 'dark': '#AAAAAA'},
      'shadow': {'light': '#BBBBBB', 'dark': '#BBBBBB'},
      'textMuted': {'light': '#CCCCCC', 'dark': '#CCCCCC'},
    },
  };
}
