import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/features/dashboard/presentation/widgets/dashboard_nav_bar.dart';

/// Root shell widget hosting the persistent [DashboardNavBar]
/// and active tab branch.
class DashboardShellPage extends StatelessWidget {
  /// Creates a [DashboardShellPage].
  const DashboardShellPage({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // If tapping the active tab, reset branch to initial location.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      
      bottomNavigationBar: DashboardNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
