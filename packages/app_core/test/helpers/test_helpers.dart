import 'package:flutter/material.dart';
import 'package:app_interfaces/app_interfaces.dart';
import '../mocks/mock_storage.dart';
import '../mocks/mock_signature_provider.dart';
import '../mocks/mock_app_info.dart';
import '../../lib/src/app_config.dart';

/// 测试辅助工具类
class TestHelpers {
  /// 创建测试用的 AppConfig
  static AppConfig createTestAppConfig({
    String? channel,
    EnvironmentType? environment,
    Map<EnvironmentType, Map<String, dynamic>>? environmentConfigs,
    IStorage Function()? storageFactory,
    IAppInfo Function()? appInfoFactory,
    Future<String> Function()? signatureHashProvider,
    Locale? defaultLocale,
    List<Locale>? supportedLocales,
    Color? defaultPrimaryColor,
  }) {
    final mockStorage = storageFactory?.call() ?? MockKeyValueStorage();
    
    return AppConfig(
      channel: channel ?? 'test',
      defaultEnvironment: environment ?? EnvironmentType.development,
      environmentConfigs: environmentConfigs ?? {
        EnvironmentType.development: {
          'apiBaseUrl': 'https://test-api.example.com',
          'webSocketUrl': 'wss://test-api.example.com/ws',
          'enableVerboseLogging': true,
          'connectionTimeout': 30000,
        },
      },
      defaultLocale: defaultLocale ?? const Locale('zh', 'CN'),
      supportedLocales: supportedLocales ?? [
        const Locale('zh', 'CN'),
        const Locale('en', 'US'),
      ],
      defaultPrimaryColor: defaultPrimaryColor ?? Colors.blue,
      storageFactory: () => mockStorage,
      appInfoFactory: appInfoFactory ?? () => createMockAppInfo(
        channel: channel ?? 'test',
        storage: mockStorage as IKeyValueStorage?,
        signatureHashProvider: signatureHashProvider,
      ),
      signatureHashProvider: signatureHashProvider,
    );
  }
  
  /// 创建测试用的 MockStorage
  static MockStorage createMockStorage() {
    return MockStorage();
  }
  
  /// 创建测试用的 MockKeyValueStorage
  static MockKeyValueStorage createMockKeyValueStorage() {
    return MockKeyValueStorage();
  }
  
  /// 创建测试用的 MockAppInfo
  static MockAppInfo createMockAppInfo({
    String? channel,
    IKeyValueStorage? storage,
    Future<String> Function()? signatureHashProvider,
  }) {
    return MockAppInfo(
      channel: channel ?? 'test',
      storage: storage,
      signatureHashProvider: signatureHashProvider,
    );
  }
  
  /// 创建成功的签名提供者
  static Future<String> Function() createSuccessSignatureProvider([String? hash]) {
    return MockSignatureHashProvider.success(hash).provider;
  }
  
  /// 创建失败的签名提供者
  static Future<String> Function() createFailureSignatureProvider() {
    return MockSignatureHashProvider.failure().provider;
  }
  
  /// 创建带延迟的签名提供者
  static Future<String> Function() createDelayedSignatureProvider(
    Duration delay, [String? hash]
  ) {
    return MockSignatureHashProvider.withDelay(delay, hash).provider;
  }
  
  /// 验证进度回调是否被正确调用
  static void verifyProgressCallback(
    List<double> progressValues,
    double expectedMin,
    double expectedMax,
  ) {
    if (progressValues.isEmpty) {
      throw AssertionError('进度回调未被调用');
    }
    
    // 验证进度值在合理范围内
    for (final progress in progressValues) {
      if (progress < expectedMin || progress > expectedMax) {
        throw AssertionError('进度值 $progress 超出预期范围 [$expectedMin, $expectedMax]');
      }
    }
    
    // 验证进度是递增的
    for (int i = 1; i < progressValues.length; i++) {
      if (progressValues[i] < progressValues[i - 1]) {
        throw AssertionError('进度值应该是递增的，但发现 ${progressValues[i]} < ${progressValues[i - 1]}');
      }
    }
  }
  
  /// 验证步骤完成回调是否被正确调用
  static void verifyStepCompletedCallback(
    List<MapEntry<String, bool>> stepResults,
    List<String> expectedSteps,
  ) {
    if (stepResults.isEmpty) {
      throw AssertionError('步骤完成回调未被调用');
    }
    
    // 验证所有预期步骤都被调用
    final actualSteps = stepResults.map((e) => e.key).toSet();
    final expectedStepsSet = expectedSteps.toSet();
    
    if (!actualSteps.containsAll(expectedStepsSet)) {
      final missing = expectedStepsSet.difference(actualSteps);
      throw AssertionError('缺少预期的步骤: $missing');
    }
    
    // 验证所有步骤都成功完成
    final failedSteps = stepResults.where((e) => !e.value).map((e) => e.key).toList();
    if (failedSteps.isNotEmpty) {
      throw AssertionError('以下步骤执行失败: $failedSteps');
    }
  }
  
  /// 等待异步操作完成的辅助方法
  static Future<void> waitForAsync([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 10));
  }
  
  /// 创建测试用的环境配置
  static Map<EnvironmentType, Map<String, dynamic>> createTestEnvironmentConfigs() {
    return {
      EnvironmentType.development: {
        'apiBaseUrl': 'https://dev-api.example.com',
        'webSocketUrl': 'wss://dev-api.example.com/ws',
        'enableVerboseLogging': true,
        'connectionTimeout': 30000,
      },
      EnvironmentType.staging: {
        'apiBaseUrl': 'https://staging-api.example.com',
        'webSocketUrl': 'wss://staging-api.example.com/ws',
        'enableVerboseLogging': true,
        'connectionTimeout': 20000,
      },
      EnvironmentType.production: {
        'apiBaseUrl': 'https://api.example.com',
        'webSocketUrl': 'wss://api.example.com/ws',
        'enableVerboseLogging': false,
        'connectionTimeout': 15000,
        'enableCrashReporting': true,
        'enablePerformanceMonitoring': true,
      },
    };
  }
}
