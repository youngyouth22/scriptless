// Cubit constructors must call super() in the initializer list.
// ignore_for_file: prefer_initializing_formals
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:scriptless/features/splash/domain/usecases/initialize_powersync_usecase.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_state.dart';

/// Cubit responsible for the startup sequence:
/// 1. Verifying Supabase session.
/// 2. Checking user onboarding completion.
/// 3. Initializing PowerSync local database.
/// 4. Emitting appropriate navigation target state.
class SplashCubit extends Cubit<SplashState> {
  /// Creates a [SplashCubit].
  SplashCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required CheckOnboardingStatusUseCase checkOnboardingStatus,
    required InitializePowerSyncUseCase initializePowerSync,
  }) : _getCurrentUser = getCurrentUser,
       _checkOnboardingStatus = checkOnboardingStatus,
       _initializePowerSync = initializePowerSync,
       super(const SplashInitial());

  final GetCurrentUserUseCase _getCurrentUser;
  final CheckOnboardingStatusUseCase _checkOnboardingStatus;
  final InitializePowerSyncUseCase _initializePowerSync;

  /// Starts the splash initialization check sequence.
  Future<void> init() async {
    log('SplashCubit: Starting initialization checks', name: 'splash');
    _safeEmit(const SplashLoading());

    // 1. Verify Supabase session
    final authResult = await _getCurrentUser(const NoParams());

    await authResult.fold(
      (failure) async {
        log(
          'SplashCubit: Session check error — ${failure.message}',
          name: 'splash',
        );
        _safeEmit(const SplashNavigateToLogin());
      },
      (user) async {
        if (user == null || user.isEmpty) {
          log('SplashCubit: No active session found', name: 'splash');
          _safeEmit(const SplashNavigateToLogin());
          return;
        }

        log('SplashCubit: User authenticated — ${user.id}', name: 'splash');

        // 2. Check onboarding status
        final onboardingResult = await _checkOnboardingStatus(user.id);

        await onboardingResult.fold(
          (failure) async {
            log(
              'SplashCubit: Onboarding check failed — ${failure.message}',
              name: 'splash',
            );
            _safeEmit(SplashError(failure));
          },
          (isCompleted) async {
            if (!isCompleted) {
              log('SplashCubit: Onboarding incomplete', name: 'splash');
              _safeEmit(const SplashNavigateToOnboarding());
              return;
            }

            log(
              'SplashCubit: Onboarding complete, initializing PowerSync',
              name: 'splash',
            );

            // 3. Initialize PowerSync
            final powerSyncResult = await _initializePowerSync(
              const NoParams(),
            );

            powerSyncResult.fold(
              (failure) {
                log(
                  'SplashCubit: PowerSync init failed — ${failure.message}',
                  name: 'splash',
                );
                _safeEmit(SplashError(failure));
              },
              (_) {
                log(
                  'SplashCubit: PowerSync initialized successfully',
                  name: 'splash',
                );
                _safeEmit(const SplashNavigateToDashboard());
              },
            );
          },
        );
      },
    );
  }

  void _safeEmit(SplashState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
