import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/exceptions.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/splash/data/datasources/splash_remote_datasource.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';

/// Implementation of [SplashRepository].
class SplashRepositoryImpl implements SplashRepository {
  /// Creates a [SplashRepositoryImpl].
  const SplashRepositoryImpl(this._remoteDataSource);

  final SplashRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId) async {
    try {
      final isCompleted = await _remoteDataSource.isOnboardingCompleted(userId);
      return Right(isCompleted);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> initializePowerSync() async {
    try {
      await _remoteDataSource.initializePowerSync();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
