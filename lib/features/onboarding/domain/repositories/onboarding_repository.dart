// Abstract contract is required for Clean Architecture
// and dependency inversion.
// ignore_for_file: one_member_abstracts
import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';

/// Contract for onboarding operations in the domain layer.
abstract class OnboardingRepository {
  /// Marks the onboarding as completed for user with [userId].
  Future<Either<Failure, Unit>> completeOnboarding(String userId);
}
