import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_seen_repository.dart';

/// Use case: Check whether the user has already seen the onboarding slides.
///
/// Returns `true` if the local flag is set, `false` on first launch.
/// Uses [NoParams] because the check is device-scoped, not user-scoped.
class HasSeenOnboardingUseCase implements UseCase<bool, NoParams> {
  /// Creates a [HasSeenOnboardingUseCase].
  const HasSeenOnboardingUseCase(this._repository);

  final OnboardingSeenRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repository.hasSeenOnboarding();
}
