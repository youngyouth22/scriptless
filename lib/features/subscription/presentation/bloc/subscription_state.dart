import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';

/// Base sealed class for all SubscriptionBloc states.
@immutable
sealed class SubscriptionState {
  /// Default const constructor.
  const SubscriptionState();

  /// Helper getter for current subscription status across states.
  SubscriptionStatus get status => SubscriptionStatus.free();

  /// Helper getter for current offerings across states.
  List<SubscriptionPackage> get offerings => const <SubscriptionPackage>[];

  /// Whether user has active pro entitlement.
  bool get isPro => status.isPro;
}

/// Initial uninitialized state.
@immutable
final class SubscriptionInitial extends SubscriptionState {
  /// Default const constructor.
  const SubscriptionInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state during initial bootstrap / refresh.
@immutable
final class SubscriptionLoading extends SubscriptionState {
  /// Default const constructor.
  const SubscriptionLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State when subscription status and available offerings have been fetched.
@immutable
final class SubscriptionLoaded extends SubscriptionState {
  /// Creates a [SubscriptionLoaded] state.
  const SubscriptionLoaded({
    required this.currentStatus,
    this.availableOfferings = const <SubscriptionPackage>[],
  });

  /// The active subscription status.
  final SubscriptionStatus currentStatus;

  /// The list of available subscription packages.
  final List<SubscriptionPackage> availableOfferings;

  @override
  SubscriptionStatus get status => currentStatus;

  @override
  List<SubscriptionPackage> get offerings => availableOfferings;

  /// Returns a copy of [SubscriptionLoaded] with modified fields.
  SubscriptionLoaded copyWith({
    SubscriptionStatus? currentStatus,
    List<SubscriptionPackage>? availableOfferings,
  }) {
    return SubscriptionLoaded(
      currentStatus: currentStatus ?? this.currentStatus,
      availableOfferings: availableOfferings ?? this.availableOfferings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionLoaded &&
          runtimeType == other.runtimeType &&
          currentStatus == other.currentStatus &&
          availableOfferings.length == other.availableOfferings.length;

  @override
  int get hashCode => currentStatus.hashCode ^ availableOfferings.hashCode;
}

/// State emitted while a purchase or restore action is actively running.
@immutable
final class SubscriptionActionInProgress extends SubscriptionState {
  /// Creates a [SubscriptionActionInProgress] state.
  const SubscriptionActionInProgress({
    required this.currentStatus,
    this.availableOfferings = const <SubscriptionPackage>[],
  });

  /// The active subscription status.
  final SubscriptionStatus currentStatus;

  /// The list of available subscription packages.
  final List<SubscriptionPackage> availableOfferings;

  @override
  SubscriptionStatus get status => currentStatus;

  @override
  List<SubscriptionPackage> get offerings => availableOfferings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionActionInProgress &&
          runtimeType == other.runtimeType &&
          currentStatus == other.currentStatus &&
          availableOfferings.length == other.availableOfferings.length;

  @override
  int get hashCode => currentStatus.hashCode ^ availableOfferings.hashCode;
}

/// State emitted upon successful purchase or restore action.
@immutable
final class SubscriptionActionSuccess extends SubscriptionState {
  /// Creates a [SubscriptionActionSuccess] state.
  const SubscriptionActionSuccess({
    required this.message,
    required this.currentStatus,
    this.availableOfferings = const <SubscriptionPackage>[],
  });

  /// Success message for feedback.
  final String message;

  /// The active subscription status.
  final SubscriptionStatus currentStatus;

  /// The list of available subscription packages.
  final List<SubscriptionPackage> availableOfferings;

  @override
  SubscriptionStatus get status => currentStatus;

  @override
  List<SubscriptionPackage> get offerings => availableOfferings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionActionSuccess &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          currentStatus == other.currentStatus &&
          availableOfferings.length == other.availableOfferings.length;

  @override
  int get hashCode =>
      message.hashCode ^
      currentStatus.hashCode ^
      availableOfferings.hashCode;
}

/// Error state emitted when a subscription operation encounters a failure.
@immutable
final class SubscriptionFailureState extends SubscriptionState {
  /// Creates a [SubscriptionFailureState].
  const SubscriptionFailureState({
    required this.failure,
    this.currentStatus,
    this.availableOfferings = const <SubscriptionPackage>[],
  });

  /// The underlying failure object.
  final Failure failure;

  /// The subscription status before failure.
  final SubscriptionStatus? currentStatus;

  /// The available offerings before failure.
  final List<SubscriptionPackage> availableOfferings;

  @override
  SubscriptionStatus get status => currentStatus ?? SubscriptionStatus.free();

  @override
  List<SubscriptionPackage> get offerings => availableOfferings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionFailureState &&
          runtimeType == other.runtimeType &&
          failure.message == other.failure.message &&
          currentStatus == other.currentStatus &&
          availableOfferings.length == other.availableOfferings.length;

  @override
  int get hashCode =>
      failure.hashCode ^
      (currentStatus?.hashCode ?? 0) ^
      availableOfferings.hashCode;
}
