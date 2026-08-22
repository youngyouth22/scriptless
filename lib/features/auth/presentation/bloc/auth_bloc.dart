// Bloc constructors must call super() in the initializer list, which prevents
// using initializing formals (this._field) for private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/core/usecase/usecase.dart';
import 'package:scriptless/features/auth/domain/entities/app_user.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_linkedin_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_in_with_twitter_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:scriptless/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages authentication state for email and OAuth sign-in / sign-up / sign-out flows.
///
/// Uses [SignInWithEmailUseCase], [SignUpWithEmailUseCase],
/// [SignInWithGoogleUseCase], [SignInWithTwitterUseCase],
/// [SignInWithLinkedInUseCase], [SignOutUseCase].
/// Emits: [AuthInitial] → [AuthLoading] | [AuthOAuthInProgress] →
/// [AuthSuccess] | [AuthFailureState] | [AuthSignedOut].
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc].
  AuthBloc({
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignInWithTwitterUseCase signInWithTwitter,
    required SignInWithLinkedInUseCase signInWithLinkedIn,
    required SignOutUseCase signOut,
  }) : _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signInWithTwitter = signInWithTwitter,
       _signInWithLinkedIn = signInWithLinkedIn,
       _signOut = signOut,
       super(const AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthTwitterSignInRequested>(_onTwitterSignInRequested);
    on<AuthLinkedInSignInRequested>(_onLinkedInSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInWithTwitterUseCase _signInWithTwitter;
  final SignInWithLinkedInUseCase _signInWithLinkedIn;
  final SignOutUseCase _signOut;

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.emailSignIn));
    log('AuthBloc: sign-in requested for ${event.email}', name: 'auth');

    final result = await _signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        log(
          'AuthBloc: sign-in failed — ${failure.message}',
          name: 'auth',
        );
        emit(AuthFailureState(failure));
      },
      (user) {
        log('AuthBloc: sign-in success — user ${user.id}', name: 'auth');
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.emailSignUp));
    log('AuthBloc: sign-up requested for ${event.email}', name: 'auth');

    final result = await _signUpWithEmail(
      SignUpParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        log(
          'AuthBloc: sign-up failed — ${failure.message}',
          name: 'auth',
        );
        emit(AuthFailureState(failure));
      },
      (user) {
        log('AuthBloc: sign-up success — user ${user.id}', name: 'auth');
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.google));
    log('AuthBloc: Google OAuth requested', name: 'auth');

    final result = await _signInWithGoogle(const NoParams());

    result.fold(
      (failure) {
        log('AuthBloc: Google OAuth failed — ${failure.message}', name: 'auth');
        emit(AuthFailureState(failure));
      },
      (_) {
        log('AuthBloc: Google OAuth browser opened', name: 'auth');
        emit(const AuthOAuthInProgress());
      },
    );
  }

  Future<void> _onTwitterSignInRequested(
    AuthTwitterSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.twitter));
    log('AuthBloc: Twitter OAuth requested', name: 'auth');

    final result = await _signInWithTwitter(const NoParams());

    result.fold(
      (failure) {
        log(
          'AuthBloc: Twitter OAuth failed — ${failure.message}',
          name: 'auth',
        );
        emit(AuthFailureState(failure));
      },
      (_) {
        log('AuthBloc: Twitter OAuth browser opened', name: 'auth');
        emit(const AuthOAuthInProgress());
      },
    );
  }

  Future<void> _onLinkedInSignInRequested(
    AuthLinkedInSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.linkedIn));
    log('AuthBloc: LinkedIn OAuth requested', name: 'auth');

    final result = await _signInWithLinkedIn(const NoParams());

    result.fold(
      (failure) {
        log(
          'AuthBloc: LinkedIn OAuth failed — ${failure.message}',
          name: 'auth',
        );
        emit(AuthFailureState(failure));
      },
      (_) {
        log('AuthBloc: LinkedIn OAuth browser opened', name: 'auth');
        emit(const AuthOAuthInProgress());
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(provider: AuthProviderType.signOut));
    log('AuthBloc: sign-out requested', name: 'auth');

    final result = await _signOut(const NoParams());

    result.fold(
      (failure) {
        log(
          'AuthBloc: sign-out failed — ${failure.message}',
          name: 'auth',
        );
        emit(AuthFailureState(failure));
      },
      (_) {
        log('AuthBloc: sign-out success', name: 'auth');
        emit(const AuthSignedOut());
      },
    );
  }
}
