import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';

/// Verifies the OTP token sent to a new user email during sign-up.
class VerifySignUpOtpUseCase implements UseCase<Unit, VerifyOtpParams> {
  /// Creates a [VerifySignUpOtpUseCase].
  VerifySignUpOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(VerifyOtpParams params) =>
      _repository.verifySignUpOtp(
        email: params.email,
        token: params.token,
      );
}
