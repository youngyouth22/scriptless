import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_cubit.dart';

/// Base sealed class for all states emitted by [OnboardingCubit].
@immutable
sealed class OnboardingState {
  /// Default const constructor.
  const OnboardingState();
}

/// State representing active onboarding progression.
@immutable
final class OnboardingInProgress extends OnboardingState {
  /// Creates an [OnboardingInProgress] state.
  const OnboardingInProgress({
    required this.currentIndex,
    this.totalPages = 3,
  });

  /// The active slide index (0-indexed).
  final int currentIndex;

  /// Total number of onboarding slides.
  final int totalPages;

  /// Whether current slide is the first slide.
  bool get isFirstPage => currentIndex == 0;

  /// Whether current slide is the last slide.
  bool get isLastPage => currentIndex == totalPages - 1;

  /// Returns a copy of [OnboardingInProgress] with updated properties.
  OnboardingInProgress copyWith({
    int? currentIndex,
    int? totalPages,
  }) {
    return OnboardingInProgress(
      currentIndex: currentIndex ?? this.currentIndex,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingInProgress &&
          runtimeType == other.runtimeType &&
          currentIndex == other.currentIndex &&
          totalPages == other.totalPages;

  @override
  int get hashCode => currentIndex.hashCode ^ totalPages.hashCode;
}

/// State emitted while onboarding completion is being submitted/persisted.
@immutable
final class OnboardingSubmitting extends OnboardingState {
  /// Default const constructor.
  const OnboardingSubmitting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingSubmitting && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when onboarding flow is successfully completed.
@immutable
final class OnboardingCompleted extends OnboardingState {
  /// Default const constructor.
  const OnboardingCompleted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingCompleted && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when completing onboarding fails.
@immutable
final class OnboardingError extends OnboardingState {
  /// Creates an [OnboardingError] state.
  const OnboardingError(this.failure);

  /// The underlying failure.
  final Failure failure;

  /// Convenience getter for error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingError &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
