// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [FeedbackCenterPage]
class FeedbackCenterRoute extends PageRouteInfo<void> {
  const FeedbackCenterRoute({List<PageRouteInfo>? children})
    : super(FeedbackCenterRoute.name, initialChildren: children);

  static const String name = 'FeedbackCenterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedbackCenterPage();
    },
  );
}

/// generated route for
/// [FeedbackDetailPage]
class FeedbackDetailRoute extends PageRouteInfo<FeedbackDetailRouteArgs> {
  FeedbackDetailRoute({
    required String ticketId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         FeedbackDetailRoute.name,
         args: FeedbackDetailRouteArgs(ticketId: ticketId, key: key),
         initialChildren: children,
       );

  static const String name = 'FeedbackDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FeedbackDetailRouteArgs>();
      return FeedbackDetailPage(ticketId: args.ticketId, key: args.key);
    },
  );
}

class FeedbackDetailRouteArgs {
  const FeedbackDetailRouteArgs({required this.ticketId, this.key});

  final String ticketId;

  final Key? key;

  @override
  String toString() {
    return 'FeedbackDetailRouteArgs{ticketId: $ticketId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FeedbackDetailRouteArgs) return false;
    return ticketId == other.ticketId && key == other.key;
  }

  @override
  int get hashCode => ticketId.hashCode ^ key.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [HomeTabPage]
class HomeTabRoute extends PageRouteInfo<void> {
  const HomeTabRoute({List<PageRouteInfo>? children})
    : super(HomeTabRoute.name, initialChildren: children);

  static const String name = 'HomeTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeTabPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [ShowcasePage]
class ShowcaseRoute extends PageRouteInfo<void> {
  const ShowcaseRoute({List<PageRouteInfo>? children})
    : super(ShowcaseRoute.name, initialChildren: children);

  static const String name = 'ShowcaseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShowcasePage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [SubmitFeedbackPage]
class SubmitFeedbackRoute extends PageRouteInfo<void> {
  const SubmitFeedbackRoute({List<PageRouteInfo>? children})
    : super(SubmitFeedbackRoute.name, initialChildren: children);

  static const String name = 'SubmitFeedbackRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SubmitFeedbackPage();
    },
  );
}
