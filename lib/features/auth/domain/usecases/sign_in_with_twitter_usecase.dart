import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Initiates X (Twitter) OAuth sign-in flow.
class SignInWithTwitterUseCase implements UseCase<Unit, NoParams> {
  /// Creates a [SignInWithTwitterUseCase].
  const SignInWithTwitterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.signInWithTwitter();
}
