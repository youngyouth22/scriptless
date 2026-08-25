import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/features/dashboard/domain/entities/dashboard_tab.dart';

/// Enterprise-grade bottom navigation bar for the main application shell.
class DashboardNavBar extends StatelessWidget {
  /// Creates a [DashboardNavBar].
  const DashboardNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// The currently active tab index.
  final int currentIndex;

  /// Callback triggered when a tab item is tapped.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.spacing24,
          right: AppSpacing.spacing24,
          bottom: AppSpacing.spacing8,
        ),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: DashboardTab.values.map((tab) {
              final isSelected = tab.index == currentIndex;
              return Expanded(
                child: _NavBarItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => onTap(tab.index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final DashboardTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.purpleHard : AppColors.grey400;

    return Semantics(
      label: tab.label,
      selected: isSelected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: isSelected
                    ? Container(
                        key: ValueKey<String>('tab_bg_${tab.name}_selected'),
                        decoration: BoxDecoration(
                          color: AppColors.purpleHard.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      )
                    : SizedBox.expand(
                        key: ValueKey<String>('tab_bg_${tab.name}_unselected'),
                      ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(100),
                  splashColor: AppColors.purpleLight,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                          child: SvgPicture.asset(
                            isSelected ? tab.activeIcon : tab.inactiveIcon,
                            key: ValueKey<String>(
                              'tab_icon_${tab.name}_$isSelected',
                            ),
                            colorFilter: ColorFilter.mode(
                              color,
                              BlendMode.srcIn,
                            ),
                            width: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tab.label,
                              maxLines: 1,
                              style:
                                  (isSelected
                                          ? AppTypography.bodySSemiBold
                                          : AppTypography.bodySMedium)
                                      .copyWith(
                                        color: color,
                                        fontSize: 10,
                                        height: 1.2,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
