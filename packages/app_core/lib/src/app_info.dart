import 'package:app_interfaces/app_interfaces.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用信息持久化键值
const String _firstInstallTimeKey = 'first_install_time';
const String _lastUpdateTimeKey = 'last_update_time';


/// [AppInfo] 实现 [IAppInfo] 接口
/// 
/// 提供应用的元数据信息，如版本号、构建号、包名等
class AppInfo implements IAppInfo {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  late PackageInfo _packageInfo;
  String? _deviceId;
  final String _channel;
  DateTime? _firstInstallTime;
  DateTime? _lastUpdateTime;
  IKeyValueStorage? _kvStorage;

  /// 应用签名哈希，通常需要应用层传入或通过平台通道获取
  final Future<String> Function()? _signatureHashProvider;

  AppInfo({
    required String channel,
    Future<String> Function()? signatureHashProvider,
    IKeyValueStorage? storage
  }) : _channel = channel,
        _signatureHashProvider = signatureHashProvider,
        _kvStorage = storage;

  /// 初始化应用信息
  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();

    // 获取设备信息（此处仅获取ID，实际使用时应考虑隐私政策）
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await _deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
      // 真实场景中应考虑Android 10+ 的设备标识符政策
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor;
    } else {
      _deviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
    }

    // 在实际应用中，首次安装时间和最后更新时间应从存储中获取
    final firstInstallTimeStr = await _kvStorage?.getString(_firstInstallTimeKey);
    final lastUpdateTimeStr = await _kvStorage?.getString(_lastUpdateTimeKey);

    if (firstInstallTimeStr != null) {
      try {
        _firstInstallTime = DateTime.parse(firstInstallTimeStr);
      } catch (e) {
        _firstInstallTime = DateTime.now();
      }
    } else {
      _firstInstallTime = DateTime.now();
    }

    if (lastUpdateTimeStr != null) {
      try {
        _lastUpdateTime = DateTime.parse(lastUpdateTimeStr);
      } catch (e) {
        _lastUpdateTime = DateTime.now();
      }
    } else {
      _lastUpdateTime = DateTime.now();
    }

    await _kvStorage?.setString(_firstInstallTimeKey, _firstInstallTime.toString());
    await _kvStorage?.setString(_lastUpdateTimeKey, _lastUpdateTime.toString());
  }

  @override
  String get appName => _packageInfo.appName;

  @override
  String get packageName => _packageInfo.packageName;

  @override
  String get version => _packageInfo.version;

  @override
  String get buildNumber => _packageInfo.buildNumber;

  @override
  Future<String> get deviceId async {
    return _deviceId ?? 'unknown';
  }

  @override
  String get channel => _channel;

  @override
  DateTime get firstInstallTime => _firstInstallTime!;

  @override
  DateTime get lastUpdateTime => _lastUpdateTime!;

  @override
  String get fullVersion => '$version+$buildNumber';

  @override
  bool isUpdateRequired(String minimumRequiredVersion) {
    // 简单的版本比较，实际使用时可能需要更复杂的逻辑
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
      return await _signatureHashProvider();
    }
    return 'signature-not-provided';
  }

  @override
  String get userAgent {
    final platform = defaultTargetPlatform.toString().split('.').last;
    return '$appName/$version ($platform; $packageName)';
  }
}
