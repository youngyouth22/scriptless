import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';

/// Updates the authenticated or recovery user's password.
class UpdatePasswordUseCase implements UseCase<Unit, String> {
  /// Creates an [UpdatePasswordUseCase].
  UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String newPassword) =>
      _repository.updatePassword(newPassword: newPassword);
}
