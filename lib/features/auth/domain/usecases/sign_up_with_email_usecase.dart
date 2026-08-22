import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Sign up a new user with email & password credentials.
class SignUpWithEmailUseCase implements UseCase<AppUser, SignUpParams> {
  /// Creates a [SignUpWithEmailUseCase].
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) =>
      _repository.signUpWithEmail(
        email: params.email,
        password: params.password,
      );
}

/// Parameters for [SignUpWithEmailUseCase].
class SignUpParams {
  /// Creates [SignUpParams].
  const SignUpParams({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's chosen password.
  final String password;
}
