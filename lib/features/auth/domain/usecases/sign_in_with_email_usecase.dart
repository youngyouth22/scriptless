import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Sign in an existing user with email & password.
class SignInWithEmailUseCase implements UseCase<AppUser, SignInParams> {
  /// Creates a [SignInWithEmailUseCase].
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) =>
      _repository.signInWithEmail(
        email: params.email,
        password: params.password,
      );
}

/// Parameters for [SignInWithEmailUseCase].
class SignInParams {
  /// Creates [SignInParams].
  const SignInParams({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;
}
