import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_typography.dart';

/// Label text widget
class LabelText extends StatelessWidget {
  /// Default constructor
  const LabelText({
    required this.text,
    this.isRequired = false,
    super.key,
  });

  /// Text to be displayed on the label
  final String text;

  /// Flag to indicate if the label is required
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTypography.bodyMMedium.copyWith(
            overflow: TextOverflow.ellipsis,
            color: AppColors.grey950,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.red,
                ),
              ),
            // if (widget.messageTooltip != null)
            //   WidgetSpan(
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 5),
            //       child: InfosTooltip(
            //         title: widget.title ?? 'Information importante'
            //         message: widget.messageTooltip!,
            //       ),
            //     ),
            //   )
          ],
        ),
      ),
    );
  }
}
