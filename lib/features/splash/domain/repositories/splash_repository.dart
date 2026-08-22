import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';

/// Contract for splash operations including onboarding check
/// and PowerSync database initialization.
abstract class SplashRepository {
  /// Checks whether the user with [userId] has completed the onboarding flow.
  Future<Either<Failure, bool>> isOnboardingCompleted(String userId);

  /// Initializes the local PowerSync database and sync connection.
  Future<Either<Failure, Unit>> initializePowerSync();
}
