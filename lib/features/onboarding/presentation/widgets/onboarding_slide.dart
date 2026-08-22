import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';

/// Placeholder slide widget for onboarding.
///
/// Intended to be styled and expanded by the UI designer.
class OnboardingSlide extends StatelessWidget {
  /// Creates an [OnboardingSlide].
  const OnboardingSlide({
    required this.title,
    required this.description,
    super.key,
    this.imagePath,
  });

  /// The main title of the slide.
  final String title;

  /// The description text of the slide.
  final String description;

  /// Optional asset image path.
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Placeholder(
            fallbackHeight: 200,
            fallbackWidth: double.infinity,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headingH4Bold.copyWith(
              color: AppColors.grey950,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
