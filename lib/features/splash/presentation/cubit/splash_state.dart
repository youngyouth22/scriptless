import 'package:flutter/foundation.dart';
import 'package:scriptless/core/error/failures.dart';
import 'package:scriptless/features/splash/presentation/cubit/splash_cubit.dart';

/// Base sealed class for all states emitted by [SplashCubit].
@immutable
sealed class SplashState {
  /// Default const constructor.
  const SplashState();
}

/// Initial state before any checks have started.
@immutable
final class SplashInitial extends SplashState {
  /// Default const constructor.
  const SplashInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state while session, onboarding, and PowerSync are being verified.
@immutable
final class SplashLoading extends SplashState {
  /// Default const constructor.
  const SplashLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State directing navigation to the Auth / Login flow.
@immutable
final class SplashNavigateToLogin extends SplashState {
  /// Default const constructor.
  const SplashNavigateToLogin();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashNavigateToLogin && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State directing navigation to the Onboarding flow.
@immutable
final class SplashNavigateToOnboarding extends SplashState {
  /// Default const constructor.
  const SplashNavigateToOnboarding();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashNavigateToOnboarding && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State directing navigation to the main Dashboard flow.
@immutable
final class SplashNavigateToDashboard extends SplashState {
  /// Default const constructor.
  const SplashNavigateToDashboard();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashNavigateToDashboard && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when an unrecoverable failure occurs during startup checks.
@immutable
final class SplashError extends SplashState {
  /// Creates a [SplashError] state.
  const SplashError(this.failure);

  /// The failure returned by the usecase.
  final Failure failure;

  /// Convenience getter for error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashError &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
