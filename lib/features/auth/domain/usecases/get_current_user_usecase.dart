import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Retrieve the currently authenticated user (one-shot).
///
/// Returns [AppUser] if there is an active session, or `null` if not.
class GetCurrentUserUseCase implements UseCase<AppUser?, NoParams> {
  /// Creates a [GetCurrentUserUseCase].
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
