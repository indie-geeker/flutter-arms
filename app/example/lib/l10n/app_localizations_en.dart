// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FlutterArms Example';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get username => 'Username';

  @override
  String get enterYourUsername => 'Enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get home => 'Home';

  @override
  String get welcome => 'Welcome!';

  @override
  String loggedInAt(String time) {
    return 'Logged in at $time';
  }

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get colorScheme => 'Color Scheme';

  @override
  String get blue => 'Blue';

  @override
  String get green => 'Green';

  @override
  String get purple => 'Purple';

  @override
  String get orange => 'Orange';

  @override
  String get teal => 'Teal';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get userNotFound => 'User not found';

  @override
  String storageError(String message) {
    return 'Storage error: $message';
  }

  @override
  String networkError(String message) {
    return 'Network error: $message';
  }

  @override
  String unexpectedError(String message) {
    return 'Unexpected error: $message';
  }

  @override
  String get error => 'Error';

  @override
  String get noUserFound => 'No user found';
}
