import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/i18n/strings.g.dart';

/// 首页壳页面（底部导航）。
@RoutePage()
class HomePage extends StatelessWidget {
  /// 构造函数。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return AutoTabsScaffold(
      routes: const <PageRouteInfo<dynamic>>[
        FeedRoute(),
        ExploreRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              label: t.home.feed,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              label: t.home.explore,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: t.home.profile,
            ),
          ],
        );
      },
    );
  }
}
