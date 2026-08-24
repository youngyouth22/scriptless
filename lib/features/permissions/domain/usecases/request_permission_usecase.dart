import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';

/// Use case to prompt the user for a specific system permission.
class RequestPermissionUseCase
    implements UseCase<AppPermissionStatus, AppPermissionType> {
  /// Creates a [RequestPermissionUseCase].
  const RequestPermissionUseCase(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Either<Failure, AppPermissionStatus>> call(
    AppPermissionType params,
  ) {
    return _repository.requestPermission(params);
  }
}
