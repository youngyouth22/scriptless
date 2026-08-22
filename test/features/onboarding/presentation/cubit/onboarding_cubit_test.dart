import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/mark_onboarding_seen_usecase.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_state.dart';

class MockCompleteOnboardingUseCase extends Mock
    implements CompleteOnboardingUseCase {}

class MockMarkOnboardingSeenUseCase extends Mock
    implements MarkOnboardingSeenUseCase {}

void main() {
  late MockCompleteOnboardingUseCase mockCompleteOnboarding;
  late MockMarkOnboardingSeenUseCase mockMarkOnboardingSeen;

  const tUserId = 'user-123';

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockCompleteOnboarding = MockCompleteOnboardingUseCase();
    mockMarkOnboardingSeen = MockMarkOnboardingSeenUseCase();
    // Default: markOnboardingSeen succeeds.
    when(
      () => mockMarkOnboardingSeen(any()),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));
  });

  OnboardingCubit buildCubit({int totalPages = 3}) => OnboardingCubit(
    completeOnboarding: mockCompleteOnboarding,
    markOnboardingSeen: mockMarkOnboardingSeen,
    totalPages: totalPages,
  );

  group('OnboardingCubit', () {
    test('initial state should be OnboardingInProgress with index 0', () {
      expect(
        buildCubit().state,
        const OnboardingInProgress(currentIndex: 0),
      );
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'nextSlide increments currentIndex',
      build: buildCubit,
      act: (cubit) => cubit.nextSlide(),
      expect: () => const [
        OnboardingInProgress(currentIndex: 1),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'nextSlide does not increment past the last slide',
      build: buildCubit,
      seed: () => const OnboardingInProgress(currentIndex: 2),
      act: (cubit) => cubit.nextSlide(),
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'previousSlide decrements currentIndex',
      build: buildCubit,
      seed: () => const OnboardingInProgress(currentIndex: 2),
      act: (cubit) => cubit.previousSlide(),
      expect: () => const [
        OnboardingInProgress(currentIndex: 1),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'previousSlide does not decrement below 0',
      build: buildCubit,
      seed: () => const OnboardingInProgress(currentIndex: 0),
      act: (cubit) => cubit.previousSlide(),
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'goToSlide sets valid index',
      build: buildCubit,
      act: (cubit) => cubit.goToSlide(2),
      expect: () => const [
        OnboardingInProgress(currentIndex: 2),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'skip emits OnboardingCompleted',
      build: buildCubit,
      act: (cubit) => cubit.skip(),
      expect: () => const [
        OnboardingCompleted(),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'complete emits [OnboardingSubmitting, OnboardingCompleted] on success',
      build: () {
        when(
          () => mockCompleteOnboarding(tUserId),
        ).thenAnswer((_) async => const Right<Failure, Unit>(unit));
        return buildCubit();
      },
      act: (cubit) => cubit.complete(tUserId),
      expect: () => const [
        OnboardingSubmitting(),
        OnboardingCompleted(),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'complete emits [OnboardingSubmitting, OnboardingError] on failure',
      build: () {
        when(() => mockCompleteOnboarding(tUserId)).thenAnswer(
          (_) async =>
              const Left<Failure, Unit>(ServerFailure('Failed to complete')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.complete(tUserId),
      expect: () => const [
        OnboardingSubmitting(),
        OnboardingError(ServerFailure('Failed to complete')),
      ],
    );
  });
}
