/// Central registry of all named routes used by go_router.
///
/// Use these constants everywhere instead of raw strings to avoid typos
/// and to make refactoring safe.
abstract class AppRoutes {
  /// Splash / loading screen shown during app startup.
  static const String splash = '/splash';

  /// Root — redirects based on auth state.
  static const String root = '/';

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Login screen (email + OAuth entry point).
  static const String authLogin = '/auth/login';

  /// OAuth deep-link callback route handled internally by Supabase.
  static const String authCallback = '/auth/callback';

  // ── Protected ─────────────────────────────────────────────────────────────

  /// Main dashboard (authenticated users only).
  static const String home = '/home';

  /// Scenario list screen.
  static const String scenarios = '/scenarios';

  /// Active conversation screen.
  static const String conversation = '/conversation';
}
