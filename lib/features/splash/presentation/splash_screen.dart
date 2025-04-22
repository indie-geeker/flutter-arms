import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_router.dart';
import '../../../core/cache/provider/cache_providers.dart';
@RoutePage()
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _initialize(context, ref),
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png'),
                const SizedBox(height: 24),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CircularProgressIndicator()
                else if (snapshot.hasError)
                  Text('初始化失败: ${snapshot.error}')
                else
                  const Text('初始化完成...')
              ],
            );
          },
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

    
    // 导航到主界面
    context.router.replace(const HomeRoute());
  }
}
