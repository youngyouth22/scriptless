import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';

/// Use case to open the application system settings page on the device.
class OpenAppSettingsUseCase implements UseCase<bool, NoParams> {
  /// Creates an [OpenAppSettingsUseCase].
  const OpenAppSettingsUseCase(this._repository);

  final PermissionRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.openAppSettings();
  }
}
