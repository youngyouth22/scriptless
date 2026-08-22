import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Domain contract for checking and persisting the first-launch
/// onboarding flag.
///
/// This is distinct from [OnboardingRepository] which handles the remote
/// `profiles.onboarding_completed` flag for post-auth onboarding.
/// This contract manages the local pre-auth marketing slide flag.
abstract class OnboardingSeenRepository {
  /// Returns `true` if the user has already seen the marketing
  /// onboarding slides.
  Future<Either<Failure, bool>> hasSeenOnboarding();

  /// Marks the marketing onboarding slides as seen.
  Future<Either<Failure, Unit>> markOnboardingSeen();
}
