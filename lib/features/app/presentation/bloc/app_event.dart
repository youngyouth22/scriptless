part of 'app_bloc.dart';

/// Events driving [AppBloc].
sealed class AppEvent {
  const AppEvent();
}

/// Fired on startup to check if there is an active session.
final class AppStarted extends AppEvent {
  /// Default constructor.
  const AppStarted();
}

/// Fired when the auth state stream emits a new user (logged in).
final class AppUserAuthenticated extends AppEvent {
  /// Default constructor.
  const AppUserAuthenticated(this.user);

  /// The newly authenticated user.
  final AppUser user;
}

/// Fired when the auth state stream emits null (logged out).
final class AppUserUnauthenticated extends AppEvent {
  /// Default constructor.
  const AppUserUnauthenticated();
}

/// Fired when the user completes their persona selection/setup.
final class AppPersonaCompleted extends AppEvent {
  /// Default constructor.
  const AppPersonaCompleted(this.user);

  /// The user who completed persona setup.
  final AppUser user;
}
