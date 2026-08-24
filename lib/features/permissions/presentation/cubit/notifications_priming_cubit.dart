// Cubit constructors must call super() in the initializer list.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/usecases/check_permission_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/open_app_settings_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/request_permission_usecase.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_state.dart';

/// Cubit managing state and interactions for the notifications priming screen.
class NotificationsPrimingCubit extends Cubit<NotificationsPrimingState> {
  /// Creates a [NotificationsPrimingCubit].
  NotificationsPrimingCubit({
    required CheckPermissionUseCase checkPermission,
    required RequestPermissionUseCase requestPermission,
    required OpenAppSettingsUseCase openAppSettings,
  })  : _checkPermission = checkPermission,
        _requestPermission = requestPermission,
        _openAppSettings = openAppSettings,
        super(const NotificationsPrimingInitial());

  final CheckPermissionUseCase _checkPermission;
  final RequestPermissionUseCase _requestPermission;
  final OpenAppSettingsUseCase _openAppSettings;

  /// Checks the current status of notification permissions.
  Future<void> checkStatus() async {
    final result = await _checkPermission(AppPermissionType.notification);
    result.fold(
      (failure) => _safeEmit(NotificationsPrimingFailure(failure)),
      (status) {
        if (status.isGranted) {
          _safeEmit(const NotificationsPrimingGranted());
        } else if (status.isPermanentlyDenied) {
          _safeEmit(const NotificationsPrimingPermanentlyDenied());
        } else {
          _safeEmit(NotificationsPrimingInitial(status: status));
        }
      },
    );
  }

  /// Prompts the user to grant notification permissions.
  Future<void> requestNotificationPermission() async {
    _safeEmit(const NotificationsPrimingRequesting());
    final result = await _requestPermission(AppPermissionType.notification);
    result.fold(
      (failure) => _safeEmit(NotificationsPrimingFailure(failure)),
      (status) {
        switch (status) {
          case AppPermissionStatus.granted:
          case AppPermissionStatus.limited:
          case AppPermissionStatus.provisional:
            _safeEmit(const NotificationsPrimingGranted());
          case AppPermissionStatus.denied:
            _safeEmit(const NotificationsPrimingDenied());
          case AppPermissionStatus.permanentlyDenied:
            _safeEmit(const NotificationsPrimingPermanentlyDenied());
          case AppPermissionStatus.restricted:
          case AppPermissionStatus.unknown:
            _safeEmit(const NotificationsPrimingDenied());
        }
      },
    );
  }

  /// Opens the device app settings screen.
  Future<void> openSettings() async {
    final result = await _openAppSettings(const NoParams());
    result.fold(
      (failure) => _safeEmit(NotificationsPrimingFailure(failure)),
      (_) {},
    );
  }

  /// Skips the priming screen without requesting.
  void skip() {
    _safeEmit(const NotificationsPrimingSkipped());
  }

  void _safeEmit(NotificationsPrimingState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
