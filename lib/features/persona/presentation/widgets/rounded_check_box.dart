import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';

/// A rounded checkbox widget.
class RoundedCheckBox extends StatelessWidget {
  /// Indicates if the checkbox is selected.
  const RoundedCheckBox({super.key, this.isSelected = false});

  /// Creates the [RoundedCheckBox].

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.purpleHard : null,
        border: !isSelected
            ? Border.all(color: AppColors.grey200, width: 1.5)
            : null,
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
          : null,
    );
  }
}
