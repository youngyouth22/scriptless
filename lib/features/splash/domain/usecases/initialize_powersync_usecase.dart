import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';

/// Use case: Initialize local PowerSync database and connection.
class InitializePowerSyncUseCase implements UseCase<Unit, NoParams> {
  /// Creates an [InitializePowerSyncUseCase].
  const InitializePowerSyncUseCase(this._repository);

  final SplashRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.initializePowerSync();
}
