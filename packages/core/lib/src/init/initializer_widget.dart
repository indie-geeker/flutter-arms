import 'package:flutter/material.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';

import '../di/module_registry.dart';
import '../di/service_locator.dart';

/// Application initialization progress.
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

/// Initialization lifecycle controller.
///
/// Used to explicitly trigger module disposal at an awaitable point,
/// such as application exit.
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

/// Application initializer widget.
/// Provides a visual initialization process with customizable loading
/// and error screens.
class AppInitializerWidget extends StatefulWidget {
  /// List of modules to initialize.
  final List<IModule> modules;

  /// Custom loading screen builder.
  final Widget Function(BuildContext, InitializationProgress)? loadingBuilder;

  /// Custom error screen builder.
  final Widget Function(BuildContext, Object)? errorBuilder;

  /// Optional lifecycle controller for explicit module disposal.
  final AppInitializerController? controller;

  /// Application body shown after successful initialization.
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
      // Register all modules into the registry.
      _registry.registerModules(widget.modules, replace: true);

      // Use the unified initialization logic (includes dependency validation).
      await _registry.initializeAllWithProgress((module, current, total) {
        _updateProgress('Initializing ${module.name}...', current, total);
      });

      _updateProgress(
        'Initialization completed',
        widget.modules.length,
        widget.modules.length,
      );
    } catch (e, stackTrace) {
      // Log the error if the logger module is already initialized.
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
        // Initializing.
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loadingBuilder?.call(context, _progress) ??
              _defaultLoadingWidget();
        }

        // Initialization failed.
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              _defaultErrorWidget(snapshot.error!);
        }

        // Initialization succeeded — show application body.
        return widget.child;
      },
    );
  }

  /// Default loading screen.
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

  /// Default error screen.
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
                    // Restart the application.
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
