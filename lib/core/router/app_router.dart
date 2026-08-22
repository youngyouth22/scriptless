import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/core/router/go_router_refresh_stream.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';
import 'package:scriptless/features/auth/presentation/pages/auth_email_login_page.dart';
import 'package:scriptless/features/auth/presentation/pages/auth_register_page.dart';
import 'package:scriptless/features/auth/presentation/pages/login_page.dart';
import 'package:scriptless/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:scriptless/features/splash/presentation/pages/splash_page.dart';

// ─── Router factory ──────────────────────────────────────────────────────────

/// Builds and returns the app-wide [GoRouter].
///
/// The router uses [AppBloc] as its single source of truth for auth/onboarding
/// state. Any state change in [AppBloc] triggers a re-evaluation of the
/// redirect callback via [GoRouterRefreshStream].
///
/// Guard logic:
/// - [AppLoading]           → always show splash (wait for boot sequence)
/// - [AppNeedsOnboarding]   → redirect to /onboarding (first launch only)
/// - [AppUnauthenticated]   → redirect to /auth/login (has seen onboarding)
/// - [AppAuthenticated]     → redirect away from auth/onboarding/splash routes
GoRouter createRouter(AppBloc appBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(appBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final appState = appBloc.state;
      final location = state.matchedLocation;

      log(
        'GoRouter redirect — state: $appState, location: $location',
        name: 'router',
      );

      final isOnSplash = location == AppRoutes.splash;
      final isOnOnboarding = location.startsWith('/onboarding');
      final isOnAuthRoute = location.startsWith('/auth');

      return switch (appState) {
        // ── Boot ──────────────────────────────────────────────────────────
        // Keep the user on /splash until the AppBloc emits a real state.
        AppLoading() => isOnSplash ? null : AppRoutes.splash,

        // ── First launch ──────────────────────────────────────────────────
        // User has never seen the onboarding marketing slides.
        // Allow /onboarding only; redirect everything else there.
        AppNeedsOnboarding() => isOnOnboarding ? null : AppRoutes.onboarding,

        // ── Unauthenticated (returning user / signed out) ─────────────────
        // User has already seen onboarding; send straight to login.
        // Allow all /auth/* routes; redirect everything else to login.
        AppUnauthenticated() => isOnAuthRoute ? null : AppRoutes.authLogin,

        // ── Authenticated ─────────────────────────────────────────────────
        // User is signed in; block auth/onboarding/splash routes.
        AppAuthenticated() =>
          (isOnAuthRoute || isOnOnboarding || isOnSplash)
              ? AppRoutes.dashboard
              : null,
      };
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ── Onboarding ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        name: AppRoutes.authLogin,
        path: AppRoutes.authLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoutes.authEmailLogin,
        path: AppRoutes.authEmailLogin,
        builder: (context, state) => const AuthEmailLoginPage(),
      ),
      GoRoute(
        name: AppRoutes.authRegister,
        path: AppRoutes.authRegister,
        builder: (context, state) => const AuthRegisterPage(),
      ),
      // GoRoute(
      //   path: AppRoutes.authMagicLink,
      //   builder: (context, state) => const MagicLinkPage(),
      // ),
      // GoRoute(
      //   path: AppRoutes.authForgotPassword,
      //   builder: (context, state) => const ForgotPasswordPage(),
      // ),
      GoRoute(
        path: AppRoutes.authCallback,
        // The deep-link callback is handled by Supabase's auth listener;
        // this route simply redirects back to splash so the guard takes over.
        redirect: (context, state) => AppRoutes.splash,
      ),

      // ── Permissions ────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.permissionsMicrophonePriming,
      //   builder: (context, state) => const MicrophonePrimingPage(),
      // ),
      // GoRoute(
      //   path: AppRoutes.permissionsNotificationsPriming,
      //   builder: (context, state) => const NotificationsPrimingPage(),
      // ),

      // ── Persona ────────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.persona,
      //   builder: (context, state) => const PersonaPage(),
      // ),

      // ── Dashboard ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Library ────────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.library,
      //   builder: (context, state) => const LibraryPage(),
      //   routes: [
      //     GoRoute(
      //       path: 'search',
      //       builder: (context, state) => const LibrarySearchPage(),
      //     ),
      //     GoRoute(
      //       path: 'scenario/:id',
      //       builder: (context, state) {
      //         final id = state.pathParameters['id']!;
      //         return ScenarioDetailPage(id: id);
      //       },
      //     ),
      //     GoRoute(
      //       path: 'personality/create',
      //       builder: (context, state) => const PersonalityCreatePage(),
      //     ),
      //     GoRoute(
      //       path: 'personality/:id/edit',
      //       builder: (context, state) {
      //         final id = state.pathParameters['id']!;
      //         return PersonalityEditPage(id: id);
      //       },
      //     ),
      //   ],
      // ),

      // ── Conversation ───────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.conversationConsent,
      //   builder: (context, state) {
      //     final scenarioId = state.pathParameters['scenarioId']!;
      //     return ConversationConsentPage(scenarioId: scenarioId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutes.conversationPre,
      //   builder: (context, state) {
      //     final scenarioId = state.pathParameters['scenarioId']!;
      //     return ConversationPrePage(scenarioId: scenarioId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutes.conversationActive,
      //   builder: (context, state) {
      //     final conversationId = state.pathParameters['conversationId']!;
      //     return ConversationActivePage(conversationId: conversationId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutes.conversationActiveText,
      //   builder: (context, state) {
      //     final conversationId = state.pathParameters['conversationId']!;
      //     return ConversationActiveTextPage(conversationId: conversationId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutes.conversationProcessing,
      //   builder: (context, state) {
      //     final conversationId = state.pathParameters['conversationId']!;
      //     return ConversationProcessingPage(conversationId: conversationId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutes.conversationFeedback,
      //   builder: (context, state) {
      //     final conversationId = state.pathParameters['conversationId']!;
      //     return ConversationFeedbackPage(conversationId: conversationId);
      //   },
      // ),

      // ── History ────────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.history,
      //   builder: (context, state) => const HistoryPage(),
      //   routes: [
      //     GoRoute(
      //       path: 'detail/:conversationId',
      //       builder: (context, state) {
      //         final conversationId = state.pathParameters['conversationId']!;
      //         return HistoryDetailPage(conversationId: conversationId);
      //       },
      //     ),
      //   ],
      // ),

      // ── Gamification / Social ──────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.leaderboard,
      //   builder: (context, state) => const LeaderboardPage(),
      // ),
      // GoRoute(
      //   path: AppRoutes.achievements,
      //   builder: (context, state) => const AchievementsPage(),
      // ),
      // GoRoute(
      //   path: AppRoutes.notifications,
      //   builder: (context, state) => const NotificationsPage(),
      // ),

      // ── Profile ────────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.profile,
      //   builder: (context, state) => const ProfilePage(),
      //   routes: [
      //     GoRoute(
      //       path: 'edit',
      //       builder: (context, state) => const ProfileEditPage(),
      //     ),
      //   ],
      // ),

      // ── Settings ───────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.settings,
      //   builder: (context, state) => const SettingsPage(),
      // ),

      // ── Paywall ────────────────────────────────────────────────────────────
      // GoRoute(
      //   path: AppRoutes.paywall,
      //   builder: (context, state) => const PaywallPage(),
      // ),
    ],
  );
}
