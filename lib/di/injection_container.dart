import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:powersync/powersync.dart';
import 'package:scriptless/core/powersync/powersync.dart';
import 'package:scriptless/core/powersync/supabase_connector.dart';
import 'package:scriptless/core/router/app_router.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:scriptless/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/resend_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_linkedin_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_twitter_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/verify_sign_up_otp_usecase.dart';
import 'package:scriptless/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:scriptless/features/auth/presentation/bloc/otp_bloc.dart';


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
import 'package:scriptless/features/permissions/data/datasources/permission_local_datasource.dart';
import 'package:scriptless/features/permissions/data/repositories/permission_repository_impl.dart';
import 'package:scriptless/features/permissions/domain/repositories/permission_repository.dart';
import 'package:scriptless/features/permissions/domain/usecases/check_permission_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/open_app_settings_usecase.dart';
import 'package:scriptless/features/permissions/domain/usecases/request_permission_usecase.dart';
import 'package:scriptless/features/permissions/presentation/cubit/microphone_priming_cubit.dart';
import 'package:scriptless/features/permissions/presentation/cubit/notifications_priming_cubit.dart';
import 'package:scriptless/features/persona/data/datasources/persona_remote_datasource.dart';
import 'package:scriptless/features/persona/data/repositories/persona_repository_impl.dart';
import 'package:scriptless/features/persona/domain/repositories/persona_repository.dart';
import 'package:scriptless/features/persona/domain/usecases/get_persona_profile_usecase.dart';
import 'package:scriptless/features/persona/domain/usecases/save_persona_profile_usecase.dart';
import 'package:scriptless/features/persona/presentation/cubit/persona_cubit.dart';
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

  // PowerSync connector and database service
  sl
    ..registerLazySingleton<SupabaseConnector>(
      () => SupabaseConnector(supabaseClient: sl<SupabaseClient>()),
    )
    ..registerLazySingleton<PowerSyncService>(
      () => PowerSyncService(
        supabaseClient: sl<SupabaseClient>(),
        connector: sl<SupabaseConnector>(),
      ),
    )
    ..registerLazySingleton<PowerSyncDatabase>(
      () => sl<PowerSyncService>().db,
    );

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
      () => AuthRemoteDataSourceImpl(
        sl<SupabaseClient>(),
        powerSyncService: sl<PowerSyncService>(),
      ),
    )
    ..registerLazySingleton<RevenueCatRemoteDataSource>(
      RevenueCatRemoteDataSourceImpl.new,
    )
    ..registerLazySingleton<SplashRemoteDataSource>(
      () => SplashRemoteDataSourceImpl(
        sl<SupabaseClient>(),
        sl<PowerSyncService>(),
      ),
    )
    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<PermissionLocalDataSource>(
      PermissionLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<PersonaRemoteDataSource>(
      () => PersonaRemoteDataSourceImpl(sl<SupabaseClient>()),
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
    )
    ..registerLazySingleton<PermissionRepository>(
      () => PermissionRepositoryImpl(sl<PermissionLocalDataSource>()),
    )
    ..registerLazySingleton<PersonaRepository>(
      () => PersonaRepositoryImpl(sl<PersonaRemoteDataSource>()),
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
    ..registerLazySingleton(
      () => SendPasswordResetOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => VerifyPasswordResetOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(() => UpdatePasswordUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(
      () => ResendPasswordResetOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => VerifySignUpOtpUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => ResendSignUpOtpUseCase(sl<AuthRepository>()),
    )
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
    )
    // Permissions use cases
    ..registerLazySingleton(
      () => CheckPermissionUseCase(sl<PermissionRepository>()),
    )
    ..registerLazySingleton(
      () => RequestPermissionUseCase(sl<PermissionRepository>()),
    )
    ..registerLazySingleton(
      () => OpenAppSettingsUseCase(sl<PermissionRepository>()),
    )
    // Persona use cases
    ..registerLazySingleton(
      () => SavePersonaProfileUseCase(sl<PersonaRepository>()),
    )
    ..registerLazySingleton(
      () => GetPersonaProfileUseCase(sl<PersonaRepository>()),
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
      getPersonaProfile: sl<GetPersonaProfileUseCase>(),
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

  // OtpBloc — factory tied to OTP & password reset flow lifecycle.
  sl.registerFactory<OtpBloc>(
    () => OtpBloc(
      sendPasswordResetOtp: sl<SendPasswordResetOtpUseCase>(),
      verifyPasswordResetOtp: sl<VerifyPasswordResetOtpUseCase>(),
      updatePassword: sl<UpdatePasswordUseCase>(),
      resendPasswordResetOtp: sl<ResendPasswordResetOtpUseCase>(),
      verifySignUpOtp: sl<VerifySignUpOtpUseCase>(),
      resendSignUpOtp: sl<ResendSignUpOtpUseCase>(),
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

  // Permissions Cubits — factories tied to priming screens.
  sl.registerFactory<MicrophonePrimingCubit>(
    () => MicrophonePrimingCubit(
      checkPermission: sl<CheckPermissionUseCase>(),
      requestPermission: sl<RequestPermissionUseCase>(),
      openAppSettings: sl<OpenAppSettingsUseCase>(),
    ),
  );

  sl.registerFactory<NotificationsPrimingCubit>(
    () => NotificationsPrimingCubit(
      checkPermission: sl<CheckPermissionUseCase>(),
      requestPermission: sl<RequestPermissionUseCase>(),
      openAppSettings: sl<OpenAppSettingsUseCase>(),
    ),
  );

  // PersonaCubit — factory tied to persona selection wizard.
  sl.registerFactory<PersonaCubit>(
    () => PersonaCubit(
      savePersonaProfile: sl<SavePersonaProfileUseCase>(),
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
