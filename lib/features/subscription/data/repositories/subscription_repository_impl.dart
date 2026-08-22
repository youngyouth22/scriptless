import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:scriptless/core/constants/subscription_constants.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/subscription/data/datasources/revenuecat_remote_datasource.dart';
import 'package:scriptless/features/subscription/data/models/subscription_package_model.dart';
import 'package:scriptless/features/subscription/data/models/subscription_status_model.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';

/// Concrete implementation of [SubscriptionRepository] backed by RevenueCat.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  /// Creates a [SubscriptionRepositoryImpl].
  const SubscriptionRepositoryImpl(this._remoteDataSource);

  final RevenueCatRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final customerInfo = await _remoteDataSource.getCustomerInfo();
      return Right(customerInfo.toDomain());
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, SubscriptionStatus>> watchSubscriptionStatus() {
    return _remoteDataSource.customerInfoStream
        .map<Either<Failure, SubscriptionStatus>>(
          (customerInfo) => Right(customerInfo.toDomain()),
        )
        .handleError(
          (dynamic error) => Left<Failure, SubscriptionStatus>(
            error is PlatformException
                ? _mapPlatformException(error)
                : SubscriptionFailure(error.toString()),
          ),
        );
  }

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> getOfferings() async {
    try {
      final offerings = await _remoteDataSource.getOfferings();
      final currentOffering = offerings.current;

      if (currentOffering == null) {
        return const Right(<SubscriptionPackage>[]);
      }

      final packages = currentOffering.availablePackages
          .map((package) => package.toDomain())
          .toList();

      return Right(packages);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async {
    try {
      final offerings = await _remoteDataSource.getOfferings();
      final currentOffering = offerings.current;

      if (currentOffering == null) {
        return const Left(
          SubscriptionFailure('No current offerings available to purchase.'),
        );
      }

      final rcPackage = currentOffering.availablePackages.firstWhere(
        (p) => p.identifier == package.identifier,
        orElse: () => throw Exception(
          'Package ${package.identifier} not found in current offering.',
        ),
      );

      final customerInfo = await _remoteDataSource.purchasePackage(rcPackage);
      return Right(customerInfo.toDomain());
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async {
    try {
      final customerInfo = await _remoteDataSource.restorePurchases();
      return Right(customerInfo.toDomain());
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logIn(String userId) async {
    try {
      await _remoteDataSource.logIn(userId);
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logOut() async {
    try {
      await _remoteDataSource.logOut();
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> presentPaywallIfNeeded({
    String? requiredEntitlementId,
  }) async {
    try {
      final entitlement =
          requiredEntitlementId ?? SubscriptionConstants.proEntitlementId;
      final result = await _remoteDataSource.presentPaywallIfNeeded(
        entitlement,
      );

      switch (result) {
        case PaywallResult.purchased:
        case PaywallResult.restored:
          return const Right(true);
        case PaywallResult.notPresented:
          // User already had the entitlement
          return const Right(true);
        case PaywallResult.cancelled:
          return const Right(false);
        case PaywallResult.error:
          return const Left(
            SubscriptionFailure(
              'An error occurred during paywall presentation.',
            ),
          );
      }
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> presentPaywall() async {
    try {
      final result = await _remoteDataSource.presentPaywall();
      if (result == PaywallResult.error) {
        return const Left(
          SubscriptionFailure('An error occurred during paywall presentation.'),
        );
      }
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> presentCustomerCenter() async {
    try {
      await _remoteDataSource.presentCustomerCenter();
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(_mapPlatformException(e));
    } on Exception catch (e) {
      return Left(SubscriptionFailure(e.toString()));
    }
  }

  Failure _mapPlatformException(PlatformException exception) {
    final errorCode = PurchasesErrorHelper.getErrorCode(exception);
    if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
      return const PurchaseCancelledFailure();
    }
    return SubscriptionFailure(
      exception.message ?? 'Unknown subscription error',
    );
  }
}
