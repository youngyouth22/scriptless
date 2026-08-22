import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_seen_repository.dart';

/// Use case: Mark that the user has seen the onboarding marketing slides.
///
/// Called once, just before navigating from the onboarding screen to login.
/// Uses [NoParams] because the flag is device-scoped, not user-scoped.
class MarkOnboardingSeenUseCase implements UseCase<Unit, NoParams> {
  /// Creates a [MarkOnboardingSeenUseCase].
  const MarkOnboardingSeenUseCase(this._repository);

  final OnboardingSeenRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.markOnboardingSeen();
}
