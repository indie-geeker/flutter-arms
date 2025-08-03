import 'package:app_interfaces/app_interfaces.dart';

/// Mock AppInfo 实现，用于测试
class MockAppInfo implements IAppInfo {
  final String _channel;
  final String _appName;
  final String _packageName;
  final String _version;
  final String _buildNumber;
  final String _deviceId;
  final DateTime _firstInstallTime;
  final DateTime _lastUpdateTime;
  final IKeyValueStorage? _storage;
  final Future<String> Function()? _signatureHashProvider;
  
  bool _isInitialized = false;

  MockAppInfo({
    required String channel,
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? deviceId,
    DateTime? firstInstallTime,
    DateTime? lastUpdateTime,
    IKeyValueStorage? storage,
    Future<String> Function()? signatureHashProvider,
  }) : _channel = channel,
       _appName = appName ?? 'Test App',
       _packageName = packageName ?? 'com.example.test',
       _version = version ?? '1.0.0',
       _buildNumber = buildNumber ?? '1',
       _deviceId = deviceId ?? 'test-device-id',
       _firstInstallTime = firstInstallTime ?? DateTime.now(),
       _lastUpdateTime = lastUpdateTime ?? DateTime.now(),
       _storage = storage,
       _signatureHashProvider = signatureHashProvider;

  /// 初始化 Mock AppInfo
  Future<void> initialize() async {
    // 模拟一些初始化延迟
    await Future.delayed(const Duration(milliseconds: 10));
    
    // 如果有存储，保存一些测试数据
    if (_storage != null) {
      await _storage!.setString('first_install_time', _firstInstallTime.toString());
      await _storage!.setString('last_update_time', _lastUpdateTime.toString());
    }
    
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  @override
  String get appName => _appName;

  @override
  String get packageName => _packageName;

  @override
  String get version => _version;

  @override
  String get buildNumber => _buildNumber;

  @override
  Future<String> get deviceId async => _deviceId;

  @override
  String get channel => _channel;

  @override
  DateTime get firstInstallTime => _firstInstallTime;

  @override
  DateTime get lastUpdateTime => _lastUpdateTime;

  @override
  String get fullVersion => '$version+$buildNumber';

  @override
  bool isUpdateRequired(String minimumRequiredVersion) {
    // 简单的版本比较逻辑
    final currentParts = version.split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    final requiredParts = minimumRequiredVersion.split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    // 补齐位数
    while (currentParts.length < requiredParts.length) {
      currentParts.add(0);
    }
    while (requiredParts.length < currentParts.length) {
      requiredParts.add(0);
    }

    // 逐位比较
    for (int i = 0; i < currentParts.length; i++) {
      if (currentParts[i] < requiredParts[i]) {
        return true; // 需要更新
      } else if (currentParts[i] > requiredParts[i]) {
        return false; // 不需要更新
      }
    }

    return false; // 版本相同，不需要更新
  }

  @override
  Future<String> get signatureHash async {
    if (_signatureHashProvider != null) {
      return await _signatureHashProvider!();
    }
    return 'mock-signature-hash';
  }

  @override
  String get userAgent {
    return '$appName/$version (test; $packageName)';
  }
}
