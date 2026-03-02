import 'package:flutter/material.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';

import '../di/module_registry.dart';
import '../di/service_locator.dart';

/// 应用初始化进度
class InitializationProgress {
  final String message;
  final int current;
  final int total;

  InitializationProgress({
    required this.message,
    required this.current,
    required this.total,
  });

  double get percentage => total > 0 ? current / total : 0.0;
}

/// 初始化生命周期控制器
///
/// 用于在应用退出等可等待的时机显式触发模块销毁。
class AppInitializerController {
  Future<void> Function()? _shutdownHandler;

  Future<void> shutdown() async {
    final handler = _shutdownHandler;
    if (handler == null) return;
    await handler();
  }

  void _attach(Future<void> Function() handler) {
    _shutdownHandler = handler;
  }

  void _detach() {
    _shutdownHandler = null;
  }
}

/// 应用初始化 Widget
/// 提供可视化的初始化过程，支持自定义加载和错误界面
class AppInitializerWidget extends StatefulWidget {
  /// 需要初始化的模块列表
  final List<IModule> modules;

  /// 自定义加载界面构建器
  final Widget Function(BuildContext, InitializationProgress)? loadingBuilder;

  /// 自定义错误界面构建器
  final Widget Function(BuildContext, Object)? errorBuilder;

  /// 可选的生命周期控制器，用于显式触发模块销毁
  final AppInitializerController? controller;

  /// 初始化成功后显示的应用主体
  final Widget child;

  const AppInitializerWidget({
    super.key,
    required this.modules,
    required this.child,
    this.loadingBuilder,
    this.errorBuilder,
    this.controller,
  });

  @override
  State<AppInitializerWidget> createState() => _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends State<AppInitializerWidget> {
  late Future<void> _initializationFuture;
  final ModuleRegistry _registry = ModuleRegistry();
  Future<void>? _shutdownFuture;
  InitializationProgress _progress = InitializationProgress(
    message: 'Starting initialization...',
    current: 0,
    total: 0,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_shutdownModules);
    _initializationFuture = _initialize();
  }

  @override
  void didUpdateWidget(covariant AppInitializerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_shutdownModules);
    }
  }

  Future<void> _initialize() async {
    try {
      // 注册所有模块到 Registry
      _registry.registerModules(widget.modules, replace: true);

      // 使用统一的初始化逻辑（包含依赖验证）
      await _registry.initializeAllWithProgress((module, current, total) {
        _updateProgress('Initializing ${module.name}...', current, total);
      });

      _updateProgress(
        'Initialization completed',
        widget.modules.length,
        widget.modules.length,
      );
    } catch (e, stackTrace) {
      // 记录错误（如果日志模块已初始化）
      if (ServiceLocator().isRegistered<ILogger>()) {
        ServiceLocator().get<ILogger>().error(
          'Initialization failed',
          error: e,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  void _updateProgress(String message, int current, int total) {
    final percentage = total > 0
        ? ((current / total) * 100).toStringAsFixed(1)
        : '0.0';
    debugPrint('[Init] $message ($current/$total) - $percentage%');
    if (mounted) {
      setState(() {
        _progress = InitializationProgress(
          message: message,
          current: current,
          total: total,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // 初始化中
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loadingBuilder?.call(context, _progress) ??
              _defaultLoadingWidget();
        }

        // 初始化失败
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              _defaultErrorWidget(snapshot.error!);
        }

        // 初始化成功，显示应用主体
        return widget.child;
      },
    );
  }

  /// 默认加载界面
  Widget _defaultLoadingWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(value: _progress.percentage),
              SizedBox(height: 16),
              Text(
                _progress.message,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                '${_progress.current} / ${_progress.total}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 默认错误界面
  Widget _defaultErrorWidget(Object error) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // 重新启动应用
                    setState(() {
                      _initializationFuture = _initialize();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _shutdownModules() {
    _shutdownFuture ??= _registry.disposeAll();
    return _shutdownFuture!;
  }
}
