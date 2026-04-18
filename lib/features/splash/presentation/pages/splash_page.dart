import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 启动页。
@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  /// 构造函数。
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_checkLoginFlow);
  }

  Future<void> _checkLoginFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }

    final storage = ref.read(kvStorageProvider);
    if (!storage.isOnboardingDone()) {
      unawaited(context.router.replace(const OnboardingRoute()));
      return;
    }

    final authed = ref.read(authProvider);
    if (authed) {
      unawaited(context.router.replace(const HomeRoute()));
    } else {
      unawaited(context.router.replace(const LoginRoute()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const FlutterLogo(size: 72),
            const SizedBox(height: 16),
            Text(context.t.splash.title),
          ],
        ),
      ),
    );
  }
}
