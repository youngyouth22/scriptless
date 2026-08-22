import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';

/// Use case: Check whether the user with the given ID
/// has completed onboarding.
class CheckOnboardingStatusUseCase implements UseCase<bool, String> {
  /// Creates a [CheckOnboardingStatusUseCase].
  const CheckOnboardingStatusUseCase(this._repository);

  final SplashRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String params) =>
      _repository.isOnboardingCompleted(params);
}
