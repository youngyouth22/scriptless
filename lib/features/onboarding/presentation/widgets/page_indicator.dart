import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Placeholder page indicator widget for onboarding.
///
/// Intended to be styled and refined by the UI designer.
class OnboardingPageIndicator extends StatelessWidget {
  /// Creates an [OnboardingPageIndicator].
  const OnboardingPageIndicator({
    required this.controller,
    required this.count,
    super.key,
  });

  /// The page controller managing page swipes.
  final PageController controller;

  /// Total number of pages.
  final int count;

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: const ExpandingDotsEffect(
        dotHeight: 8,
        dotWidth: 8,
        spacing: 6,
        activeDotColor: Colors.black87,
        dotColor: Colors.black26,
      ),
    );
  }
}
