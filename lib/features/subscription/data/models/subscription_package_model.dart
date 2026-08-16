import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';

/// Extension / Mapper for converting RevenueCat [Package] to domain
/// [SubscriptionPackage].
extension PackageX on Package {
  /// Converts [Package] to [SubscriptionPackage].
  SubscriptionPackage toDomain() {
    return SubscriptionPackage(
      identifier: identifier,
      offeringIdentifier: presentedOfferingContext.offeringIdentifier,
      title: storeProduct.title,
      description: storeProduct.description,
      priceString: storeProduct.priceString,
      price: storeProduct.price,
      currencyCode: storeProduct.currencyCode,
      packageType: packageType.toDomain(),
    );
  }
}

/// Extension / Mapper for converting [PackageType] to domain
/// [SubscriptionPackageType].
extension PackageTypeX on PackageType {
  /// Maps RevenueCat [PackageType] to domain [SubscriptionPackageType].
  SubscriptionPackageType toDomain() {
    switch (this) {
      case PackageType.annual:
        return SubscriptionPackageType.annual;
      case PackageType.monthly:
        return SubscriptionPackageType.monthly;
      case PackageType.weekly:
        return SubscriptionPackageType.weekly;
      case PackageType.lifetime:
        return SubscriptionPackageType.lifetime;
      case PackageType.sixMonth:
        return SubscriptionPackageType.sixMonth;
      case PackageType.threeMonth:
        return SubscriptionPackageType.threeMonth;
      case PackageType.twoMonth:
        return SubscriptionPackageType.twoMonth;
      case PackageType.custom:
        return SubscriptionPackageType.custom;
      case PackageType.unknown:
        return SubscriptionPackageType.unknown;
    }
  }
}
