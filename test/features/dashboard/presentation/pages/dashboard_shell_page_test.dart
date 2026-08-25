import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:scriptless/features/dashboard/presentation/pages/dashboard_shell_page.dart';
import 'package:scriptless/features/dashboard/presentation/widgets/dashboard_nav_bar.dart';
import 'package:scriptless/features/history/presentation/pages/history_page.dart';
import 'package:scriptless/features/library/presentation/pages/library_page.dart';
import 'package:scriptless/features/profile/presentation/pages/profile_page.dart';

void main() {
  group('DashboardShellPage with GoRouter', () {
    late GoRouter testRouter;

    setUp(() {
      testRouter = GoRouter(
        initialLocation: AppRoutes.dashboard,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return DashboardShellPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.dashboard,
                    builder: (context, state) => const DashboardPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.library,
                    builder: (context, state) => const LibraryPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.history,
                    builder: (context, state) => const HistoryPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.profile,
                    builder: (context, state) => const ProfilePage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });

    Widget buildTestApp() {
      return MaterialApp.router(
        routerConfig: testRouter,
      );
    }

    testWidgets('renders DashboardShellPage, initial Accueil tab, and nav bar',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardShellPage), findsOneWidget);
      expect(find.byType(DashboardNavBar), findsOneWidget);
      expect(find.text('Accueil'), findsWidgets);
    });

    testWidgets('switches to Scénarios branch on tap', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Scénarios'));
      await tester.pumpAndSettle();

      expect(testRouter.state.matchedLocation, AppRoutes.library);
      expect(find.byType(LibraryPage), findsOneWidget);
    });

    testWidgets('switches to Historique branch on tap', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      expect(testRouter.state.matchedLocation, AppRoutes.history);
      expect(find.byType(HistoryPage), findsOneWidget);
    });

    testWidgets('switches to Profil branch on tap', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(testRouter.state.matchedLocation, AppRoutes.profile);
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });
}
