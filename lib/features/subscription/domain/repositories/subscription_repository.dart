import 'package:dartz/dartz.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';

/// Contract for subscription operations and paywall management.
abstract class SubscriptionRepository {
  /// Fetches the current user's subscription and entitlement status.
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus();

  /// Watches real-time customer info changes.
  Stream<Either<Failure, SubscriptionStatus>> watchSubscriptionStatus();

  /// Fetches current offerings and purchasable packages.
  Future<Either<Failure, List<SubscriptionPackage>>> getOfferings();

  /// Purchases a selected [SubscriptionPackage].
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  );

  /// Restores previous purchases for the current user.
  Future<Either<Failure, SubscriptionStatus>> restorePurchases();

  /// Identifies the user in RevenueCat upon authentication.
  Future<Either<Failure, Unit>> logIn(String userId);

  /// Resets the user in RevenueCat upon sign out.
  Future<Either<Failure, Unit>> logOut();

  /// Presents the native RevenueCat Paywall UI if user lacks entitlement.
  ///
  /// Returns `true` if pro access was granted/unlocked, `false` otherwise.
  Future<Either<Failure, bool>> presentPaywallIfNeeded({
    String? requiredEntitlementId,
  });

  /// Unconditionally presents the native RevenueCat Paywall UI.
  Future<Either<Failure, Unit>> presentPaywall();

  /// Presents the RevenueCat Customer Center for subscription management.
  Future<Either<Failure, Unit>> presentCustomerCenter();
}
