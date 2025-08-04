import 'package:flutter/foundation.dart';

/// 应用初始化接口
/// 
/// 负责协调应用启动过程中各模块的初始化，确保模块按正确的顺序初始化，
/// 并提供初始化状态的回调通知。
abstract class IAppInitializer {
  /// 初始化应用所有依赖的模块
  /// 
  /// [onProgress] 可选回调，用于报告初始化进度 (0.0 到 1.0)
  /// [onStepCompleted] 可选回调，用于报告每个初始化步骤的完成情况
  /// 
  /// 返回 [Future<bool>] 表示初始化是否成功
  Future<bool> initialize({
    ValueChanged<double>? onProgress,
    void Function(String stepName, bool success)? onStepCompleted,
  });

  /// 注册自定义初始化步骤
  /// 
  /// [name] 初始化步骤名称
  /// [initializer] 初始化函数
  /// [priority] 优先级，数字越小优先级越高，默认为 100
  /// [dependsOn] 该步骤所依赖的其他步骤名称列表
  void registerInitializer({
    required String name,
    required Future<bool> Function() initializer,
    int priority = 100,
    List<String> dependsOn = const [],
  });

  /// 获取应用是否已完成初始化
  bool get isInitialized;

  /// 获取初始化过程中发生的任何错误
  List<Object> get initializationErrors;

  /// 重置初始化状态，用于测试或重新初始化
  void reset();
}
