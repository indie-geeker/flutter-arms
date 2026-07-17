import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_overlay/super_overlay.dart';

import '../../helpers/super_overlay_test_app.dart';

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockKvStorage storage;

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    storage = _MockKvStorage();
    when(() => storage.getAccessToken()).thenReturn(null);
    when(() => storage.getRefreshToken()).thenReturn(null);
    when(() => storage.getUserMap()).thenReturn(null);
    when(() => storage.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => storage.getThemeSeedColor()).thenReturn(const Color(0xFF1D4ED8));
    when(() => storage.isOnboardingDone()).thenReturn(true);
    when(() => storage.getLocale()).thenReturn(null);
  });

  testWidgets('app root installs an operational SuperOverlay host', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(AppFlavor.dev)),
          kvStorageProvider.overrideWithValue(storage),
        ],
        child: const App(),
      ),
    );

    AppDialog.showInfo('Overlay ready');
    await tester.pump();

    expect(find.text('Overlay ready'), findsOneWidget);

    await SuperOverlay.close<void>(target: OverlayCloseTarget.allToasts);
    await tester.pumpAndSettle();
  });

  testWidgets('AppDialog shows toast and loading with SuperOverlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SuperOverlayTestApp(
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );

    AppDialog.showInfo('Saved');
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
    await SuperOverlay.close<void>(target: OverlayCloseTarget.allToasts);
    await tester.pumpAndSettle();

    AppDialog.showLoading(msg: 'Working...');
    await tester.pump();

    expect(find.text('Working...'), findsOneWidget);

    AppDialog.hideLoading();
    await tester.pumpAndSettle();

    expect(find.text('Working...'), findsNothing);
  });

  testWidgets('AppDialog shows confirm dialog and returns the result', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SuperOverlayTestApp(
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );

    final resultFuture = AppDialog.showConfirm(
      title: '确认提交订单？',
      message: '这会调用 POST /api/orders 并展示请求反馈。',
      confirmText: '确认',
      cancelText: '取消',
    );
    await tester.pumpAndSettle();

    expect(find.text('确认提交订单？'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isTrue);
    expect(find.text('确认提交订单？'), findsNothing);
  });

  testWidgets('AppDialog custom dialog returns its typed result', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SuperOverlayTestApp(
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );

    AppDialog.showInfo('Keep this toast');
    final resultFuture = AppDialog.showCustom<int>(
      tag: 'typed-result-dialog',
      builder:
          (context, close) => AlertDialog(
            title: const Text('Choose a value'),
            actions: [
              TextButton(
                onPressed: () => close(7),
                child: const Text('Use 7'),
              ),
            ],
          ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use 7'));
    await tester.pumpAndSettle();

    expect(await resultFuture, 7);
    expect(find.text('Choose a value'), findsNothing);
    expect(find.text('Keep this toast'), findsOneWidget);

    await SuperOverlay.close<void>(target: OverlayCloseTarget.allToasts);
    await tester.pumpAndSettle();
  });

  testWidgets('AppDialog custom dialog returns null when cancelled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SuperOverlayTestApp(
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );

    final resultFuture = AppDialog.showCustom<int>(
      tag: 'typed-cancel-dialog',
      builder:
          (context, close) => AlertDialog(
            title: const Text('Choose a value'),
            actions: [
              TextButton(
                onPressed: close,
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNull);
    expect(find.text('Choose a value'), findsNothing);
  });

  testWidgets('AppDialog shows a target-bound popup window', (tester) async {
    late BuildContext targetContext;

    await tester.pumpWidget(
      SuperOverlayTestApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                targetContext = context;
                return TextButton(
                  onPressed: () {
                    AppDialog.showPopup(
                      targetContext: targetContext,
                      tag: 'demo-popup',
                      builder: (_) => const Text('PopupWindow：请求指标'),
                    );
                  },
                  child: const Text('查看请求明细'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('查看请求明细'));
    await tester.pumpAndSettle();

    expect(find.text('PopupWindow：请求指标'), findsOneWidget);

    AppDialog.dismissPopup(tag: 'demo-popup');
    await tester.pumpAndSettle();

    expect(find.text('PopupWindow：请求指标'), findsNothing);
  });
}
