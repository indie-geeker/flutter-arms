import 'dart:async';
import 'dart:collection';
import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

/// 初始化步骤定义
class _InitStep {
  /// 步骤名称
  final String name;

  /// 初始化函数
  final Future<bool> Function() initializer;

  /// 优先级，数值越小优先级越高
  final int priority;

  /// 依赖的其他步骤名称
  final List<String> dependsOn;

  /// 是否已初始化
  bool isInitialized = false;

  /// 初始化是否成功
  bool? success;

  _InitStep({
    required this.name,
    required this.initializer,
    required this.priority,
    required this.dependsOn,
  });
}

/// [AppInitializer] 实现 [IAppInitializer] 接口
/// 
/// 负责协调应用启动过程中各模块的初始化，确保模块按正确的顺序初始化
class AppInitializer implements IAppInitializer {
  final List<_InitStep> _steps = [];
  final List<Object> _errors = [];
  bool _isInitialized = false;

  @override
  Future<bool> initialize({
    ValueChanged<double>? onProgress,
    void Function(String stepName, bool success)? onStepCompleted,
  }) async {
    if (_isInitialized) {
      return true;
    }

    // 使用拓扑排序处理依赖关系
    final sortedSteps = _topologicalSort(_steps);
    if (sortedSteps == null) {
      _errors.add(Exception('检测到循环依赖'));
      return false;
    }

    // 初始化总步骤数
    final totalSteps = sortedSteps.length;
    int completedSteps = 0;

    // 进行初始化
    bool allSuccess = true;
    try {
      for (final step in sortedSteps) {
        if (step.isInitialized) {
          completedSteps++;
          onProgress?.call(completedSteps / totalSteps);
          continue;
        }

        try {
          final success = await step.initializer();
          step.isInitialized = true;
          step.success = success;

          if (!success) {
            allSuccess = false;
            _errors.add(Exception('步骤 ${step.name} 初始化失败'));
          }

          // 通知步骤完成
          onStepCompleted?.call(step.name, success);
        } catch (e) {
          step.isInitialized = true;
          step.success = false;
          allSuccess = false;
          _errors.add(e);
          onStepCompleted?.call(step.name, false);
        }

        // 更新进度
        completedSteps++;
        onProgress?.call(completedSteps / totalSteps);
      }
    } catch (e) {
      _errors.add(e);
      allSuccess = false;
    }

    _isInitialized = allSuccess;
    return allSuccess;
  }

  @override
  void registerInitializer({
    required String name,
    required Future<bool> Function() initializer,
    int priority = 100,
    List<String> dependsOn = const [],
  }) {
    // 检查是否已存在同名步骤
    if (_steps.any((step) => step.name == name)) {
      throw Exception('初始化步骤 $name 已存在');
    }

    _steps.add(_InitStep(
      name: name,
      initializer: initializer,
      priority: priority,
      dependsOn: dependsOn,
    ));
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<Object> get initializationErrors => List.unmodifiable(_errors);

  @override
  void reset() {
    _steps.clear();
    _errors.clear();
    _isInitialized = false;
  }

  /// 拓扑排序处理依赖关系
  List<_InitStep>? _topologicalSort(List<_InitStep> steps) {
    final Map<String, _InitStep> stepMap = {};
    final Map<String, int> inDegree = {};
    final Map<String, List<String>> graph = {};
    
    // 构建步骤映射和图
    for (final step in steps) {
      stepMap[step.name] = step;
      inDegree[step.name] = 0;
      graph[step.name] = [];
    }
    
    // 构建依赖图和计算入度
    for (final step in steps) {
      for (final dependency in step.dependsOn) {
        if (!stepMap.containsKey(dependency)) {
          // 依赖的步骤不存在
          return null;
        }
        graph[dependency]!.add(step.name);
        inDegree[step.name] = inDegree[step.name]! + 1;
      }
    }
    
    // Kahn算法进行拓扑排序
    final Queue<String> queue = Queue<String>();
    final List<_InitStep> result = [];
    
    // 将所有入度为0的节点加入队列
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(stepMap[current]!);
      
      // 处理当前节点的所有邻接节点
      for (final neighbor in graph[current]!) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }
    
    // 如果结果长度不等于步骤数，说明存在循环依赖
    if (result.length != steps.length) {
      return null;
    }
    
    // 在相同拓扑层级内按优先级排序
    result.sort((a, b) {
      // 如果两个步骤没有依赖关系，按优先级排序
      if (!_hasDependencyPath(a.name, b.name, graph) && 
          !_hasDependencyPath(b.name, a.name, graph)) {
        return a.priority.compareTo(b.priority);
      }
      return 0;
    });
    
    return result;
  }
  
  /// 检查是否存在从source到target的依赖路径
  bool _hasDependencyPath(String source, String target, Map<String, List<String>> graph) {
    final visited = <String>{};
    final queue = Queue<String>();
    queue.add(source);
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (visited.contains(current)) continue;
      visited.add(current);
      
      if (current == target) return true;
      
      for (final neighbor in graph[current] ?? []) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    
    return false;
  }
}
