import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/routes/router_extensions.dart';
import '../../../../core/cache/provider/cache_providers.dart';
@RoutePage()
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Center(
          child: FutureBuilder(
            future: _initialize(context, ref),
            builder: (context, snapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 使用动画图标
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // 应用名称，可以根据实际情况修改
                  Text(
                    'ARMS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  else if (snapshot.hasError)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '初始化失败: ${snapshot.error}',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '初始化完成...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _initialize(BuildContext context, WidgetRef ref) async {
    // 创建两个并行任务
    final futures = await Future.wait([
      // 等待缓存服务初始化
      ref.read(cacheServiceNotifierProvider.future),

      // 确保 Splash 页面至少显示 2 秒
      Future.delayed(const Duration(seconds: 2)),
    ]);


    // 导航到认证界面
    // 使用全局路由扩展方法
    appRouter.replaceWithAuth();

    // 或者也可以使用以下方式：
    // context.replaceWithAuth();
    // context.replaceWithPath(AppRoutes.auth);
  }
}
