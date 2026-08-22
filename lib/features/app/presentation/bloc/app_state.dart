part of 'app_bloc.dart';

/// States emitted by [AppBloc].
sealed class AppState {
  const AppState();
}

/// Splash / startup — checking whether there is a valid session.
final class AppLoading extends AppState {
  /// Default constructor.
  const AppLoading();
}

/// No session AND the user has never seen the onboarding marketing slides.
///
/// The router guard redirects to `/onboarding` in this state.
/// Emitted exclusively on the very first launch of the app (before any account
/// creation). Once the user completes/skips onboarding, the flag is persisted
/// in SharedPreferences and this state is never emitted again.
final class AppNeedsOnboarding extends AppState {
  /// Default constructor.
  const AppNeedsOnboarding();
}

/// A user is authenticated and the app is ready.
@immutable
final class AppAuthenticated extends AppState {
  /// Default constructor.
  const AppAuthenticated(this.user);

  /// The currently authenticated user.
  final AppUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// No active session — the router should navigate to the auth flow.
///
/// Distinct from [AppNeedsOnboarding]: this state means the user has already
/// seen the onboarding slides (or signed out) and should go straight to login.
final class AppUnauthenticated extends AppState {
  /// Default constructor.
  const AppUnauthenticated();
}
