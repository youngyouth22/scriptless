import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/core/router/app_router.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:scriptless/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_linkedin_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_twitter_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/subscription/data/datasources/revenuecat_remote_datasource.dart';
import 'package:scriptless/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:scriptless/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:scriptless/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_customer_center_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/present_paywall_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/sync_subscription_auth_usecase.dart';
import 'package:scriptless/features/subscription/domain/usecases/watch_subscription_status_usecase.dart';
import 'package:scriptless/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers all dependencies.
///
/// Call this once in `main()` before `runApp()`.
/// Order matters:
/// external → data sources → repositories → use cases → blocs → router.
Future<void> configureDependencies() async {
  _registerExternal();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
  _registerRouter();
}

// ─────────────────────────────────────────────────────────────────────────────
// External / third-party
// ─────────────────────────────────────────────────────────────────────────────

void _registerExternal() {
  // Supabase client — already initialized in main.dart before this runs.
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Sources
// ─────────────────────────────────────────────────────────────────────────────

void _registerDataSources() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<RevenueCatRemoteDataSource>(
      RevenueCatRemoteDataSourceImpl.new,
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// Repositories
// ─────────────────────────────────────────────────────────────────────────────

void _registerRepositories() {
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl<RevenueCatRemoteDataSource>()),
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// Use Cases
// ─────────────────────────────────────────────────────────────────────────────

void _registerUseCases() {
  sl
    // Auth use cases
    ..registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(
      () => SignInWithTwitterUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => SignInWithLinkedInUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()))
    // Subscription use cases
    ..registerLazySingleton(
      () => CheckProEntitlementUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => GetOfferingsUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => PurchaseSubscriptionUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => RestorePurchasesUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => PresentPaywallUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => PresentCustomerCenterUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => SyncSubscriptionAuthUseCase(sl<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => WatchSubscriptionStatusUseCase(sl<SubscriptionRepository>()),
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoCs / Cubits
// ─────────────────────────────────────────────────────────────────────────────

void _registerBlocs() {
  // AppBloc — singleton because it lives for the entire app lifetime.
  sl.registerLazySingleton<AppBloc>(
    () => AppBloc(
      authRepository: sl<AuthRepository>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
    ),
  );

  // AuthBloc — factory because it is tied to the sign-in screen lifecycle.
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithEmail: sl<SignInWithEmailUseCase>(),
      signInWithGoogle: sl<SignInWithGoogleUseCase>(),
      signInWithTwitter: sl<SignInWithTwitterUseCase>(),
      signInWithLinkedIn: sl<SignInWithLinkedInUseCase>(),
      signOut: sl<SignOutUseCase>(),
    ),
  );

  // SubscriptionBloc — singleton because subscription state spans the whole
  // app.
  sl.registerLazySingleton<SubscriptionBloc>(
    () => SubscriptionBloc(
      subscriptionRepository: sl<SubscriptionRepository>(),
      getOfferings: sl<GetOfferingsUseCase>(),
      purchaseSubscription: sl<PurchaseSubscriptionUseCase>(),
      restorePurchases: sl<RestorePurchasesUseCase>(),
      presentPaywall: sl<PresentPaywallUseCase>(),
      presentCustomerCenter: sl<PresentCustomerCenterUseCase>(),
      syncSubscriptionAuth: sl<SyncSubscriptionAuthUseCase>(),
      watchSubscriptionStatus: sl<WatchSubscriptionStatusUseCase>(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

void _registerRouter() {
  sl.registerLazySingleton<GoRouter>(() => createRouter(sl<AppBloc>()));
}
