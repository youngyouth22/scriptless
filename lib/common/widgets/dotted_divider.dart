import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';

/// A widget that displays a horizontal dotted divider.
/// Uses [LayoutBuilder] to calculate the number of dashes based
/// on the available width.
///
/// Example:
/// ```dart
/// DottedDivider(height: 2, color: Colors.blue)
/// ```
///
/// Default values:
/// - [height]: 1.0
/// - [color]: [AppColors.grey300]
///
/// The widget uses [Flex] with [MainAxisAlignment.spaceBetween]
/// to distribute dashes evenly.
///
/// See also:
/// - [DecoratedBox] - used for drawing individual dashes
/// - [Flex] - used for layout
class DottedDivider extends StatelessWidget {
  /// Creates a [DottedDivider].
  ///
  /// [height] - Height of each dash. Default is 1.
  /// [color] - Color of each dash. Default is [AppColors.grey300].
  const DottedDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.grey300,
  });

  /// The height of each dash.
  final double height;

  /// The color of each dash.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (dashWidth * 2)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
