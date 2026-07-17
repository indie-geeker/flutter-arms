import 'package:flutter/material.dart';
import 'package:super_overlay/super_overlay.dart';

/// 为 widget test 提供与生产根节点一致的 SuperOverlay 生命周期。
class SuperOverlayTestApp extends StatefulWidget {
  /// 创建测试应用。
  const SuperOverlayTestApp({required this.home, super.key});

  /// 测试首页。
  final Widget home;

  @override
  State<SuperOverlayTestApp> createState() => _SuperOverlayTestAppState();
}

class _SuperOverlayTestAppState extends State<SuperOverlayTestApp> {
  late final SuperOverlayIntegration _integration;

  @override
  void initState() {
    super.initState();
    _integration = SuperOverlay.integration();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: _integration.builder,
      navigatorObservers: [_integration.observer],
      home: widget.home,
    );
  }

  @override
  void dispose() {
    _integration.dispose();
    super.dispose();
  }
}
