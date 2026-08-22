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
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:scriptless/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:scriptless/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:scriptless/features/onboarding/data/repositories/onboarding_seen_repository_impl.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:scriptless/features/onboarding/domain/repositories/onboarding_seen_repository.dart';
import 'package:scriptless/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/has_seen_onboarding_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/mark_onboarding_seen_usecase.dart';
import 'package:scriptless/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:scriptless/features/splash/data/datasources/splash_remote_datasource.dart';
import 'package:scriptless/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:scriptless/features/splash/domain/repositories/splash_repository.dart';
import 'package:scriptless/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:scriptless/features/splash/domain/usecases/initialize_powersync_usecase.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_cubit.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers all dependencies.
///
/// Call this once in `main()` before `runApp()`.
/// Order matters:
/// external → data sources → repositories → use cases → blocs → router.
Future<void> configureDependencies() async {
  await _registerExternal();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
  _registerRouter();
}

// ─────────────────────────────────────────────────────────────────────────────
// External / third-party
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _registerExternal() async {
  // Supabase client — already initialized in main.dart before this runs.
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // SharedPreferences — must be awaited before registering datasources.
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
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
    )
    ..registerLazySingleton<SplashRemoteDataSource>(
      () => SplashRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
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
    )
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(sl<SplashRemoteDataSource>()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl<OnboardingRemoteDataSource>()),
    )
    ..registerLazySingleton<OnboardingSeenRepository>(
      () => OnboardingSeenRepositoryImpl(sl<OnboardingLocalDataSource>()),
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// Use Cases
// ─────────────────────────────────────────────────────────────────────────────

void _registerUseCases() {
  sl
    // Auth use cases
    ..registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthRepository>()))
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
    )
    // Splash use cases
    ..registerLazySingleton(
      () => CheckOnboardingStatusUseCase(sl<SplashRepository>()),
    )
    ..registerLazySingleton(
      () => InitializePowerSyncUseCase(sl<SplashRepository>()),
    )
    // Onboarding use cases
    ..registerLazySingleton(
      () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
    )
    ..registerLazySingleton(
      () => HasSeenOnboardingUseCase(sl<OnboardingSeenRepository>()),
    )
    ..registerLazySingleton(
      () => MarkOnboardingSeenUseCase(sl<OnboardingSeenRepository>()),
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
      hasSeenOnboarding: sl<HasSeenOnboardingUseCase>(),
    ),
  );

  // AuthBloc — factory because it is tied to the sign-in screen lifecycle.
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithEmail: sl<SignInWithEmailUseCase>(),
      signUpWithEmail: sl<SignUpWithEmailUseCase>(),
      signInWithGoogle: sl<SignInWithGoogleUseCase>(),
      signInWithTwitter: sl<SignInWithTwitterUseCase>(),
      signInWithLinkedIn: sl<SignInWithLinkedInUseCase>(),
      signOut: sl<SignOutUseCase>(),
    ),
  );

  // SplashCubit — factory tied to the splash screen.
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      checkOnboardingStatus: sl<CheckOnboardingStatusUseCase>(),
      initializePowerSync: sl<InitializePowerSyncUseCase>(),
    ),
  );

  // OnboardingCubit — factory tied to onboarding flow.
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      completeOnboarding: sl<CompleteOnboardingUseCase>(),
      markOnboardingSeen: sl<MarkOnboardingSeenUseCase>(),
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
