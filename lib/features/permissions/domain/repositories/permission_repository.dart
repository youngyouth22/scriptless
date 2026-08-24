import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';

/// Repository interface for checking and requesting system permissions.
abstract class PermissionRepository {
  /// Checks the current status of the given [permission].
  Future<Either<Failure, AppPermissionStatus>> checkPermission(
    AppPermissionType permission,
  );

  /// Requests the given [permission] from the operating system.
  Future<Either<Failure, AppPermissionStatus>> requestPermission(
    AppPermissionType permission,
  );

  /// Opens the device settings page for this application.
  Future<Either<Failure, bool>> openAppSettings();
}
