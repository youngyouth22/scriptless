import 'package:flutter/foundation.dart';

/// Base class for all domain-layer failures.
@immutable
abstract class Failure {
  /// Creates a [Failure] with a [message].
  const Failure(this.message);

  /// Human-readable description of the failure.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => runtimeType.hashCode ^ message.hashCode;

  @override
  String toString() => message;
}

/// Returned when a remote/Supabase operation fails.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure(super.message);
}

/// Returned when Supabase Auth raises an error.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure(super.message);
}

/// Returned when a local PowerSync/SQLite operation fails.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure(super.message);
}

/// Returned when the device has no network connectivity.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure(super.message);
}

/// Returned when user-provided data fails validation.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message);
}

/// Returned when a subscription or in-app purchase operation fails.
class SubscriptionFailure extends Failure {
  /// Creates a [SubscriptionFailure].
  const SubscriptionFailure(super.message);
}

/// Returned when the user cancels an in-app purchase flow.
class PurchaseCancelledFailure extends Failure {
  /// Creates a [PurchaseCancelledFailure].
  const PurchaseCancelledFailure([super.message = 'Purchase was cancelled.']);
}

/// Returned when an OS permission request or check fails.
class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure].
  const PermissionFailure([super.message = 'Permission request failed.']);
}
