/// 应用常量。
class AppConstants {
  AppConstants._();

  /// 网络超时时间（毫秒）。
  static const int connectTimeoutMs = 15000;

  /// 存储盒子名称。
  static const String keyBoxName = 'app_key_box';
  static const String secureBoxName = 'app_secure_box';
  static const String commonBoxName = 'app_common_box';

  /// 存储键。
  static const String cipherKey = 'cipher_key';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';
  static const String themeModeKey = 'theme_mode';
  static const String themeSeedColorKey = 'theme_seed_color';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String localeKey = 'app_locale';
}
