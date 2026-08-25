import 'package:scriptless/common/resources/app_routes.dart';
import 'package:scriptless/common/resources/image_resources.dart';

/// Represents the navigation tabs available in the main application shell.
enum DashboardTab {
  /// Accueil / Home tab (index 0).
  home(
    route: AppRoutes.dashboard,
    label: 'Accueil',
    inactiveIcon: ImageResources.homeIcon,
    activeIcon: ImageResources.homeIconBold,
  ),

  /// Scénarios / Library tab (index 1).
  library(
    route: AppRoutes.library,
    label: 'Scénarios',
    inactiveIcon: ImageResources.libraryIcon,
    activeIcon: ImageResources.libraryIconBold,
  ),

  /// Historique / History tab (index 2).
  history(
    route: AppRoutes.history,
    label: 'Historique',
    inactiveIcon: ImageResources.historyIcon,
    activeIcon: ImageResources.historyIconBold,
  ),

  /// Profil / Profile tab (index 3).
  profile(
    route: AppRoutes.profile,
    label: 'Profil',
    inactiveIcon: ImageResources.profileIcon,
    activeIcon: ImageResources.profileIconBold,
  );

  const DashboardTab({
    required this.route,
    required this.label,
    required this.inactiveIcon,
    required this.activeIcon,
  });

  /// The canonical route string associated with this tab.
  final String route;

  /// Human-readable label displayed in the navigation bar.
  final String label;

  /// Outlined icon used when the tab is unselected.
  final String inactiveIcon;

  /// Filled icon used when the tab is selected.
  final String activeIcon;

  /// Resolves a [DashboardTab] from an integer index, defaulting to [home].
  static DashboardTab fromIndex(int index) {
    if (index < 0 || index >= DashboardTab.values.length) {
      return DashboardTab.home;
    }
    return DashboardTab.values[index];
  }
}
