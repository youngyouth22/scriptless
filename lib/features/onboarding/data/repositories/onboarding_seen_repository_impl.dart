import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_seen_repository.dart';

/// Concrete implementation of [OnboardingSeenRepository].
///
/// Delegates all persistence to [OnboardingLocalDataSource].
class OnboardingSeenRepositoryImpl implements OnboardingSeenRepository {
  /// Creates an [OnboardingSeenRepositoryImpl].
  const OnboardingSeenRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, bool>> hasSeenOnboarding() async {
    try {
      final result = await _localDataSource.hasSeenOnboarding();
      return Right(result);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOnboardingSeen() async {
    try {
      await _localDataSource.markOnboardingSeen();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
