// Bloc constructors must call super() in the initializer list, which prevents
// using initializing formals (this._field) for private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/subscription/domain/entities/subscription_package.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:scriptless/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_customer_center_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_paywall_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/sync_subscription_auth_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/watch_subscription_status_usecase.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_state.dart';

/// BLoC orchestrating subscription status, offerings, purchasing, and paywalls.
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  /// Creates a [SubscriptionBloc].
  SubscriptionBloc({
    required SubscriptionRepository subscriptionRepository,
    required GetOfferingsUseCase getOfferings,
    required PurchaseSubscriptionUseCase purchaseSubscription,
    required RestorePurchasesUseCase restorePurchases,
    required PresentPaywallUseCase presentPaywall,
    required PresentCustomerCenterUseCase presentCustomerCenter,
    required SyncSubscriptionAuthUseCase syncSubscriptionAuth,
    required WatchSubscriptionStatusUseCase watchSubscriptionStatus,
  }) : _subscriptionRepository = subscriptionRepository,
       _getOfferings = getOfferings,
       _purchaseSubscription = purchaseSubscription,
       _restorePurchases = restorePurchases,
       _presentPaywall = presentPaywall,
       _presentCustomerCenter = presentCustomerCenter,
       _syncSubscriptionAuth = syncSubscriptionAuth,
       _watchSubscriptionStatus = watchSubscriptionStatus,
       super(const SubscriptionInitial()) {
    on<SubscriptionCheckRequested>(_onCheckRequested);
    on<SubscriptionOfferingsRequested>(_onOfferingsRequested);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
    on<SubscriptionPaywallRequested>(_onPaywallRequested);
    on<SubscriptionPaywallIfNeededRequested>(_onPaywallIfNeededRequested);
    on<SubscriptionCustomerCenterRequested>(_onCustomerCenterRequested);
    on<SubscriptionUserChanged>(_onUserChanged);
    on<SubscriptionStatusUpdated>(_onStatusUpdated);

    _statusSubscription = _watchSubscriptionStatus().listen((result) {
      result.fold(
        (_) => null,
        (status) => add(SubscriptionStatusUpdated(status)),
      );
    });
  }

  final SubscriptionRepository _subscriptionRepository;
  final GetOfferingsUseCase _getOfferings;
  final PurchaseSubscriptionUseCase _purchaseSubscription;
  final RestorePurchasesUseCase _restorePurchases;
  final PresentPaywallUseCase _presentPaywall;
  final PresentCustomerCenterUseCase _presentCustomerCenter;
  final SyncSubscriptionAuthUseCase _syncSubscriptionAuth;
  final WatchSubscriptionStatusUseCase _watchSubscriptionStatus;

  StreamSubscription<dynamic>? _statusSubscription;

  Future<void> _onCheckRequested(
    SubscriptionCheckRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    final statusResult = await _subscriptionRepository.getSubscriptionStatus();
    final offeringsResult = await _getOfferings(const NoParams());

    statusResult.fold(
      (failure) => emit(SubscriptionFailureState(failure: failure)),
      (status) {
        final offerings = offeringsResult.getOrElse(
          () => <SubscriptionPackage>[],
        );
        emit(
          SubscriptionLoaded(
            currentStatus: status,
            availableOfferings: offerings,
          ),
        );
      },
    );
  }

  Future<void> _onOfferingsRequested(
    SubscriptionOfferingsRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentStatus = state.status;
    final offeringsResult = await _getOfferings(const NoParams());

    offeringsResult.fold(
      (failure) => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: currentStatus,
          availableOfferings: state.offerings,
        ),
      ),
      (offerings) => emit(
        SubscriptionLoaded(
          currentStatus: currentStatus,
          availableOfferings: offerings,
        ),
      ),
    );
  }

  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentStatus = state.status;
    final currentOfferings = state.offerings;

    emit(
      SubscriptionActionInProgress(
        currentStatus: currentStatus,
        availableOfferings: currentOfferings,
      ),
    );

    final result = await _purchaseSubscription(event.package);

    result.fold(
      (failure) => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: currentStatus,
          availableOfferings: currentOfferings,
        ),
      ),
      (updatedStatus) => emit(
        SubscriptionActionSuccess(
          message: 'Subscription successfully activated!',
          currentStatus: updatedStatus,
          availableOfferings: currentOfferings,
        ),
      ),
    );
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentStatus = state.status;
    final currentOfferings = state.offerings;

    emit(
      SubscriptionActionInProgress(
        currentStatus: currentStatus,
        availableOfferings: currentOfferings,
      ),
    );

    final result = await _restorePurchases(const NoParams());

    result.fold(
      (failure) => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: currentStatus,
          availableOfferings: currentOfferings,
        ),
      ),
      (updatedStatus) => emit(
        SubscriptionActionSuccess(
          message: 'Purchases successfully restored.',
          currentStatus: updatedStatus,
          availableOfferings: currentOfferings,
        ),
      ),
    );
  }

  Future<void> _onPaywallRequested(
    SubscriptionPaywallRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = await _presentPaywall(
      const PresentPaywallParams(onlyIfNeeded: false),
    );

    await result.fold(
      (failure) async => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: state.status,
          availableOfferings: state.offerings,
        ),
      ),
      (_) async => _refreshStatus(emit),
    );
  }

  Future<void> _onPaywallIfNeededRequested(
    SubscriptionPaywallIfNeededRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = await _presentPaywall(
      PresentPaywallParams(
        requiredEntitlementId: event.requiredEntitlementId,
      ),
    );

    await result.fold(
      (failure) async => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: state.status,
          availableOfferings: state.offerings,
        ),
      ),
      (_) async => _refreshStatus(emit),
    );
  }

  Future<void> _onCustomerCenterRequested(
    SubscriptionCustomerCenterRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = await _presentCustomerCenter(const NoParams());
    await result.fold(
      (failure) async => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: state.status,
          availableOfferings: state.offerings,
        ),
      ),
      (_) async => _refreshStatus(emit),
    );
  }

  Future<void> _onUserChanged(
    SubscriptionUserChanged event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = await _syncSubscriptionAuth(event.userId);
    await result.fold(
      (failure) async => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: state.status,
          availableOfferings: state.offerings,
        ),
      ),
      (_) async => _refreshStatus(emit),
    );
  }

  void _onStatusUpdated(
    SubscriptionStatusUpdated event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(
      SubscriptionLoaded(
        currentStatus: event.status,
        availableOfferings: state.offerings,
      ),
    );
  }

  Future<void> _refreshStatus(Emitter<SubscriptionState> emit) async {
    final statusResult = await _subscriptionRepository.getSubscriptionStatus();
    statusResult.fold(
      (failure) => emit(
        SubscriptionFailureState(
          failure: failure,
          currentStatus: state.status,
          availableOfferings: state.offerings,
        ),
      ),
      (status) => emit(
        SubscriptionLoaded(
          currentStatus: status,
          availableOfferings: state.offerings,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    return super.close();
  }
}
