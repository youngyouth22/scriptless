import 'package:flutter/foundation.dart';

/// Domain entity representing a customer's subscription and entitlement status.
@immutable
class SubscriptionStatus {
  /// Creates a [SubscriptionStatus].
  const SubscriptionStatus({
    required this.isPro,
    required this.activeEntitlements,
    required this.allPurchasedProductIdentifiers,
    this.originalAppUserId = '',
    this.latestExpirationDate,
    this.willRenew = false,
  });

  /// Factory for an unauthenticated / default free user status.
  factory SubscriptionStatus.free() => const SubscriptionStatus(
        isPro: false,
        activeEntitlements: <String>[],
        allPurchasedProductIdentifiers: <String>[],
      );

  /// Whether the user has an active "Scriptless Pro" entitlement.
  final bool isPro;

  /// List of active entitlement IDs (e.g. `['Scriptless Pro']`).
  final List<String> activeEntitlements;

  /// List of all purchased product IDs.
  final List<String> allPurchasedProductIdentifiers;

  /// RevenueCat original app user ID.
  final String originalAppUserId;

  /// The latest expiration date if subscription is time-limited.
  final DateTime? latestExpirationDate;

  /// Whether the subscription is set to automatically renew.
  final bool willRenew;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatus &&
          runtimeType == other.runtimeType &&
          isPro == other.isPro &&
          originalAppUserId == other.originalAppUserId &&
          willRenew == other.willRenew;

  @override
  int get hashCode =>
      isPro.hashCode ^ originalAppUserId.hashCode ^ willRenew.hashCode;
}
