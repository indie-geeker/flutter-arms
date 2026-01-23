// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FlutterArms 示例';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get signInToContinue => '请登录以继续';

  @override
  String get username => '用户名';

  @override
  String get enterYourUsername => '请输入用户名';

  @override
  String get password => '密码';

  @override
  String get enterYourPassword => '请输入密码';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get home => '首页';

  @override
  String get welcome => '欢迎！';

  @override
  String loggedInAt(String time) {
    return '登录时间：$time';
  }

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get themeMode => '主题模式';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get systemMode => '跟随系统';

  @override
  String get colorScheme => '配色方案';

  @override
  String get blue => '蓝色';

  @override
  String get green => '绿色';

  @override
  String get purple => '紫色';

  @override
  String get orange => '橙色';

  @override
  String get teal => '青色';

  @override
  String get language => '语言';

  @override
  String get english => '英语';

  @override
  String get chinese => '中文';

  @override
  String get usernameRequired => '用户名不能为空';

  @override
  String get passwordRequired => '密码不能为空';

  @override
  String get invalidCredentials => '用户名或密码错误';

  @override
  String get userNotFound => '用户不存在';

  @override
  String storageError(String message) {
    return '存储错误：$message';
  }

  @override
  String networkError(String message) {
    return '网络错误：$message';
  }

  @override
  String unexpectedError(String message) {
    return '未知错误：$message';
  }

  @override
  String get error => '错误';

  @override
  String get noUserFound => '未找到用户';
}
