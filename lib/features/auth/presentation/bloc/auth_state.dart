part of 'auth_bloc.dart';

/// States emitted by [AuthBloc].
sealed class AuthState {
  const AuthState();
}

/// Initial state before any auth action has been attempted.
final class AuthInitial extends AuthState {
  /// Default constructor.
  const AuthInitial();
}

/// Authentication provider types used to identify active operations.
enum AuthProviderType {
  /// Sign in with email and password.
  emailSignIn,

  /// Sign up with email and password.
  emailSignUp,

  /// Google OAuth provider.
  google,

  /// Twitter / X OAuth provider.
  twitter,

  /// LinkedIn OAuth provider.
  linkedIn,

  /// Sign out operation.
  signOut,
}

/// An async auth operation (sign-in / sign-up / sign-out) is in progress.
@immutable
final class AuthLoading extends AuthState {
  /// Default constructor.
  const AuthLoading({this.provider});

  /// The specific provider or action currently loading.
  final AuthProviderType? provider;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoading &&
          runtimeType == other.runtimeType &&
          provider == other.provider;

  @override
  int get hashCode => provider.hashCode;
}

/// OAuth browser has opened and waiting for deep link callback.
final class AuthOAuthInProgress extends AuthState {
  /// Default constructor.
  const AuthOAuthInProgress();
}

/// The auth operation succeeded — user is now authenticated.
@immutable
final class AuthSuccess extends AuthState {
  /// Default constructor.
  const AuthSuccess(this.user);

  /// The authenticated user.
  final AppUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccess &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// The auth operation failed — contains the typed [Failure].
@immutable
final class AuthFailureState extends AuthState {
  /// Default constructor.
  const AuthFailureState(this.failure);

  /// The typed failure returned by the use case.
  final Failure failure;

  /// Convenience getter for the human-readable error message.
  String get message => failure.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailureState &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// Sign-out completed — the user is no longer authenticated.
final class AuthSignedOut extends AuthState {
  /// Default constructor.
  const AuthSignedOut();
}
