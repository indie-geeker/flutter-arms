import 'package:example/src/core/theme/app_color_scheme.dart';
import 'package:example/src/core/theme/app_theme_factory.dart';
import 'package:example/src/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppThemeFactory', () {
    test('builds light theme with expected brightness and tokens', () {
      final theme = AppThemeFactory.light(AppColorScheme.green);

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);

      final tokens = theme.extension<AppThemeTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.success, isNot(equals(tokens.warning)));
    });

    test('builds dark theme with expected brightness and tokens', () {
      final theme = AppThemeFactory.dark(AppColorScheme.orange);

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);

      final tokens = theme.extension<AppThemeTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.overlay, isNot(equals(Colors.transparent)));
    });
  });
}
