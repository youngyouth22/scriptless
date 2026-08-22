import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case: Mark user onboarding as completed.
class CompleteOnboardingUseCase implements UseCase<Unit, String> {
  /// Creates a [CompleteOnboardingUseCase].
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repository.completeOnboarding(params);
}
