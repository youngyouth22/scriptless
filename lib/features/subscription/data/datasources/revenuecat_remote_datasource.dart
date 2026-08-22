import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Data source interface for low-level RevenueCat SDK operations.
abstract class RevenueCatRemoteDataSource {
  /// Initializes the RevenueCat SDK with the provided [apiKey]
  /// and optional [appUserId].
  Future<void> initialize(String apiKey, {String? appUserId});

  /// Retrieves the latest customer info from RevenueCat.
  Future<CustomerInfo> getCustomerInfo();

  /// Stream emitting real-time customer info updates.
  Stream<CustomerInfo> get customerInfoStream;

  /// Retrieves available offerings and packages from RevenueCat.
  Future<Offerings> getOfferings();

  /// Executes a purchase for the specified [package].
  Future<CustomerInfo> purchasePackage(Package package);

  /// Restores previous in-app purchases.
  Future<CustomerInfo> restorePurchases();

  /// Associates the current device with an authenticated [userId].
  Future<CustomerInfo> logIn(String userId);

  /// Resets user identity upon sign out.
  Future<CustomerInfo> logOut();

  /// Unconditionally presents the RevenueCat native paywall.
  Future<PaywallResult> presentPaywall({Offering? offering});

  /// Presents paywall only if user lacks the [requiredEntitlementIdentifier].
  Future<PaywallResult> presentPaywallIfNeeded(
    String requiredEntitlementIdentifier, {
    Offering? offering,
  });

  /// Presents the RevenueCat self-service Customer Center.
  Future<void> presentCustomerCenter();
}

/// Production implementation using `purchases_flutter` and
/// `purchases_ui_flutter`.
class RevenueCatRemoteDataSourceImpl implements RevenueCatRemoteDataSource {
  /// Creates a [RevenueCatRemoteDataSourceImpl].
  RevenueCatRemoteDataSourceImpl({
    StreamController<CustomerInfo>? customerInfoStreamController,
  }) : _customerInfoController =
           customerInfoStreamController ??
           StreamController<CustomerInfo>.broadcast() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }

  final StreamController<CustomerInfo> _customerInfoController;

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(customerInfo);
    }
  }

  @override
  Future<void> initialize(String apiKey, {String? appUserId}) async {
    final configuration = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(configuration);
  }

  @override
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  @override
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  @override
  Future<Offerings> getOfferings() => Purchases.getOfferings();

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final purchaseResult = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    return purchaseResult.customerInfo;
  }

  @override
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  @override
  Future<CustomerInfo> logIn(String userId) async {
    final result = await Purchases.logIn(userId);
    return result.customerInfo;
  }

  @override
  Future<CustomerInfo> logOut() => Purchases.logOut();

  @override
  Future<PaywallResult> presentPaywall({Offering? offering}) {
    return RevenueCatUI.presentPaywall(
      offering: offering,
    );
  }

  @override
  Future<PaywallResult> presentPaywallIfNeeded(
    String requiredEntitlementIdentifier, {
    Offering? offering,
  }) {
    return RevenueCatUI.presentPaywallIfNeeded(
      requiredEntitlementIdentifier,
      offering: offering,
    );
  }

  @override
  Future<void> presentCustomerCenter() {
    return RevenueCatUI.presentCustomerCenter();
  }
}
