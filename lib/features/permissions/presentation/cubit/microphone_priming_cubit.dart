// Cubit constructors must call super() in the initializer list.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_type.dart';
import 'package:scriptless/features/permissions/domain/usecases/check_permission_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/open_app_settings_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/request_permission_usecase.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_state.dart';

/// Cubit managing state and interactions for the microphone priming screen.
class MicrophonePrimingCubit extends Cubit<MicrophonePrimingState> {
  /// Creates a [MicrophonePrimingCubit].
  MicrophonePrimingCubit({
    required CheckPermissionUseCase checkPermission,
    required RequestPermissionUseCase requestPermission,
    required OpenAppSettingsUseCase openAppSettings,
  })  : _checkPermission = checkPermission,
        _requestPermission = requestPermission,
        _openAppSettings = openAppSettings,
        super(const MicrophonePrimingInitial());

  final CheckPermissionUseCase _checkPermission;
  final RequestPermissionUseCase _requestPermission;
  final OpenAppSettingsUseCase _openAppSettings;

  /// Checks the current status of the microphone permission.
  Future<void> checkStatus() async {
    final result = await _checkPermission(AppPermissionType.microphone);
    result.fold(
      (failure) => _safeEmit(MicrophonePrimingFailure(failure)),
      (status) {
        if (status.isGranted) {
          _safeEmit(const MicrophonePrimingGranted());
        } else if (status.isPermanentlyDenied) {
          _safeEmit(const MicrophonePrimingPermanentlyDenied());
        } else {
          _safeEmit(MicrophonePrimingInitial(status: status));
        }
      },
    );
  }

  /// Prompts the user to grant microphone permission.
  Future<void> requestMicrophonePermission() async {
    _safeEmit(const MicrophonePrimingRequesting());
    final result = await _requestPermission(AppPermissionType.microphone);
    result.fold(
      (failure) => _safeEmit(MicrophonePrimingFailure(failure)),
      (status) {
        switch (status) {
          case AppPermissionStatus.granted:
          case AppPermissionStatus.limited:
          case AppPermissionStatus.provisional:
            _safeEmit(const MicrophonePrimingGranted());
          case AppPermissionStatus.denied:
            _safeEmit(const MicrophonePrimingDenied());
          case AppPermissionStatus.permanentlyDenied:
            _safeEmit(const MicrophonePrimingPermanentlyDenied());
          case AppPermissionStatus.restricted:
          case AppPermissionStatus.unknown:
            _safeEmit(const MicrophonePrimingDenied());
        }
      },
    );
  }

  /// Opens the device app settings screen.
  Future<void> openSettings() async {
    final result = await _openAppSettings(const NoParams());
    result.fold(
      (failure) => _safeEmit(MicrophonePrimingFailure(failure)),
      (_) {},
    );
  }

  /// Skips the priming screen without requesting.
  void skip() {
    _safeEmit(const MicrophonePrimingSkipped());
  }

  void _safeEmit(MicrophonePrimingState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
