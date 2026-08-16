import 'package:flutter/foundation.dart';

/// Represents a purchasable subscription package (e.g. Monthly, Annual).
@immutable
class SubscriptionPackage {
  /// Creates a [SubscriptionPackage].
  const SubscriptionPackage({
    required this.identifier,
    required this.offeringIdentifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    this.packageType = SubscriptionPackageType.custom,
  });

  /// The unique identifier of the package in RevenueCat.
  final String identifier;

  /// The offering identifier this package belongs to.
  final String offeringIdentifier;

  /// Display title of the product.
  final String title;

  /// Product description.
  final String description;

  /// Formatted localized price (e.g. "$9.99").
  final String priceString;

  /// Raw numeric price.
  final double price;

  /// ISO 4217 currency code (e.g. "USD").
  final String currencyCode;

  /// The package type (annual, monthly, weekly, etc.).
  final SubscriptionPackageType packageType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPackage &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          offeringIdentifier == other.offeringIdentifier &&
          priceString == other.priceString;

  @override
  int get hashCode =>
      identifier.hashCode ^
      offeringIdentifier.hashCode ^
      priceString.hashCode;
}

/// Package duration / type classification.
enum SubscriptionPackageType {
  /// Unknown duration.
  unknown,

  /// Custom duration.
  custom,

  /// Lifetime purchase.
  lifetime,

  /// Annual / Yearly subscription.
  annual,

  /// Six month subscription.
  sixMonth,

  /// Three month subscription.
  threeMonth,

  /// Two month subscription.
  twoMonth,

  /// Monthly subscription.
  monthly,

  /// Weekly subscription.
  weekly,
}
