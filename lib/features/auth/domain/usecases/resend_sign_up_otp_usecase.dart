import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Resends the sign-up verification OTP code to the requested email.
class ResendSignUpOtpUseCase implements UseCase<Unit, String> {
  /// Creates a [ResendSignUpOtpUseCase].
  ResendSignUpOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resendSignUpOtp(email: email);
}
