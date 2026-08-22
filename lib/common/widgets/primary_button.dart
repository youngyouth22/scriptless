import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_typography.dart';

/// Un bouton principal réutilisable avec un style cohérent.
///
/// [text] Le texte à afficher sur le bouton.
/// [onPressed] L'action à exécuter au clic. Si null, le bouton sera désactivé.
/// [isLoading] Si true, affiche un indicateur de chargement à la place du texte
/// [icon] Une icône optionnelle à afficher à côté du texte.
class PrimaryButton extends StatelessWidget {
  /// default constructor
  const PrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 100,
    this.height = 48,
    this.width = double.infinity,
    this.textStyle,
  });

  /// The text to display on the button.
  final String text;

  /// The callback to execute when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// An optional icon to display next to the text.
  final Widget? icon;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The text color of the button.
  final Color? textColor;

  /// The border radius of the button.
  final double borderRadius;

  /// The height of the button.
  final double height;

  /// The width of the button.
  final double width;

  /// The text style of the button.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.purpleHard,
          foregroundColor: textColor ?? AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style:
                    textStyle ??
                    AppTypography.bodyLBold.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}
