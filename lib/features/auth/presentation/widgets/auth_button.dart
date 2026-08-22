import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/widgets/custom_circular_loading_indicator.dart';

/// Auth button with icon and text.
class AuthButton extends StatelessWidget {
  /// Default constructor
  const AuthButton({
    required this.text,
    required this.onPressed,
    required this.icon,
    super.key,
    this.isLoading = false,
  });

  /// Text to be displayed on the button
  final String text;

  /// Callback to be executed when the button is pressed
  final VoidCallback? onPressed;

  /// Icon to be displayed on the button
  final Widget icon;

  /// Flag to indicate if the button is loading
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: isLoading
            ? const CustomCircularLoadingIndicator(
                color: AppColors.purpleHard,
              )
            : icon,
        onPressed: isLoading ? null : onPressed,
        label: Text(
          isLoading ? 'Please wait...' : text,
          style: AppTypography.bodyLMedium.copyWith(
            color: isLoading ? AppColors.purpleHard : AppColors.grey950,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          side: const BorderSide(color: AppColors.grey100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
