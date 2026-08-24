import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_button.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_methods_builder.dart';

/// Renders a vertical list of [AuthButton] widgets for the given [methods].
class AuthMethodButtons extends StatelessWidget {
  /// Default constructor for [AuthMethodButtons].
  const AuthMethodButtons({
    super.key,
    this.methods = const [
      AuthMethodType.email,
      AuthMethodType.google,
      AuthMethodType.twitter,
      AuthMethodType.linkedIn,
    ],
    this.action = AuthActionType.signUp,
    this.spacing = AppSpacing.spacing8,
    this.onEmailPressed,
  });

  /// The list of auth methods to display.
  final List<AuthMethodType> methods;

  /// The action intent (e.g. [AuthActionType.signUp], [AuthActionType.signIn]).
  final AuthActionType action;

  /// Spacing between each button.
  final double spacing;

  /// Optional callback to override the email button action.
  final VoidCallback? onEmailPressed;

  @override
  Widget build(BuildContext context) {
    return AuthMethodsBuilder(
      methods: methods,
      action: action,
      onEmailPressed: onEmailPressed,
      builder: (context, items) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              AuthButton(
                text: items[i].label,
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
