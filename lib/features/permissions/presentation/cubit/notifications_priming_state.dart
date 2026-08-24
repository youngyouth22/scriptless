import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/permissions/domain/entities/app_permission_status.dart';

/// Base sealed class for all states emitted by the notifications priming cubit.
@immutable
sealed class NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingState();
}

/// Initial state when landing on the notifications priming screen.
@immutable
final class NotificationsPrimingInitial extends NotificationsPrimingState {
  /// Creates a [NotificationsPrimingInitial] state.
  const NotificationsPrimingInitial({
    this.status = AppPermissionStatus.unknown,
  });

  /// The known permission status before requesting.
  final AppPermissionStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingInitial &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;
}

/// State emitted while the OS permission dialog is active or resolving.
@immutable
final class NotificationsPrimingRequesting extends NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingRequesting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingRequesting &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user has granted notification permission.
@immutable
final class NotificationsPrimingGranted extends NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingGranted();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingGranted && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user denied notification permission.
@immutable
final class NotificationsPrimingDenied extends NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingDenied();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingDenied && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when notification permission is permanently denied.
@immutable
final class NotificationsPrimingPermanentlyDenied
    extends NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingPermanentlyDenied();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingPermanentlyDenied &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the user elects to skip notification priming.
@immutable
final class NotificationsPrimingSkipped extends NotificationsPrimingState {
  /// Default const constructor.
  const NotificationsPrimingSkipped();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingSkipped && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when an unexpected error occurred during permission check/request.
@immutable
final class NotificationsPrimingFailure extends NotificationsPrimingState {
  /// Creates a [NotificationsPrimingFailure] state.
  const NotificationsPrimingFailure(this.failure);

  /// The underlying failure.
  final Failure failure;

  /// Convenience getter for the error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsPrimingFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
