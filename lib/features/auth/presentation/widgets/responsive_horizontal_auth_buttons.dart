import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/features/auth/presentation/models/auth_method.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_method_buttons.dart';
import 'package:scriptless/features/auth/presentation/widgets/auth_method_icon_buttons.dart';

/// Responsive widget that displays auth buttons horizontally as icon buttons
/// or vertically as full buttons depending on the screen width breakpoint.
class ResponsiveHorizontalAuthButtons extends StatelessWidget {
  /// Creates a [ResponsiveHorizontalAuthButtons] widget.
  const ResponsiveHorizontalAuthButtons({
    super.key,
    this.methods = const [
      AuthMethodType.google,
      AuthMethodType.twitter,
      AuthMethodType.linkedIn,
    ],
    this.action = AuthActionType.signUp,
    this.breakpoint = 300,
    this.spacing = AppSpacing.spacing8,
    this.onEmailPressed,
  });

  /// The list of auth methods to display.
  final List<AuthMethodType> methods;

  /// Action intent when displayed as full buttons.
  final AuthActionType action;

  /// Width breakpoint below which full vertical buttons are used.
  final double breakpoint;

  /// Spacing between buttons.
  final double spacing;

  /// Optional callback to override email tap.
  final VoidCallback? onEmailPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return AuthMethodIconButtons(
            methods: methods,
            spacing: spacing,
            onEmailPressed: onEmailPressed,
          );
        }

        return AuthMethodButtons(
          methods: methods,
          action: action,
          spacing: spacing,
          onEmailPressed: onEmailPressed,
        );
      },
    );
  }
}
