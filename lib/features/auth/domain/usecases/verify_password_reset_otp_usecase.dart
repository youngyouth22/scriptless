import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for [VerifyPasswordResetOtpUseCase].
class VerifyOtpParams {
  /// Creates a [VerifyOtpParams].
  const VerifyOtpParams({required this.email, required this.token});

  /// The user's email address.
  final String email;

  /// The 6-digit OTP token.
  final String token;
}

/// Verifies the OTP recovery token sent to a user email.
class VerifyPasswordResetOtpUseCase implements UseCase<Unit, VerifyOtpParams> {
  /// Creates a [VerifyPasswordResetOtpUseCase].
  VerifyPasswordResetOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(VerifyOtpParams params) =>
      _repository.verifyPasswordResetOtp(
        email: params.email,
        token: params.token,
      );
}
