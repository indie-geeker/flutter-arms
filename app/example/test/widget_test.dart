import 'package:example/l10n/app_localizations.dart';
import 'package:example/src/domain/entities/user_entity.dart';
import 'package:example/src/presentation/screens/home_screen.dart';
import 'package:example/src/presentation/screens/login_screen.dart';
import 'package:example/src/presentation/state/login_state.dart';
import 'package:example/src/presentation/widgets/custom_button.dart';
import 'package:example/src/presentation/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('CustomButton invokes callback when enabled', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _testApp(
        CustomButton(
          text: 'Sign In',
          isFullWidth: false,
          onPressed: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('LoadingOverlay shows and hides loading message', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const LoadingOverlay(
          isLoading: true,
          message: 'Loading profile...',
          child: Text('Base Content'),
        ),
      ),
    );

    expect(find.text('Base Content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading profile...'), findsOneWidget);

    await tester.pumpWidget(
      _testApp(
        const LoadingOverlay(
          isLoading: false,
          message: 'Loading profile...',
          child: Text('Base Content'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Loading profile...'), findsNothing);
  });

  testWidgets('LoginFormContent enables login only when form is valid', (
    tester,
  ) async {
    final usernameController = TextEditingController(text: '');
    final passwordController = TextEditingController(text: '');

    await tester.pumpWidget(
      _testApp(
        LoginFormContent(
          usernameController: usernameController,
          passwordController: passwordController,
          formState: const LoginFormState(username: '', password: ''),
          isLoading: false,
          onUsernameChanged: (_) {},
          onPasswordChanged: (_) {},
          onTogglePasswordVisibility: () {},
          onLogin: () {},
        ),
      ),
    );

    final disabledButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(disabledButton.onPressed, isNull);

    await tester.pumpWidget(
      _testApp(
        LoginFormContent(
          usernameController: usernameController,
          passwordController: passwordController,
          formState: const LoginFormState(
            username: 'alice',
            password: 'secret',
          ),
          isLoading: false,
          onUsernameChanged: (_) {},
          onPasswordChanged: (_) {},
          onTogglePasswordVisibility: () {},
          onLogin: () {},
        ),
      ),
    );
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('UserInfoCard shows username and triggers logout', (
    tester,
  ) async {
    var logoutCalled = false;
    final user = UserEntity(
      id: '1',
      username: 'alice',
      loginTime: DateTime(2026, 1, 1, 9, 30),
    );

    await tester.pumpWidget(
      _testApp(
        UserInfoCard(
          username: user.username,
          loginTime: user.loginTime,
          onLogout: () => logoutCalled = true,
        ),
      ),
    );

    expect(find.text('alice'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();

    expect(logoutCalled, isTrue);
  });
}
