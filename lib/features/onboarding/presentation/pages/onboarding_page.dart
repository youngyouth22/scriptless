import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/widgets/primary_button.dart';
import 'package:scriptless/di/injection_container.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:scriptless/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:scriptless/features/onboarding/presentation/widgets/page_indicator.dart';

/// Onboarding page placeholder.
///
/// UI design and interactive animations to be crafted by the UI designer.
/// Connects to [OnboardingCubit] for slide transitions and completion logic.
class OnboardingPage extends StatelessWidget {
  /// Creates the [OnboardingPage].
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (context) => sl<OnboardingCubit>(),
      child: const _OnboardingPageView(),
    );
  }
}

class _OnboardingPageView extends StatefulWidget {
  const _OnboardingPageView();

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView> {
  late final PageController _pageController;

  static const _slides = <Map<String, String>>[
    {
      'title': 'Master Difficult Workplace Conversations',
      'description':
          'Practice high-stakes management simulations with real-time AI.',
    },
    {
      'title': 'Real-Time Voice AI Feedback',
      'description':
          'Sharpen your assertiveness, empathy, and leadership presence.',
    },
    {
      'title': 'Measure Your Progress',
      'description': 'Track your skill metrics, streaks, and achievements.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go(AppRoutes.authLogin);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () =>
                  unawaited(context.read<OnboardingCubit>().skip()),
              child: const Text('Skip'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    context.read<OnboardingCubit>().goToSlide(index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return OnboardingSlide(
                      title: slide['title'] ?? '',
                      description: slide['description'] ?? '',
                    );
                  },
                ),
              ),
              OnboardingPageIndicator(
                controller: _pageController,
                count: _slides.length,
              ),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final isLast =
                      state is OnboardingInProgress && state.isLastPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PrimaryButton(
                      onPressed: () {
                        if (isLast) {
                          unawaited(
                            context.read<OnboardingCubit>().skip(),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      text: isLast ? 'Get Started' : 'Next',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
