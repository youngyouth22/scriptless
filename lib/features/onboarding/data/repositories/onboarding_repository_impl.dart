import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of [OnboardingRepository].
class OnboardingRepositoryImpl implements OnboardingRepository {
  /// Creates an [OnboardingRepositoryImpl].
  const OnboardingRepositoryImpl(this._remoteDataSource);

  final OnboardingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Unit>> completeOnboarding(String userId) async {
    try {
      await _remoteDataSource.completeOnboarding(userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
