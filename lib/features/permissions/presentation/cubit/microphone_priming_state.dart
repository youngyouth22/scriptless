import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';

/// Base sealed class for all states emitted by the microphone priming cubit.
@immutable
sealed class MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingState();
}

/// Initial state when landing on the microphone priming screen.
@immutable
final class MicrophonePrimingInitial extends MicrophonePrimingState {
  /// Creates a [MicrophonePrimingInitial] state.
  const MicrophonePrimingInitial({
    this.status = AppPermissionStatus.unknown,
  });

  /// The known permission status before requesting.
  final AppPermissionStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingInitial &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;
}

/// State emitted while the OS permission dialog is active or resolving.
@immutable
final class MicrophonePrimingRequesting extends MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingRequesting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingRequesting && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user has granted microphone permission.
@immutable
final class MicrophonePrimingGranted extends MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingGranted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingGranted && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user denied microphone permission.
@immutable
final class MicrophonePrimingDenied extends MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingDenied();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingDenied && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when microphone permission is permanently denied.
@immutable
final class MicrophonePrimingPermanentlyDenied extends MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingPermanentlyDenied();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingPermanentlyDenied &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user elects to skip microphone priming.
@immutable
final class MicrophonePrimingSkipped extends MicrophonePrimingState {
  /// Default const constructor.
  const MicrophonePrimingSkipped();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingSkipped && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when an unexpected error occurred during permission check/request.
@immutable
final class MicrophonePrimingFailure extends MicrophonePrimingState {
  /// Creates a [MicrophonePrimingFailure] state.
  const MicrophonePrimingFailure(this.failure);

  /// The underlying failure.
  final Failure failure;

  /// Convenience getter for the error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicrophonePrimingFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
