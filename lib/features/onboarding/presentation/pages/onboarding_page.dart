import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/features/onboarding/presentation/view_models/onboarding_view_model.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首次引导页。
@RoutePage()
class OnboardingPage extends ConsumerStatefulWidget {
  /// 构造函数。
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(onboardingViewModelProvider).pageIndex;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeAndNavigate() async {
    final notifier = ref.read(onboardingViewModelProvider.notifier);
    await notifier.complete();
    if (!mounted) {
      return;
    }

    context.router.replace(const LoginRoute());
  }

  Future<void> _goToNextPage(int currentIndex) async {
    await _pageController.animateToPage(
      currentIndex + 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = ref.watch(onboardingViewModelProvider);
    final notifier = ref.read(onboardingViewModelProvider.notifier);
    final slides = _slides(t);
    final isLastPage = state.pageIndex == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _completeAndNavigate,
                  child: Text(t.onboarding.skip),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: notifier.setPage,
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    return _OnboardingSlideView(
                      slide: slides[index],
                      index: index + 1,
                      total: slides.length,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(slides.length, (index) {
                  final selected = index == state.pageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLastPage
                    ? _completeAndNavigate
                    : () => _goToNextPage(state.pageIndex),
                child: Text(
                  isLastPage ? t.onboarding.start : t.onboarding.next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.title, required this.body});

  final String title;
  final String body;
}

List<_OnboardingSlide> _slides(Translations t) => <_OnboardingSlide>[
  _OnboardingSlide(
    title: t.onboarding.slide1Title,
    body: t.onboarding.slide1Body,
  ),
  _OnboardingSlide(
    title: t.onboarding.slide2Title,
    body: t.onboarding.slide2Body,
  ),
  _OnboardingSlide(
    title: t.onboarding.slide3Title,
    body: t.onboarding.slide3Body,
  ),
];

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({
    required this.slide,
    required this.index,
    required this.total,
  });

  final _OnboardingSlide slide;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              slide.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              slide.body,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '$index / $total',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
