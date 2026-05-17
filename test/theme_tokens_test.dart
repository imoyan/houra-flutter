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

  test('theme parser rejects schema drift and incomplete color tokens', () {
    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'extra-root',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          'primary': {'light': '#000000', 'dark': '#FFFFFF'},
        },
        'palette': <String, Object?>{},
      }),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('unsupported field "palette"'),
        ),
      ),
    );

    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'extra-token-field',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          'primary': {
            'light': '#000000',
            'dark': '#FFFFFF',
            'flutter': '#FFFFFF',
          },
        },
      }),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('unsupported field "flutter"'),
        ),
      ),
    );

    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'missing-dark',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          'primary': {'light': '#000000'},
        },
      }),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('Theme field "dark" must be a non-empty string'),
        ),
      ),
    );

    expect(
      () => HouraThemeTokens.fromJson({
        'name': 'empty-token',
        'version': '0.1.0',
        'defs': <String, Object?>{},
        'theme': {
          ' ': {'light': '#000000', 'dark': '#FFFFFF'},
        },
      }),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('Theme token name must be non-empty'),
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

  test('Flutter adapter declares and requires mapped color tokens', () {
    final tokens = HouraThemeTokens.fromJsonString(
      File('design/themes/smoke.json').readAsStringSync(),
    );
    final light = tokens.resolve(HouraThemeVariant.light);

    expect(
      HouraFlutterTheme.requiredColorTokens,
      orderedEquals([
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
      ]),
    );
    expect(
      light.colors.keys,
      containsAll(HouraFlutterTheme.requiredColorTokens),
    );

    final missingSurfaceRaised = Map<String, String>.from(light.colors)
      ..remove('surfaceRaised');
    expect(
      () => HouraFlutterTheme.themeData(
        HouraResolvedTheme(
          name: light.name,
          version: light.version,
          variant: light.variant,
          colors: missingSurfaceRaised,
        ),
      ),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('surfaceRaised'),
        ),
      ),
    );
  });

  test('Flutter adapter rejects invalid resolved color values', () {
    final colors = {
      for (final token in HouraFlutterTheme.requiredColorTokens)
        token: '#000000',
    };
    colors['primary'] = 'blue';

    expect(
      () => HouraFlutterTheme.themeData(
        HouraResolvedTheme(
          name: 'invalid',
          version: '0.1.0',
          variant: HouraThemeVariant.light,
          colors: colors,
        ),
      ),
      throwsA(
        isA<HouraThemeFormatException>().having(
          (error) => error.message,
          'message',
          contains('primary'),
        ),
      ),
    );
  });
}
