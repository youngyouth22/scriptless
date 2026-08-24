import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';

/// Contract for local platform permission operations.
abstract class PermissionLocalDataSource {
  /// Queries the current [ph.PermissionStatus] for [type].
  Future<ph.PermissionStatus> checkPermission(AppPermissionType type);

  /// Requests permission from the OS for [type].
  Future<ph.PermissionStatus> requestPermission(AppPermissionType type);

  /// Opens the device settings page for this app.
  Future<bool> openAppSettings();
}

/// Implementation of [PermissionLocalDataSource] using [ph.Permission].
class PermissionLocalDataSourceImpl implements PermissionLocalDataSource {
  /// Default const constructor.
  const PermissionLocalDataSourceImpl();

  @override
  Future<ph.PermissionStatus> checkPermission(AppPermissionType type) {
    final permission = _mapToHandlerPermission(type);
    return permission.status;
  }

  @override
  Future<ph.PermissionStatus> requestPermission(AppPermissionType type) {
    final permission = _mapToHandlerPermission(type);
    return permission.request();
  }

  @override
  Future<bool> openAppSettings() => ph.openAppSettings();

  ph.Permission _mapToHandlerPermission(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.microphone:
        return ph.Permission.microphone;
      case AppPermissionType.notification:
        return ph.Permission.notification;
    }
  }
}
