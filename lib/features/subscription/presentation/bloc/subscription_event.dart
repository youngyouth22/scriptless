import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';

/// Base sealed class for all SubscriptionBloc events.
sealed class SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionEvent();
}

/// Triggers checking current subscription status and active entitlements.
final class SubscriptionCheckRequested extends SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionCheckRequested();
}

/// Triggers fetching available offerings and packages (e.g. Monthly, Yearly).
final class SubscriptionOfferingsRequested extends SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionOfferingsRequested();
}

/// Triggers purchasing the selected [package].
final class SubscriptionPurchaseRequested extends SubscriptionEvent {
  /// Creates a [SubscriptionPurchaseRequested] event.
  const SubscriptionPurchaseRequested(this.package);

  /// The target package to purchase.
  final SubscriptionPackage package;
}

/// Triggers restoring previous purchases.
final class SubscriptionRestoreRequested extends SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionRestoreRequested();
}

/// Triggers unconditional presentation of the RevenueCat Paywall UI.
final class SubscriptionPaywallRequested extends SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionPaywallRequested();
}

/// Triggers presentation of the RevenueCat Paywall only if user lacks
/// entitlement.
final class SubscriptionPaywallIfNeededRequested extends SubscriptionEvent {
  /// Creates a [SubscriptionPaywallIfNeededRequested] event.
  const SubscriptionPaywallIfNeededRequested({this.requiredEntitlementId});

  /// Optional specific entitlement ID to verify.
  final String? requiredEntitlementId;
}

/// Triggers opening the RevenueCat Customer Center.
final class SubscriptionCustomerCenterRequested extends SubscriptionEvent {
  /// Default const constructor.
  const SubscriptionCustomerCenterRequested();
}

/// Synchronizes RevenueCat user identity when auth state changes.
final class SubscriptionUserChanged extends SubscriptionEvent {
  /// Creates a [SubscriptionUserChanged] event.
  const SubscriptionUserChanged(this.userId);

  /// The authenticated user ID, or null if logged out.
  final String? userId;
}

/// Internal event fired when customer info updates via stream.
final class SubscriptionStatusUpdated extends SubscriptionEvent {
  /// Creates a [SubscriptionStatusUpdated] event.
  const SubscriptionStatusUpdated(this.status);

  /// The updated subscription status.
  final SubscriptionStatus status;
}
