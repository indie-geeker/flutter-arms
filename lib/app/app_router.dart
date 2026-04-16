import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arms/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/features/home/presentation/pages/explore_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/feed_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/home_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/profile_page.dart';
import 'package:flutter_arms/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_arms/features/splash/presentation/pages/splash_page.dart';

part 'app_router.gr.dart';

/// 全局路由配置。
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  /// 构造函数。
  AppRouter(this.ref);

  final WidgetRef ref;

  late final AuthGuard _authGuard = AuthGuard(ref);

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(
      page: HomeRoute.page,
      guards: <AutoRouteGuard>[_authGuard],
      children: <AutoRoute>[
        AutoRoute(page: FeedRoute.page, initial: true),
        AutoRoute(page: ExploreRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
  ];
}

/// 登录路由守卫。
class AuthGuard extends AutoRouteGuard {
  /// 构造函数。
  AuthGuard(this.ref);

  final WidgetRef ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthed = ref.read(authNotifierProvider);
    if (isAuthed) {
      resolver.next(true);
      return;
    }

    resolver.redirectUntil(const LoginRoute());
  }
}
