import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/application/auth_usecases.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late _MockKvStorage storage;
  late _MockLoginUseCase loginUseCase;
  late _MockLogoutUseCase logoutUseCase;

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    storage = _MockKvStorage();
    loginUseCase = _MockLoginUseCase();
    logoutUseCase = _MockLogoutUseCase();

    when(storage.getThemeMode).thenReturn(ThemeMode.system);
    when(storage.getThemeSeedColor).thenReturn(const Color(0xFF1D4ED8));
    when(storage.getLocale).thenReturn(null);
    when(storage.isOnboardingDone).thenReturn(true);
    when(storage.getAccessToken).thenReturn(null);
    when(storage.getUserMap).thenReturn(null);
    when(
      () => loginUseCase(username: 'admin', password: 'admin'),
    ).thenAnswer(
      (_) async => const Result.success(
        User(id: '1', name: 'Admin', email: 'admin@example.com'),
      ),
    );
    when(() => logoutUseCase()).thenAnswer((_) async {});
  });

  testWidgets('logout lands on login as a root page without back navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(AppFlavor.dev)),
          kvStorageProvider.overrideWithValue(storage),
          loginUseCaseProvider.overrideWithValue(loginUseCase),
          logoutUseCaseProvider.overrideWithValue(logoutUseCase),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Logout'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Logout'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('auth state change on login route navigates to home', (
    tester,
  ) async {
    late WidgetRef capturedRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(AppFlavor.dev)),
          kvStorageProvider.overrideWithValue(storage),
          loginUseCaseProvider.overrideWithValue(loginUseCase),
          logoutUseCaseProvider.overrideWithValue(logoutUseCase),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const App();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    capturedRef
        .read(authProvider.notifier)
        .setAuthenticated(isAuthenticated: true);
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);
  });
}
