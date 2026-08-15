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
  })  : _authRepository = authRepository,
        _getCurrentUser = getCurrentUser,
        super(const AppLoading()) {
    on<AppStarted>(_onAppStarted);
    on<AppUserAuthenticated>(_onUserAuthenticated);
    on<AppUserUnauthenticated>(_onUserUnauthenticated);
  }

  final AuthRepository _authRepository;
  final GetCurrentUserUseCase _getCurrentUser;

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

    result.fold(
      (failure) {
        log(
          'AppBloc: getCurrentUser failed — ${failure.message}',
          name: 'app',
        );
        emit(const AppUnauthenticated());
      },
      (user) {
        if (user != null && user.isNotEmpty) {
          log('AppBloc: session found — user ${user.id}', name: 'app');
          emit(AppAuthenticated(user));
        } else {
          log('AppBloc: no active session', name: 'app');
          emit(const AppUnauthenticated());
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
