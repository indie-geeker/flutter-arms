/// 存储配置模型
/// 
/// 用于配置存储实例的参数
class StorageConfig {
  /// 存储名称
  final String name;
  
  /// 是否启用日志
  final bool enableLog;
  
  /// 加密密钥（如果需要加密）
  final String? encryptionKey;
  
  /// 是否启用加密
  final bool enableEncryption;
  
  /// 存储目录（对象存储需要）
  final String? directory;

  /// 创建存储配置
  /// 
  /// [name] 存储名称，用于标识不同的存储实例
  /// [enableLog] 是否启用日志，默认为false
  /// [enableEncryption] 是否启用加密，默认为false
  /// [encryptionKey] 加密密钥，仅在enableEncryption为true时有效
  /// [directory] 存储目录，对象存储需要
  const StorageConfig({
    required this.name,
    this.enableLog = false,
    this.enableEncryption = false,
    this.encryptionKey,
    this.directory,
  });
  
  /// 创建一个默认的存储配置
  factory StorageConfig.defaultConfig() {
    return const StorageConfig(
      name: 'default_storage',
      enableLog: true,
      enableEncryption: false,
    );
  }

  /// 创建一个带加密的存储配置
  factory StorageConfig.secure({
    required String name,
    required String encryptionKey,
    bool enableLog = true,
  }) {
    return StorageConfig(
      name: name,
      enableLog: enableLog,
      enableEncryption: true,
      encryptionKey: encryptionKey,
    );
  }
  
  /// 创建配置副本
  StorageConfig copyWith({
    String? name,
    bool? enableLog,
    bool? enableEncryption,
    String? encryptionKey,
    String? directory,
  }) {
    return StorageConfig(
      name: name ?? this.name,
      enableLog: enableLog ?? this.enableLog,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      directory: directory ?? this.directory,
    );
  }
}
