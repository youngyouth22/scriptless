import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/features/dashboard/domain/entities/dashboard_tab.dart';
import 'package:scriptless/features/dashboard/presentation/widgets/dashboard_nav_bar.dart';

void main() {
  group('DashboardNavBar', () {
    Widget buildTestWidget({
      required int currentIndex,
      required ValueChanged<int> onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: DashboardNavBar(
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders all 4 tabs with their labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (_) {},
        ),
      );

      for (final tab in DashboardTab.values) {
        expect(find.text(tab.label), findsOneWidget);
      }
    });

    testWidgets('displays active icon for selected tab and inactive for others',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (_) {},
        ),
      );

      // Tab 0 (Home) should show active icon
      expect(find.byIcon(DashboardTab.home.activeIcon), findsOneWidget);
      expect(find.byIcon(DashboardTab.home.inactiveIcon), findsNothing);

      // Other tabs should show inactive icons
      expect(find.byIcon(DashboardTab.library.inactiveIcon), findsOneWidget);
      expect(find.byIcon(DashboardTab.history.inactiveIcon), findsOneWidget);
      expect(find.byIcon(DashboardTab.profile.inactiveIcon), findsOneWidget);
    });

    testWidgets('triggers onTap callback with correct index when tab is tapped',
        (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      );

      // Tap Scénarios tab (index 1)
      await tester.tap(find.text('Scénarios'));
      await tester.pump();
      expect(tappedIndex, 1);

      // Tap Historique tab (index 2)
      await tester.tap(find.text('Historique'));
      await tester.pump();
      expect(tappedIndex, 2);

      // Tap Profil tab (index 3)
      await tester.tap(find.text('Profil'));
      await tester.pump();
      expect(tappedIndex, 3);

      // Tap Accueil tab (index 0)
      await tester.tap(find.text('Accueil'));
      await tester.pump();
      expect(tappedIndex, 0);
    });

    testWidgets('applies active color to selected tab label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 1,
          onTap: (_) {},
        ),
      );

      final activeTextWidget = tester.widget<Text>(find.text('Scénarios'));
      expect(activeTextWidget.style?.color, AppColors.purpleHard);

      final inactiveTextWidget = tester.widget<Text>(find.text('Accueil'));
      expect(inactiveTextWidget.style?.color, AppColors.grey400);
    });

    testWidgets('applies translucent background decoration to selected tab',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentIndex: 0,
          onTap: (_) {},
        ),
      );

      // Selected tab 0 has the active background container with
      // purple translucent color
      final activeBackgroundFinder =
          find.byKey(const ValueKey<String>('tab_bg_home_selected'));
      expect(activeBackgroundFinder, findsOneWidget);

      final activeContainer =
          tester.widget<Container>(activeBackgroundFinder);
      final activeDecoration = activeContainer.decoration as BoxDecoration?;
      expect(
        activeDecoration?.color,
        AppColors.purpleHard.withValues(alpha: 0.12),
      );
      expect(activeDecoration?.borderRadius, BorderRadius.circular(100));
    });
  });
}
