import 'package:flutter/widgets.dart';
import 'app_manager.dart';

/// AppManager 的依赖注入提供者
///
/// 使用 InheritedWidget 在 Widget 树中传递 AppManager 实例
/// 这样可以避免使用全局单例，使代码更容易测试和维护
class AppManagerProvider extends InheritedWidget {
  final AppManager appManager;

  const AppManagerProvider({
    super.key,
    required this.appManager,
    required super.child,
  });

  /// 从上下文中获取 AppManager 实例
  ///
  /// 如果找不到 AppManagerProvider，则抛出错误
  static AppManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppManagerProvider>();
    if (provider == null) {
      throw StateError(
        'AppManagerProvider not found in widget tree. '
        'Make sure to wrap your app with AppManagerProvider.'
      );
    }
    return provider.appManager;
  }

  /// 尝试从上下文中获取 AppManager 实例
  ///
  /// 如果找不到 AppManagerProvider，返回 null
  static AppManager? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppManagerProvider>();
    return provider?.appManager;
  }

  @override
  bool updateShouldNotify(AppManagerProvider oldWidget) {
    // 如果 appManager 实例改变了，则需要通知依赖的 widget
    return appManager != oldWidget.appManager;
  }
}
