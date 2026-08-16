import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:scriptless/features/subscription/data/models/subscription_package_model.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';

void main() {
  group('PackageTypeX', () {
    test('maps all PackageTypes correctly', () {
      expect(
        PackageType.annual.toDomain(),
        SubscriptionPackageType.annual,
      );
      expect(
        PackageType.monthly.toDomain(),
        SubscriptionPackageType.monthly,
      );
      expect(
        PackageType.weekly.toDomain(),
        SubscriptionPackageType.weekly,
      );
      expect(
        PackageType.lifetime.toDomain(),
        SubscriptionPackageType.lifetime,
      );
      expect(
        PackageType.sixMonth.toDomain(),
        SubscriptionPackageType.sixMonth,
      );
      expect(
        PackageType.threeMonth.toDomain(),
        SubscriptionPackageType.threeMonth,
      );
      expect(
        PackageType.twoMonth.toDomain(),
        SubscriptionPackageType.twoMonth,
      );
      expect(
        PackageType.custom.toDomain(),
        SubscriptionPackageType.custom,
      );
      expect(
        PackageType.unknown.toDomain(),
        SubscriptionPackageType.unknown,
      );
    });
  });
}
