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
final class AppUnauthenticated extends AppState {
  /// Default constructor.
  const AppUnauthenticated();
}
