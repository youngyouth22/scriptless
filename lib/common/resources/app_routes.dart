/// Central registry of all named routes used by go_router.
///
/// Use these constants everywhere instead of raw strings to avoid typos
/// and to make refactoring safe.
abstract class AppRoutes {
  /// Splash / loading screen shown during app startup.
  static const String splash = '/splash';

  /// Root route.
  static const String root = '/';

  // ── Onboarding ─────────────────────────────────────────────────────────────

  /// Onboarding flow.
  static const String onboarding = '/onboarding';

  // ── Auth ───────────────────────────────────────────────────────────────────

  /// Base auth path.
  static const String auth = '/auth';

  /// Login screen (email + OAuth entry point).
  static const String authLogin = '/auth/login';

  /// Email & password login screen.
  static const String authEmailLogin = '/auth/login-email';

  /// Registration / sign up screen.
  static const String authRegister = '/auth/register';

  /// Passwordless magic link sign in screen.
  static const String authMagicLink = '/auth/magic-link';

  /// Forgot password / password reset request screen.
  static const String authForgotPassword = '/auth/forgot-password';

  /// OAuth deep-link callback route handled internally by Supabase.
  static const String authCallback = '/auth/callback';

  // ── Permissions ────────────────────────────────────────────────────

  /// Microphone permission priming/explanation screen.
  static const String permissionsMicrophonePriming =
      '/permissions/microphone-priming';

  /// Push notifications permission priming/explanation screen.
  static const String permissionsNotificationsPriming =
      '/permissions/notifications-priming';

  // ── Persona ────────────────────────────────────────────────────────────────

  /// Persona selection / setup screen.
  static const String persona = '/persona';

  // ── Dashboard ──────────────────────────────────────────────────────────────

  /// Main dashboard (authenticated users).
  static const String dashboard = '/dashboard';

  /// Backward-compatible alias for dashboard.
  static const String home = '/dashboard';

  // ── Library ────────────────────────────────────────────────────────────────

  /// Scenario & personality library screen.
  static const String library = '/library';

  /// Library search screen.
  static const String librarySearch = '/library/search';

  /// Scenario detail screen (:id).
  static const String libraryScenario = '/library/scenario/:id';

  /// Custom personality creation screen.
  static const String libraryPersonalityCreate = '/library/personality/create';

  /// Custom personality edit screen (:id).
  static const String libraryPersonalityEdit = '/library/personality/:id/edit';

  // ── Conversation ───────────────────────────────────────────────────────────

  /// Recording / AI consent screen before a scenario (:scenarioId).
  static const String conversationConsent = '/conversation/consent/:scenarioId';

  /// Pre-conversation briefing / instructions (:scenarioId).
  static const String conversationPre = '/conversation/pre/:scenarioId';

  /// Active voice conversation simulation screen (:conversationId).
  static const String conversationActive =
      '/conversation/active/:conversationId';

  /// Active text-based conversation fallback screen (:conversationId).
  static const String conversationActiveText =
      '/conversation/active-text/:conversationId';

  /// Processing / audio analysis loading screen (:conversationId).
  static const String conversationProcessing =
      '/conversation/processing/:conversationId';

  /// Conversation feedback & scoring screen (:conversationId).
  static const String conversationFeedback =
      '/conversation/feedback/:conversationId';

  // ── History ────────────────────────────────────────────────────────────────

  /// Past conversations history list.
  static const String history = '/history';

  /// Detailed report for a past conversation (:conversationId).
  static const String historyDetail = '/history/detail/:conversationId';

  // ── Gamification / Social ──────────────────────────────────────────────────

  /// Leaderboard screen.
  static const String leaderboard = '/leaderboard';

  /// Achievements & badges screen.
  static const String achievements = '/achievements';

  /// Notifications center screen.
  static const String notifications = '/notifications';

  // ── Profile ────────────────────────────────────────────────────────────────

  /// User profile screen.
  static const String profile = '/profile';

  /// Edit user profile screen.
  static const String profileEdit = '/profile/edit';

  // ── Settings ───────────────────────────────────────────────────────────────

  /// App and account settings screen.
  static const String settings = '/settings';

  // ── Paywall ────────────────────────────────────────────────────────────────

  /// Subscription paywall screen.
  static const String paywall = '/paywall';
}
