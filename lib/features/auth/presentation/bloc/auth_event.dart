part of 'auth_bloc.dart';

/// Events driving [AuthBloc].
sealed class AuthEvent {
  const AuthEvent();
}

/// Sign in with email and password credentials.
final class AuthSignInRequested extends AuthEvent {
  /// Creates an [AuthSignInRequested] event.
  const AuthSignInRequested({required this.email, required this.password});

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;
}

/// Sign up a new user with email and password.
final class AuthSignUpRequested extends AuthEvent {
  /// Creates an [AuthSignUpRequested] event.
  const AuthSignUpRequested({required this.email, required this.password});

  /// The new user's email address.
  final String email;

  /// The new user's password.
  final String password;
}

/// Sign in with Google OAuth.
final class AuthGoogleSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthGoogleSignInRequested();
}

/// Sign in with X (Twitter) OAuth.
final class AuthTwitterSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthTwitterSignInRequested();
}

/// Sign in with LinkedIn OAuth.
final class AuthLinkedInSignInRequested extends AuthEvent {
  /// Default constructor.
  const AuthLinkedInSignInRequested();
}

/// Sign out the currently authenticated user.
final class AuthSignOutRequested extends AuthEvent {
  /// Default constructor.
  const AuthSignOutRequested();
}
