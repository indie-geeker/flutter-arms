import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/feedback_center_page.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/feedback_detail_page.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/submit_feedback_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/home_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/home_tab_page.dart';
import 'package:flutter_arms/features/home/presentation/pages/profile_page.dart';
import 'package:flutter_arms/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_arms/features/showcase/presentation/pages/showcase_page.dart';
import 'package:flutter_arms/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_router.gr.dart';

/// 全局路由配置。
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  /// 构造函数。
  AppRouter(this.ref);

  final WidgetRef ref;

  /// 认证态变化的 `Listenable`，供 `MaterialApp.router` 的 `reevaluateListenable` 使用。
  late final AuthListenable authListenable = AuthListenable(ref);

  late final AuthGuard _authGuard = AuthGuard(ref);
  late final GuestGuard _guestGuard = GuestGuard(ref);

  @override
  List<AutoRoute> get routes {
    final isDevFlavor = ref.read(appEnvProvider).flavor == AppFlavor.dev;

    return <AutoRoute>[
      AutoRoute(page: SplashRoute.page, initial: true),
      AutoRoute(page: OnboardingRoute.page),
      AutoRoute(page: LoginRoute.page, guards: <AutoRouteGuard>[_guestGuard]),
      if (isDevFlavor) AutoRoute(page: ShowcaseRoute.page),
      AutoRoute(
        page: FeedbackCenterRoute.page,
        guards: <AutoRouteGuard>[_authGuard],
      ),
      AutoRoute(
        page: SubmitFeedbackRoute.page,
        guards: <AutoRouteGuard>[_authGuard],
      ),
      AutoRoute(
        page: FeedbackDetailRoute.page,
        guards: <AutoRouteGuard>[_authGuard],
      ),
      AutoRoute(
        page: HomeRoute.page,
        guards: <AutoRouteGuard>[_authGuard],
        children: <AutoRoute>[
          AutoRoute(page: HomeTabRoute.page, initial: true),
          AutoRoute(page: ProfileRoute.page),
        ],
      ),
    ];
  }
}

/// 访客页守卫：已登录时不再停留在登录页。
class GuestGuard extends AutoRouteGuard {
  /// 构造函数。
  GuestGuard(this.ref);

  final WidgetRef ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthed = ref.read(authProvider);
    if (!isAuthed) {
      resolver.next(true);
      return;
    }

    resolver.redirectUntil(const HomeRoute(), replace: true);
  }
}

/// 登录路由守卫。
class AuthGuard extends AutoRouteGuard {
  /// 构造函数。
  AuthGuard(this.ref);

  final WidgetRef ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthed = ref.read(authProvider);
    if (isAuthed) {
      resolver.next(true);
      return;
    }

    resolver.redirectUntil(const LoginRoute(), replace: true);
  }
}

/// 将 `authProvider` 的变化转发为 `Listenable`，供 auto_route 触发守卫重评估。
class AuthListenable extends ChangeNotifier {
  /// 构造函数。
  AuthListenable(this._ref) {
    _subscription = _ref.listenManual<bool>(
      authProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }

  final WidgetRef _ref;
  late final ProviderSubscription<bool> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
