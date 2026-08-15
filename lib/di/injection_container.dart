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
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Repositories
// ─────────────────────────────────────────────────────────────────────────────

void _registerRepositories() {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Use Cases
// ─────────────────────────────────────────────────────────────────────────────

void _registerUseCases() {
  sl
    ..registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(
      () => SignInWithTwitterUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => SignInWithLinkedInUseCase(sl<AuthRepository>()),
    )
    ..registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

void _registerRouter() {
  sl.registerLazySingleton<GoRouter>(() => createRouter(sl<AppBloc>()));
}
