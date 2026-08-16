import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:scriptless/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_customer_center_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_paywall_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/sync_subscription_auth_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/watch_subscription_status_usecase.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository mockRepository;

  const tPackage = SubscriptionPackage(
    identifier: r'$rc_monthly',
    offeringIdentifier: 'default',
    title: 'Monthly Subscription',
    description: 'Monthly access to Scriptless Pro',
    priceString: r'$9.99',
    price: 9.99,
    currencyCode: 'USD',
    packageType: SubscriptionPackageType.monthly,
  );

  final tStatusPro = SubscriptionStatus(
    isPro: true,
    activeEntitlements: const <String>['Scriptless Pro'],
    allPurchasedProductIdentifiers: const <String>['monthly'],
    originalAppUserId: 'user-123',
    latestExpirationDate: DateTime(2027),
    willRenew: true,
  );

  final tStatusFree = SubscriptionStatus.free();

  setUp(() {
    mockRepository = MockSubscriptionRepository();
  });

  group('CheckProEntitlementUseCase', () {
    late CheckProEntitlementUseCase useCase;

    setUp(() {
      useCase = CheckProEntitlementUseCase(mockRepository);
    });

    test('should return true when user has pro entitlement', () async {
      when(() => mockRepository.getSubscriptionStatus())
          .thenAnswer((_) async => Right(tStatusPro));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockRepository.getSubscriptionStatus()).called(1);
    });

    test('should return false when user is free', () async {
      when(() => mockRepository.getSubscriptionStatus())
          .thenAnswer((_) async => Right(tStatusFree));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, bool>(false));
      verify(() => mockRepository.getSubscriptionStatus()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getSubscriptionStatus()).thenAnswer(
        (_) async => const Left(SubscriptionFailure('Network error')),
      );

      final result = await useCase(const NoParams());

      expect(
        result,
        const Left<Failure, bool>(SubscriptionFailure('Network error')),
      );
      verify(() => mockRepository.getSubscriptionStatus()).called(1);
    });
  });

  group('GetOfferingsUseCase', () {
    late GetOfferingsUseCase useCase;

    setUp(() {
      useCase = GetOfferingsUseCase(mockRepository);
    });

    test('should return list of packages from repository', () async {
      when(() => mockRepository.getOfferings()).thenAnswer(
        (_) async => const Right(<SubscriptionPackage>[tPackage]),
      );

      final result = await useCase(const NoParams());

      expect(
        result,
        const Right<Failure, List<SubscriptionPackage>>([tPackage]),
      );
      verify(() => mockRepository.getOfferings()).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getOfferings()).thenAnswer(
        (_) async =>
            const Left(SubscriptionFailure('Failed to load offerings')),
      );

      final result = await useCase(const NoParams());

      expect(
        result,
        const Left<Failure, List<SubscriptionPackage>>(
          SubscriptionFailure('Failed to load offerings'),
        ),
      );
      verify(() => mockRepository.getOfferings()).called(1);
    });
  });

  group('PurchaseSubscriptionUseCase', () {
    late PurchaseSubscriptionUseCase useCase;

    setUp(() {
      useCase = PurchaseSubscriptionUseCase(mockRepository);
    });

    test('should return updated SubscriptionStatus upon purchase', () async {
      when(() => mockRepository.purchasePackage(tPackage))
          .thenAnswer((_) async => Right(tStatusPro));

      final result = await useCase(tPackage);

      expect(result, Right<Failure, SubscriptionStatus>(tStatusPro));
      verify(() => mockRepository.purchasePackage(tPackage)).called(1);
    });

    test('should return PurchaseCancelledFailure when cancelled', () async {
      when(() => mockRepository.purchasePackage(tPackage)).thenAnswer(
        (_) async => const Left(PurchaseCancelledFailure()),
      );

      final result = await useCase(tPackage);

      expect(
        result,
        const Left<Failure, SubscriptionStatus>(PurchaseCancelledFailure()),
      );
      verify(() => mockRepository.purchasePackage(tPackage)).called(1);
    });
  });

  group('RestorePurchasesUseCase', () {
    late RestorePurchasesUseCase useCase;

    setUp(() {
      useCase = RestorePurchasesUseCase(mockRepository);
    });

    test('should return restored SubscriptionStatus', () async {
      when(() => mockRepository.restorePurchases())
          .thenAnswer((_) async => Right(tStatusPro));

      final result = await useCase(const NoParams());

      expect(result, Right<Failure, SubscriptionStatus>(tStatusPro));
      verify(() => mockRepository.restorePurchases()).called(1);
    });

    test('should return Failure on restore error', () async {
      when(() => mockRepository.restorePurchases()).thenAnswer(
        (_) async => const Left(SubscriptionFailure('Restore failed')),
      );

      final result = await useCase(const NoParams());

      expect(
        result,
        const Left<Failure, SubscriptionStatus>(
          SubscriptionFailure('Restore failed'),
        ),
      );
      verify(() => mockRepository.restorePurchases()).called(1);
    });
  });

  group('PresentPaywallUseCase', () {
    late PresentPaywallUseCase useCase;

    setUp(() {
      useCase = PresentPaywallUseCase(mockRepository);
    });

    test('should delegate to presentPaywallIfNeeded when onlyIfNeeded is true',
        () async {
      when(
        () => mockRepository.presentPaywallIfNeeded(
          requiredEntitlementId: any(named: 'requiredEntitlementId'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await useCase(const PresentPaywallParams());

      expect(result, const Right<Failure, bool>(true));
      verify(
        () => mockRepository.presentPaywallIfNeeded(),
      ).called(1);
    });

    test(
        'should present unconditionally and check status when onlyIfNeeded '
        'is false',
        () async {
      when(() => mockRepository.presentPaywall())
          .thenAnswer((_) async => const Right(unit));
      when(() => mockRepository.getSubscriptionStatus())
          .thenAnswer((_) async => Right(tStatusPro));

      final result = await useCase(
        const PresentPaywallParams(onlyIfNeeded: false),
      );

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockRepository.presentPaywall()).called(1);
    });
  });

  group('PresentCustomerCenterUseCase', () {
    late PresentCustomerCenterUseCase useCase;

    setUp(() {
      useCase = PresentCustomerCenterUseCase(mockRepository);
    });

    test('should delegate to repository presentCustomerCenter', () async {
      when(() => mockRepository.presentCustomerCenter())
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.presentCustomerCenter()).called(1);
    });
  });

  group('SyncSubscriptionAuthUseCase', () {
    late SyncSubscriptionAuthUseCase useCase;

    setUp(() {
      useCase = SyncSubscriptionAuthUseCase(mockRepository);
    });

    test('should log in when userId is provided', () async {
      when(() => mockRepository.logIn('user-456'))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase('user-456');

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.logIn('user-456')).called(1);
    });

    test('should log out when userId is null', () async {
      when(() => mockRepository.logOut())
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(null);

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => mockRepository.logOut()).called(1);
    });
  });

  group('WatchSubscriptionStatusUseCase', () {
    late WatchSubscriptionStatusUseCase useCase;

    setUp(() {
      useCase = WatchSubscriptionStatusUseCase(mockRepository);
    });

    test('should return stream from repository', () {
      when(() => mockRepository.watchSubscriptionStatus()).thenAnswer(
        (_) => Stream.value(Right(tStatusPro)),
      );

      final stream = useCase();

      expect(stream, emits(Right<Failure, SubscriptionStatus>(tStatusPro)));
      verify(() => mockRepository.watchSubscriptionStatus()).called(1);
    });
  });
}
