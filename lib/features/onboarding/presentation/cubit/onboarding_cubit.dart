// Cubit constructors must call super() in the initializer list.
// ignore_for_file: prefer_initializing_formals
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/mark_onboarding_seen_usecase.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_state.dart';

/// Cubit managing the slide index and completion of the onboarding flow.
class OnboardingCubit extends Cubit<OnboardingState> {
  /// Creates an [OnboardingCubit].
  OnboardingCubit({
    required CompleteOnboardingUseCase completeOnboarding,
    required MarkOnboardingSeenUseCase markOnboardingSeen,
    int totalPages = 3,
  }) : _completeOnboarding = completeOnboarding,
       _markOnboardingSeen = markOnboardingSeen,
       _totalPages = totalPages,
       super(OnboardingInProgress(currentIndex: 0, totalPages: totalPages));

  final CompleteOnboardingUseCase _completeOnboarding;
  final MarkOnboardingSeenUseCase _markOnboardingSeen;
  final int _totalPages;

  /// Advances to the next slide if not already on the last slide.
  void nextSlide() {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      if (currentState.currentIndex < _totalPages - 1) {
        final nextIndex = currentState.currentIndex + 1;
        log('OnboardingCubit: Next slide -> $nextIndex', name: 'onboarding');
        emit(currentState.copyWith(currentIndex: nextIndex));
      }
    }
  }

  /// Navigates to the previous slide if not on the first slide.
  void previousSlide() {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      if (currentState.currentIndex > 0) {
        final prevIndex = currentState.currentIndex - 1;
        log(
          'OnboardingCubit: Previous slide -> $prevIndex',
          name: 'onboarding',
        );
        emit(currentState.copyWith(currentIndex: prevIndex));
      }
    }
  }

  /// Sets the slide index directly (e.g. from page swipe).
  void goToSlide(int index) {
    if (index >= 0 && index < _totalPages) {
      log('OnboardingCubit: Go to slide -> $index', name: 'onboarding');
      emit(OnboardingInProgress(currentIndex: index, totalPages: _totalPages));
    }
  }

  /// Skips the onboarding flow directly.
  ///
  /// Persists the [MarkOnboardingSeenUseCase] flag so that the app never
  /// shows the onboarding slides again on subsequent launches.
  Future<void> skip() async {
    log('OnboardingCubit: Skipping onboarding', name: 'onboarding');
    final result = await _markOnboardingSeen(const NoParams());
    result.fold(
      (failure) {
        log(
          'OnboardingCubit: markOnboardingSeen failed — ${failure.message}; '
          'proceeding anyway to avoid blocking user',
          name: 'onboarding',
        );
      },
      (_) {
        log('OnboardingCubit: onboarding marked as seen', name: 'onboarding');
      },
    );
    emit(const OnboardingCompleted());
  }

  /// Persists onboarding completion for [userId] and emits completed state.
  Future<void> complete(String userId) async {
    log(
      'OnboardingCubit: Completing onboarding for user $userId',
      name: 'onboarding',
    );
    emit(const OnboardingSubmitting());

    final result = await _completeOnboarding(userId);

    result.fold(
      (failure) {
        log(
          'OnboardingCubit: Complete onboarding failed — ${failure.message}',
          name: 'onboarding',
        );
        emit(OnboardingError(failure));
      },
      (_) {
        log(
          'OnboardingCubit: Onboarding successfully completed',
          name: 'onboarding',
        );
        emit(const OnboardingCompleted());
      },
    );
  }
}
