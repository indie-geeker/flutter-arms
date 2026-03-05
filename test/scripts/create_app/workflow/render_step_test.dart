import 'dart:io';

import 'package:test/test.dart';

import '../../../../scripts/src/create_app/models/create_app_config.dart';
import '../../../../scripts/src/create_app/workflow/render_step.dart';

void main() {
  group('renderSelectedTemplates', () {
    test(
      'generates architecture-aligned scaffold and removes legacy feature paths',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp(
          'create_app_render_test_',
        );

        addTearDown(() async {
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        });

        final config = CreateAppConfig(
          appName: 'demo_app',
          organization: 'com.example.demo_app',
          platforms: const ['android', 'ios'],
          interactive: false,
          overwrite: true,
          creationMode: CreationMode.templateOnly,
          modules: ModuleSelection.defaultBaseline(),
          runPostActions: false,
          autoRegisterWorkspace: false,
          rootDirectory: tempRoot.path,
        );

        final result = await renderSelectedTemplates(config: config);
        expect(result.written, isNotEmpty);

        final appDir = Directory(config.appDirectoryPath);
        expect(appDir.existsSync(), isTrue);

        expect(
          File('${config.appDirectoryPath}/lib/main.dart').existsSync(),
          isTrue,
        );
        expect(
          File('${config.appDirectoryPath}/lib/src/app/app.dart').existsSync(),
          isTrue,
        );
        expect(
          File(
            '${config.appDirectoryPath}/lib/src/bootstrap/module_composition.dart',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '${config.appDirectoryPath}/lib/src/bootstrap/module_profile.dart',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '${config.appDirectoryPath}/lib/src/di/providers.dart',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '${config.appDirectoryPath}/lib/src/router/app_router.dart',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '${config.appDirectoryPath}/lib/src/shared/theme/app_theme_factory.dart',
          ).existsSync(),
          isTrue,
        );

        expect(
          File(
            '${config.appDirectoryPath}/lib/src/features/counter/presentation/screens/counter_screen.dart',
          ).existsSync(),
          isFalse,
        );
      },
    );

    test('does not generate optional module files when disabled', () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'create_app_render_test_',
      );

      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final config = CreateAppConfig(
        appName: 'minimal_app',
        organization: 'com.example.minimal_app',
        platforms: const ['android'],
        interactive: false,
        overwrite: true,
        creationMode: CreationMode.templateOnly,
        modules: const ModuleSelection(
          router: false,
          providers: false,
          l10n: false,
          theme: false,
          feature: false,
          tests: false,
        ),
        runPostActions: false,
        autoRegisterWorkspace: false,
        rootDirectory: tempRoot.path,
      );

      await renderSelectedTemplates(config: config);

      expect(
        File(
          '${config.appDirectoryPath}/lib/src/router/app_router.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '${config.appDirectoryPath}/lib/src/di/providers.dart',
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          '${config.appDirectoryPath}/lib/src/shared/theme/app_theme_factory.dart',
        ).existsSync(),
        isFalse,
      );
    });
  });
}
