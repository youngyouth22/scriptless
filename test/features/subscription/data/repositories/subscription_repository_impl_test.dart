import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:scriptless/core/constants/subscription_constants.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/subscription/data/datasources/revenuecat_remote_datasource.dart';
import 'package:scriptless/features/subscription/data/repositories/subscription_repository_impl.dart';

class MockRevenueCatRemoteDataSource extends Mock
    implements RevenueCatRemoteDataSource {}

class FakePackage extends Fake implements Package {
  @override
  String get identifier => r'$rc_monthly';
}

void main() {
  late MockRevenueCatRemoteDataSource mockDataSource;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakePackage());
  });

  setUp(() {
    mockDataSource = MockRevenueCatRemoteDataSource();
    repository = SubscriptionRepositoryImpl(mockDataSource);
  });

  group('getSubscriptionStatus', () {
    test('returns SubscriptionFailure on generic Exception', () async {
      when(() => mockDataSource.getCustomerInfo())
          .thenThrow(Exception('RevenueCat not initialized'));

      final result = await repository.getSubscriptionStatus();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<SubscriptionFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('maps PlatformException with purchaseCancelledError', () async {
      when(() => mockDataSource.getCustomerInfo()).thenThrow(
        PlatformException(
          code: '1',
          message: 'Purchase was cancelled',
          details: const <String, dynamic>{
            'readableErrorCode': 'PurchaseCancelledError',
          },
        ),
      );

      final result = await repository.getSubscriptionStatus();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<PurchaseCancelledFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('logIn and logOut', () {
    test('logIn returns unit on success', () async {
      final customerInfo = CustomerInfo.fromJson(const <String, dynamic>{
        'entitlements': {
          'all': <String, dynamic>{},
          'active': <String, dynamic>{},
        },
        'allPurchasedProductIdentifiers': <dynamic>[],
        'activeSubscriptions': <dynamic>[],
        'allExpirationDates': <String, dynamic>{},
        'allPurchaseDates': <String, dynamic>{},
        'nonSubscriptionTransactions': <dynamic>[],
        'firstSeen': '2026-01-01T00:00:00Z',
        'originalAppUserId': 'user-123',
        'requestDate': '2026-01-01T00:00:00Z',
        'originalApplicationVersion': '1.0',
        'schemaVersion': 3,
      });

      when(() => mockDataSource.logIn('user-123'))
          .thenAnswer((_) async => customerInfo);

      final result = await repository.logIn('user-123');

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockDataSource.logIn('user-123')).called(1);
    });

    test('logOut returns unit on success', () async {
      final customerInfo = CustomerInfo.fromJson(const <String, dynamic>{
        'entitlements': {
          'all': <String, dynamic>{},
          'active': <String, dynamic>{},
        },
        'allPurchasedProductIdentifiers': <dynamic>[],
        'activeSubscriptions': <dynamic>[],
        'allExpirationDates': <String, dynamic>{},
        'allPurchaseDates': <String, dynamic>{},
        'nonSubscriptionTransactions': <dynamic>[],
        'firstSeen': '2026-01-01T00:00:00Z',
        'originalAppUserId': 'anon-123',
        'requestDate': '2026-01-01T00:00:00Z',
        'originalApplicationVersion': '1.0',
        'schemaVersion': 3,
      });

      when(() => mockDataSource.logOut()).thenAnswer((_) async => customerInfo);

      final result = await repository.logOut();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockDataSource.logOut()).called(1);
    });
  });

  group('presentPaywallIfNeeded', () {
    test('returns true when PaywallResult is purchased', () async {
      when(
        () => mockDataSource.presentPaywallIfNeeded(
          SubscriptionConstants.proEntitlementId,
        ),
      ).thenAnswer((_) async => PaywallResult.purchased);

      final result = await repository.presentPaywallIfNeeded();

      expect(result, const Right<Failure, bool>(true));
    });

    test(
        'returns true when PaywallResult is notPresented (already pro)',
        () async {
      when(
        () => mockDataSource.presentPaywallIfNeeded(
          SubscriptionConstants.proEntitlementId,
        ),
      ).thenAnswer((_) async => PaywallResult.notPresented);

      final result = await repository.presentPaywallIfNeeded();

      expect(result, const Right<Failure, bool>(true));
    });

    test('returns false when PaywallResult is cancelled', () async {
      when(
        () => mockDataSource.presentPaywallIfNeeded(
          SubscriptionConstants.proEntitlementId,
        ),
      ).thenAnswer((_) async => PaywallResult.cancelled);

      final result = await repository.presentPaywallIfNeeded();

      expect(result, const Right<Failure, bool>(false));
    });

    test('returns SubscriptionFailure when PaywallResult is error', () async {
      when(
        () => mockDataSource.presentPaywallIfNeeded(
          SubscriptionConstants.proEntitlementId,
        ),
      ).thenAnswer((_) async => PaywallResult.error);

      final result = await repository.presentPaywallIfNeeded();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<SubscriptionFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('presentPaywall', () {
    test('returns unit when paywall presents without error', () async {
      when(() => mockDataSource.presentPaywall())
          .thenAnswer((_) async => PaywallResult.purchased);

      final result = await repository.presentPaywall();

      expect(result, const Right<Failure, Unit>(unit));
    });

    test('returns SubscriptionFailure when paywall returns error', () async {
      when(() => mockDataSource.presentPaywall())
          .thenAnswer((_) async => PaywallResult.error);

      final result = await repository.presentPaywall();

      expect(result.isLeft(), isTrue);
    });
  });

  group('presentCustomerCenter', () {
    test('returns unit when customer center succeeds', () async {
      when(() => mockDataSource.presentCustomerCenter())
          .thenAnswer((_) async {});

      final result = await repository.presentCustomerCenter();

      expect(result, const Right<Failure, Unit>(unit));
    });

    test('returns Failure when customer center throws', () async {
      when(() => mockDataSource.presentCustomerCenter())
          .thenThrow(Exception('Customer center failed'));

      final result = await repository.presentCustomerCenter();

      expect(result.isLeft(), isTrue);
    });
  });
}
