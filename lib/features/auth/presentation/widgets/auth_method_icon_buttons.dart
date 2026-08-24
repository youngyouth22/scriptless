import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_icon_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_methods_builder.dart';

/// Renders a horizontal row of [AuthIconButton] widgets for the
/// given [methods].
class AuthMethodIconButtons extends StatelessWidget {
  /// Default constructor for [AuthMethodIconButtons].
  const AuthMethodIconButtons({
    super.key,
    this.methods = const [
      AuthMethodType.google,
      AuthMethodType.twitter,
      AuthMethodType.linkedIn,
    ],
    this.spacing = AppSpacing.spacing12,
    this.expanded = true,
    this.buttonWidth,
    this.onEmailPressed,
  });

  /// The list of auth methods to display (defaults to social OAuth providers).
  final List<AuthMethodType> methods;

  /// Spacing between each icon button.
  final double spacing;

  /// Whether each icon button should be wrapped in an [Expanded] widget.
  final bool expanded;

  /// Optional fixed width for each icon button when [expanded] is false.
  final double? buttonWidth;

  /// Optional callback to override email action (if email is in [methods]).
  final VoidCallback? onEmailPressed;

  @override
  Widget build(BuildContext context) {
    return AuthMethodsBuilder(
      methods: methods,
      onEmailPressed: onEmailPressed,
      builder: (context, items) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              if (expanded)
                Expanded(
                  child: AuthIconButton(
                    isLoading: items[i].isLoading,
                    onPressed: items[i].onPressed,
                    icon: SvgPicture.asset(
                      items[i].iconAssetPath,
                      colorFilter: const ColorFilter.mode(
                        AppColors.grey950,
                        BlendMode.srcIn,
                      ),
                      width: 24,
                    ),
                  ),
                )
              else
                AuthIconButton(
                  width: buttonWidth,
                  isLoading: items[i].isLoading,
                  onPressed: items[i].onPressed,
                  icon: SvgPicture.asset(
                    items[i].iconAssetPath,
                    colorFilter: const ColorFilter.mode(
                      AppColors.grey950,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
