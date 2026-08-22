part of 'auth_bloc.dart';

/// Events driving [AuthBloc].
@immutable
sealed class AuthEvent {
  const AuthEvent();
}

/// Sign in with email and password credentials.
@immutable
final class AuthSignInRequested extends AuthEvent {
  /// Creates an [AuthSignInRequested] event.
  const AuthSignInRequested({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSignInRequested &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => Object.hash(email, password);
}

/// Sign up a new user with email and password.
@immutable
final class AuthSignUpRequested extends AuthEvent {
  /// Creates an [AuthSignUpRequested] event.
  const AuthSignUpRequested({required this.email, required this.password});

  /// The new user's email address.
  final String email;

  /// The new user's password.
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSignUpRequested &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => Object.hash(email, password);
}

/// Sign in with Google OAuth.
@immutable
final class AuthGoogleSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthGoogleSignInRequested();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthGoogleSignInRequested;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Sign in with X (Twitter) OAuth.
@immutable
final class AuthTwitterSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthTwitterSignInRequested();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthTwitterSignInRequested;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Sign in with LinkedIn OAuth.
@immutable
final class AuthLinkedInSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthLinkedInSignInRequested();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLinkedInSignInRequested;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Sign out the currently authenticated user.
@immutable
final class AuthSignOutRequested extends AuthEvent {
  /// Default constructor.
  const AuthSignOutRequested();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthSignOutRequested;

  @override
  int get hashCode => runtimeType.hashCode;
}
