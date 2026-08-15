import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/app_routes.dart';
import 'package:scriptless/core/router/go_router_refresh_stream.dart';
import 'package:scriptless/features/app/presentation/bloc/app_bloc.dart';

// ─── Placeholder pages ───────────────────────────────────────────────────────
// Replace these with your real pages once the UI layer is ready.

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _LoginPlaceholderPage extends StatelessWidget {
  const _LoginPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login — replace with AuthPage')),
    );
  }
}

class _HomePlaceholderPage extends StatelessWidget {
  const _HomePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home — replace with DashboardPage')),
    );
  }
}

// ─── Router factory ──────────────────────────────────────────────────────────

/// Builds and returns the app-wide [GoRouter].
///
/// The router uses [AppBloc] as its single source of truth for auth state.
/// Any state change in [AppBloc] triggers a re-evaluation of the redirect
/// callback via [GoRouterRefreshStream].
///
/// Guard logic:
/// - [AppLoading]          → always show splash
/// - [AppUnauthenticated]  → redirect to login (unless already on auth route)
/// - [AppAuthenticated]    → redirect away from auth routes to home
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

      final isOnAuthRoute = location.startsWith('/auth');
      final isOnSplash = location == AppRoutes.splash;

      return switch (appState) {
        AppLoading() => isOnSplash ? null : AppRoutes.splash,
        AppUnauthenticated() =>
          isOnAuthRoute ? null : AppRoutes.authLogin,
        AppAuthenticated() =>
          isOnAuthRoute || isOnSplash ? AppRoutes.home : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.authLogin,
        builder: (context, state) => const _LoginPlaceholderPage(),
      ),
      GoRoute(
        path: AppRoutes.authCallback,
        // The deep-link callback is handled by Supabase's auth listener;
        // this route simply redirects back to splash so the guard takes over.
        redirect: (context, state) => AppRoutes.splash,
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _HomePlaceholderPage(),
        routes: [
          GoRoute(
            path: 'scenarios',
            builder: (context, state) => const _HomePlaceholderPage(),
          ),
          GoRoute(
            path: 'conversation',
            builder: (context, state) => const _HomePlaceholderPage(),
          ),
        ],
      ),
    ],
  );
}
