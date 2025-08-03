/// 存储键常量
/// 
/// 统一管理应用中的存储键名，避免键名冲突
/// 按功能模块进行分类
class StorageKeyConsts {
  // 私有构造函数，防止实例化
  StorageKeyConsts._();
  
  /// 用户相关键名前缀
  static const String userPrefix = 'user_';
  
  /// 设置相关键名前缀
  static const String settingsPrefix = 'settings_';
  
  /// 缓存相关键名前缀
  static const String cachePrefix = 'cache_';

  /// 安全存储相关键名前缀
  static const String securePrefix = 'secure_';
  
  /// 通用配置相关键名前缀
  static const String configPrefix = 'config_';
  
  /// 临时存储相关键名前缀
  static const String tempPrefix = 'temp_';
}

/// 用户相关存储键
class UserKeys {
  // 私有构造函数，防止实例化
  UserKeys._();
  
  /// 用户ID
  static const String userId = '${StorageKeyConsts.userPrefix}id';
  
  /// 用户名
  static const String username = '${StorageKeyConsts.userPrefix}name';
  
  /// 用户头像
  static const String avatar = '${StorageKeyConsts.userPrefix}avatar';
  
  /// 用户邮箱
  static const String email = '${StorageKeyConsts.userPrefix}email';
  
  /// 用户手机号
  static const String phone = '${StorageKeyConsts.userPrefix}phone';
  
  /// 用户登录状态
  static const String isLogin = '${StorageKeyConsts.userPrefix}is_login';
  
  /// 用户登录令牌
  static const String token = '${StorageKeyConsts.userPrefix}token';
  
  /// 用户刷新令牌
  static const String refreshToken = '${StorageKeyConsts.userPrefix}refresh_token';
  
  /// 用户权限列表
  static const String permissions = '${StorageKeyConsts.userPrefix}permissions';
}

/// 设置相关存储键
class SettingsKeys {
  // 私有构造函数，防止实例化
  SettingsKeys._();
  
  /// 应用语言
  static const String language = '${StorageKeyConsts.settingsPrefix}language';
  
  /// 应用主题模式 (light/dark/system)
  static const String themeMode = '${StorageKeyConsts.settingsPrefix}theme_mode';
  
  /// 应用主题颜色
  static const String themeColor = '${StorageKeyConsts.settingsPrefix}theme_color';
  
  /// 字体大小
  static const String fontSize = '${StorageKeyConsts.settingsPrefix}font_size';
  
  /// 是否首次启动应用
  static const String isFirstLaunch = '${StorageKeyConsts.settingsPrefix}is_first_launch';
  
  /// 自动登录
  static const String autoLogin = '${StorageKeyConsts.settingsPrefix}auto_login';
  
  /// 记住密码
  static const String rememberPassword = '${StorageKeyConsts.settingsPrefix}remember_password';
  
  /// 通知设置
  static const String notification = '${StorageKeyConsts.settingsPrefix}notification';
}

/// 缓存相关存储键
class CacheKeys {
  // 私有构造函数，防止实例化
  CacheKeys._();
  
  /// 首页数据缓存
  static const String homeData = '${StorageKeyConsts.cachePrefix}home_data';
  
  /// 列表数据缓存
  static const String listData = '${StorageKeyConsts.cachePrefix}list_data';
  
  /// 用户信息缓存
  static const String userInfo = '${StorageKeyConsts.cachePrefix}user_info';
  
  /// 最后更新时间
  static const String lastUpdateTime = '${StorageKeyConsts.cachePrefix}last_update_time';
}

/// 安全存储相关键
class SecureKeys {
  // 私有构造函数，防止实例化
  SecureKeys._();
  
  /// 用户密码
  static const String password = '${StorageKeyConsts.securePrefix}password';
  
  /// API密钥
  static const String apiKey = '${StorageKeyConsts.securePrefix}api_key';
  
  /// 加密密钥
  static const String encryptionKey = '${StorageKeyConsts.securePrefix}encryption_key';
}

/// 应用配置相关键
class ConfigKeys {
  // 私有构造函数，防止实例化
  ConfigKeys._();
  
  /// API基础URL
  static const String apiBaseUrl = '${StorageKeyConsts.configPrefix}api_base_url';
  
  /// API版本
  static const String apiVersion = '${StorageKeyConsts.configPrefix}api_version';
  
  /// 应用版本
  static const String appVersion = '${StorageKeyConsts.configPrefix}app_version';
  
  /// 设备ID
  static const String deviceId = '${StorageKeyConsts.configPrefix}device_id';
}
