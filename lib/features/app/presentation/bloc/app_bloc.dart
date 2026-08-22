// Bloc constructors must call super() in the initializer list, which prevents
// using initializing formals (this._field) for private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/repositories/auth_repository.dart';
import 'package:scriptless/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:scriptless/features/onboarding/domain/usecases/has_seen_onboarding_usecase.dart';

part 'app_event.dart';
part 'app_state.dart';

/// Global BLoC that tracks the overall authentication state of the app.
///
/// Subscribes to [AuthRepository.authStateChanges] to react to session
/// changes and guards protected routes via go_router redirects.
/// Lifecycle: [AppLoading] → [AppAuthenticated] | [AppUnauthenticated].
class AppBloc extends Bloc<AppEvent, AppState> {
  /// Creates an [AppBloc].
  AppBloc({
    required AuthRepository authRepository,
    required GetCurrentUserUseCase getCurrentUser,
    required HasSeenOnboardingUseCase hasSeenOnboarding,
  }) : _authRepository = authRepository,
       _getCurrentUser = getCurrentUser,
       _hasSeenOnboarding = hasSeenOnboarding,
       super(const AppLoading()) {
    on<AppStarted>(_onAppStarted);
    on<AppUserAuthenticated>(_onUserAuthenticated);
    on<AppUserUnauthenticated>(_onUserUnauthenticated);
  }

  final AuthRepository _authRepository;
  final GetCurrentUserUseCase _getCurrentUser;
  final HasSeenOnboardingUseCase _hasSeenOnboarding;

  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    log('AppBloc: app started — checking session', name: 'app');

    // Subscribe to real-time auth state changes.
    unawaited(_authSubscription?.cancel());
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          add(AppUserAuthenticated(user));
        } else {
          add(const AppUserUnauthenticated());
        }
      },
      onError: (Object e) {
        log('AppBloc: authStateChanges error — $e', name: 'app');
        add(const AppUserUnauthenticated());
      },
    );

    // Perform an immediate one-shot check so we don't wait for the stream.
    final result = await _getCurrentUser(const NoParams());

    await result.fold(
      (failure) async {
        log(
          'AppBloc: getCurrentUser failed — ${failure.message}',
          name: 'app',
        );
        await _emitUnauthenticatedOrOnboarding(emit);
      },
      (user) async {
        if (user != null && user.isNotEmpty) {
          log('AppBloc: session found — user ${user.id}', name: 'app');
          emit(AppAuthenticated(user));
        } else {
          log('AppBloc: no active session', name: 'app');
          await _emitUnauthenticatedOrOnboarding(emit);
        }
      },
    );
  }

  /// Checks the local [HasSeenOnboardingUseCase] flag and emits either
  /// [AppNeedsOnboarding] (first launch) or [AppUnauthenticated] (returning).
  Future<void> _emitUnauthenticatedOrOnboarding(Emitter<AppState> emit) async {
    final seenResult = await _hasSeenOnboarding(const NoParams());
    seenResult.fold(
      (failure) {
        // On any local storage error, default to unauthenticated
        // (safe fallback — never block the user).
        log(
          'AppBloc: hasSeenOnboarding failed — ${failure.message}; '
          'defaulting to AppUnauthenticated',
          name: 'app',
        );
        emit(const AppUnauthenticated());
      },
      (hasSeen) {
        if (hasSeen) {
          log(
            'AppBloc: onboarding already seen '
            '— AppUnauthenticated',
            name: 'app',
          );
          emit(const AppUnauthenticated());
        } else {
          log(
            'AppBloc: first launch — AppNeedsOnboarding',
            name: 'app',
          );
          emit(const AppNeedsOnboarding());
        }
      },
    );
  }

  void _onUserAuthenticated(
    AppUserAuthenticated event,
    Emitter<AppState> emit,
  ) {
    log('AppBloc: user authenticated — ${event.user.id}', name: 'app');
    emit(AppAuthenticated(event.user));
  }

  void _onUserUnauthenticated(
    AppUserUnauthenticated event,
    Emitter<AppState> emit,
  ) {
    log('AppBloc: user unauthenticated', name: 'app');
    emit(const AppUnauthenticated());
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription?.cancel());
    return super.close();
  }
}
