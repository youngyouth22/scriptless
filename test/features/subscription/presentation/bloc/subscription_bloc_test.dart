import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_status.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:scriptless/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_customer_center_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_paywall_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/sync_subscription_auth_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/watch_subscription_status_usecase.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_state.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockGetOfferingsUseCase extends Mock implements GetOfferingsUseCase {}

class MockPurchaseSubscriptionUseCase extends Mock
    implements PurchaseSubscriptionUseCase {}

class MockRestorePurchasesUseCase extends Mock
    implements RestorePurchasesUseCase {}

class MockPresentPaywallUseCase extends Mock implements PresentPaywallUseCase {}

class MockPresentCustomerCenterUseCase extends Mock
    implements PresentCustomerCenterUseCase {}

class MockSyncSubscriptionAuthUseCase extends Mock
    implements SyncSubscriptionAuthUseCase {}

class MockWatchSubscriptionStatusUseCase extends Mock
    implements WatchSubscriptionStatusUseCase {}

void main() {
  late MockSubscriptionRepository mockRepository;
  late MockGetOfferingsUseCase mockGetOfferings;
  late MockPurchaseSubscriptionUseCase mockPurchaseSubscription;
  late MockRestorePurchasesUseCase mockRestorePurchases;
  late MockPresentPaywallUseCase mockPresentPaywall;
  late MockPresentCustomerCenterUseCase mockPresentCustomerCenter;
  late MockSyncSubscriptionAuthUseCase mockSyncSubscriptionAuth;
  late MockWatchSubscriptionStatusUseCase mockWatchSubscriptionStatus;

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

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(tPackage);
    registerFallbackValue(const PresentPaywallParams());
  });

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    mockGetOfferings = MockGetOfferingsUseCase();
    mockPurchaseSubscription = MockPurchaseSubscriptionUseCase();
    mockRestorePurchases = MockRestorePurchasesUseCase();
    mockPresentPaywall = MockPresentPaywallUseCase();
    mockPresentCustomerCenter = MockPresentCustomerCenterUseCase();
    mockSyncSubscriptionAuth = MockSyncSubscriptionAuthUseCase();
    mockWatchSubscriptionStatus = MockWatchSubscriptionStatusUseCase();

    when(
      () => mockWatchSubscriptionStatus(),
    ).thenAnswer((_) => const Stream.empty());
  });

  SubscriptionBloc buildBloc() => SubscriptionBloc(
    subscriptionRepository: mockRepository,
    getOfferings: mockGetOfferings,
    purchaseSubscription: mockPurchaseSubscription,
    restorePurchases: mockRestorePurchases,
    presentPaywall: mockPresentPaywall,
    presentCustomerCenter: mockPresentCustomerCenter,
    syncSubscriptionAuth: mockSyncSubscriptionAuth,
    watchSubscriptionStatus: mockWatchSubscriptionStatus,
  );

  group('SubscriptionBloc', () {
    test('initial state should be SubscriptionInitial', () {
      expect(buildBloc().state, const SubscriptionInitial());
    });

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionLoaded] when check succeeds',
      build: () {
        when(
          () => mockRepository.getSubscriptionStatus(),
        ).thenAnswer((_) async => Right(tStatusPro));
        when(
          () => mockGetOfferings(any()),
        ).thenAnswer((_) async => const Right([tPackage]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubscriptionCheckRequested()),
      expect: () => [
        const SubscriptionLoading(),
        SubscriptionLoaded(
          currentStatus: tStatusPro,
          availableOfferings: const [tPackage],
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionFailureState] when check fails',
      build: () {
        when(() => mockRepository.getSubscriptionStatus()).thenAnswer(
          (_) async => const Left(SubscriptionFailure('Fetch failed')),
        );
        when(
          () => mockGetOfferings(any()),
        ).thenAnswer((_) async => const Right([tPackage]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubscriptionCheckRequested()),
      expect: () => [
        const SubscriptionLoading(),
        const SubscriptionFailureState(
          failure: SubscriptionFailure('Fetch failed'),
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionActionInProgress, SubscriptionActionSuccess] '
      'on purchase',
      build: () {
        when(
          () => mockPurchaseSubscription(tPackage),
        ).thenAnswer((_) async => Right(tStatusPro));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubscriptionPurchaseRequested(tPackage)),
      expect: () => [
        SubscriptionActionInProgress(
          currentStatus: tStatusFree,
        ),
        SubscriptionActionSuccess(
          message: 'Subscription successfully activated!',
          currentStatus: tStatusPro,
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionActionInProgress, SubscriptionFailureState] '
      'on purchase cancellation',
      build: () {
        when(() => mockPurchaseSubscription(tPackage)).thenAnswer(
          (_) async => const Left(PurchaseCancelledFailure()),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubscriptionPurchaseRequested(tPackage)),
      expect: () => [
        SubscriptionActionInProgress(
          currentStatus: tStatusFree,
        ),
        SubscriptionFailureState(
          failure: const PurchaseCancelledFailure(),
          currentStatus: tStatusFree,
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionActionInProgress, SubscriptionActionSuccess] '
      'on restore',
      build: () {
        when(
          () => mockRestorePurchases(any()),
        ).thenAnswer((_) async => Right(tStatusPro));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubscriptionRestoreRequested()),
      expect: () => [
        SubscriptionActionInProgress(
          currentStatus: tStatusFree,
        ),
        SubscriptionActionSuccess(
          message: 'Purchases successfully restored.',
          currentStatus: tStatusPro,
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits updated SubscriptionLoaded when SubscriptionStatusUpdated is '
      'received',
      build: buildBloc,
      act: (bloc) => bloc.add(SubscriptionStatusUpdated(tStatusPro)),
      expect: () => [
        SubscriptionLoaded(
          currentStatus: tStatusPro,
        ),
      ],
    );
  });
}
