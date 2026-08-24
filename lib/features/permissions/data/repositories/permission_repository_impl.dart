import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/data/datasources/permission_local_datasource.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';

/// Implementation of [PermissionRepository] backed by
/// [PermissionLocalDataSource].
class PermissionRepositoryImpl implements PermissionRepository {
  /// Creates a [PermissionRepositoryImpl].
  const PermissionRepositoryImpl(this._localDataSource);

  final PermissionLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AppPermissionStatus>> checkPermission(
    AppPermissionType permission,
  ) async {
    try {
      final status = await _localDataSource.checkPermission(permission);
      return Right(_mapPermissionStatus(status));
    } on Exception catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppPermissionStatus>> requestPermission(
    AppPermissionType permission,
  ) async {
    try {
      final status = await _localDataSource.requestPermission(permission);
      return Right(_mapPermissionStatus(status));
    } on Exception catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> openAppSettings() async {
    try {
      final opened = await _localDataSource.openAppSettings();
      return Right(opened);
    } on Exception catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  AppPermissionStatus _mapPermissionStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return AppPermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return AppPermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return AppPermissionStatus.limited;
      case ph.PermissionStatus.provisional:
        return AppPermissionStatus.provisional;
    }
  }
}
