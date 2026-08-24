import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Sends a password reset OTP code to the requested email.
class SendPasswordResetOtpUseCase implements UseCase<Unit, String> {
  /// Creates a [SendPasswordResetOtpUseCase].
  SendPasswordResetOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.sendPasswordResetOtp(email: email);
}
