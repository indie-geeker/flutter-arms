import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines the application screen-size adapter configuration', () {
    final configFile = File('lib/app/app_screen_size_config.dart');

    expect(configFile.existsSync(), isTrue);

    final source = configFile.readAsStringSync();
    expect(
      source,
      contains(
        'const appScreenSizeAdapterConfig = ScreenSizeAdapterConfig(',
      ),
    );
    expect(source, contains('designSize: Size(360, 690)'));
    expect(source, contains('scaleAxis: ScaleAxis.width'));
    expect(source, contains('enableDesktopScaling: false'));
  });

  test('bootstrap installs the adapter binding before runApp', () {
    final source = File('lib/app/bootstrap.dart').readAsStringSync();
    final bindingIndex = source.indexOf(
      'ScreenSizeWidgetsFlutterBinding.ensureInitialized(',
    );
    final runAppIndex = source.indexOf('runApp(');

    expect(bindingIndex, greaterThanOrEqualTo(0));
    expect(runAppIndex, greaterThan(bindingIndex));
    expect(
      source,
      isNot(contains('WidgetsFlutterBinding.ensureInitialized();')),
    );
  });

  test('documentation teaches only the current package integrations', () {
    final readme = File('README.md').readAsStringSync();
    final architecture = File('docs/ai/ARCHITECTURE.md').readAsStringSync();

    expect(readme, contains('screen_size_adapter'));
    expect(architecture, contains('ScreenSizeWidgetsFlutterBinding'));
    expect(architecture, contains('SuperOverlayIntegration'));
    expect(architecture, contains('SuperOverlay.dialog'));
    expect(architecture, contains('SuperOverlay.popup'));

    for (final staleApi in <String>[
      ['SuperOverlay', 'Init'].join(),
      ['SuperOverlay', 'showToast'].join('.'),
      ['SuperOverlay', 'showLoading'].join('.'),
      ['Dismiss', 'Status'].join(),
    ]) {
      expect(architecture, isNot(contains(staleApi)));
    }
  });
}
