import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scriptless/core/constants/subscription_constants.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';

/// Extension / Mapper for converting [CustomerInfo] to domain [SubscriptionStatus].
extension CustomerInfoX on CustomerInfo {
  /// Converts [CustomerInfo] to [SubscriptionStatus].
  SubscriptionStatus toDomain({
    String proEntitlementId = SubscriptionConstants.proEntitlementId,
  }) {
    final active = entitlements.active;
    final isProActive = active.containsKey(proEntitlementId);
    final proEntitlement = active[proEntitlementId];

    DateTime? expiration;
    if (proEntitlement?.expirationDate != null) {
      expiration = DateTime.tryParse(proEntitlement!.expirationDate!);
    } else if (latestExpirationDate != null) {
      expiration = DateTime.tryParse(latestExpirationDate!);
    }

    return SubscriptionStatus(
      isPro: isProActive,
      activeEntitlements: active.keys.toList(),
      allPurchasedProductIdentifiers: allPurchasedProductIdentifiers,
      originalAppUserId: originalAppUserId,
      latestExpirationDate: expiration,
      willRenew: proEntitlement?.willRenew ?? false,
    );
  }
}
