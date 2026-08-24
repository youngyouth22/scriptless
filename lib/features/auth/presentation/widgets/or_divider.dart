import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/widgets/dotted_divider.dart';

/// A widget that displays a horizontal divider with the
/// text "Or" in the middle.
class OrDivider extends StatelessWidget {
  /// Creates a [OrDivider].
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        const Expanded(child: DottedDivider()),
        Text(
          'Or',
          style: AppTypography.bodyLRegular.copyWith(
            color: AppColors.grey400,
          ),
        ),
        const Expanded(child: DottedDivider()),
      ],
    );
  }
}
