import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/features/dashboard/domain/entities/dashboard_tab.dart';

void main() {
  group('DashboardTab', () {
    test('has exactly 4 tabs in correct order', () {
      expect(DashboardTab.values.length, 4);
      expect(DashboardTab.values[0], DashboardTab.home);
      expect(DashboardTab.values[1], DashboardTab.library);
      expect(DashboardTab.values[2], DashboardTab.history);
      expect(DashboardTab.values[3], DashboardTab.profile);
    });

    test('home tab has correct properties', () {
      expect(DashboardTab.home.index, 0);
      expect(DashboardTab.home.route, AppRoutes.dashboard);
      expect(DashboardTab.home.label, 'Accueil');
      expect(DashboardTab.home.inactiveIcon, Icons.home_outlined);
      expect(DashboardTab.home.activeIcon, Icons.home);
    });

    test('library tab has correct properties', () {
      expect(DashboardTab.library.index, 1);
      expect(DashboardTab.library.route, AppRoutes.library);
      expect(DashboardTab.library.label, 'Scénarios');
      expect(DashboardTab.library.inactiveIcon, Icons.menu_book_outlined);
      expect(DashboardTab.library.activeIcon, Icons.menu_book);
    });

    test('history tab has correct properties', () {
      expect(DashboardTab.history.index, 2);
      expect(DashboardTab.history.route, AppRoutes.history);
      expect(DashboardTab.history.label, 'Historique');
      expect(DashboardTab.history.inactiveIcon, Icons.history_outlined);
      expect(DashboardTab.history.activeIcon, Icons.history);
    });

    test('profile tab has correct properties', () {
      expect(DashboardTab.profile.index, 3);
      expect(DashboardTab.profile.route, AppRoutes.profile);
      expect(DashboardTab.profile.label, 'Profil');
      expect(DashboardTab.profile.inactiveIcon, Icons.person_outline);
      expect(DashboardTab.profile.activeIcon, Icons.person);
    });

    test('fromIndex returns correct tab for valid indices', () {
      expect(DashboardTab.fromIndex(0), DashboardTab.home);
      expect(DashboardTab.fromIndex(1), DashboardTab.library);
      expect(DashboardTab.fromIndex(2), DashboardTab.history);
      expect(DashboardTab.fromIndex(3), DashboardTab.profile);
    });

    test('fromIndex returns home for out-of-bounds indices', () {
      expect(DashboardTab.fromIndex(-1), DashboardTab.home);
      expect(DashboardTab.fromIndex(4), DashboardTab.home);
      expect(DashboardTab.fromIndex(99), DashboardTab.home);
    });
  });
}
