import 'package:flutter/material.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/widgets/custom_circular_loading_indicator.dart';

/// Auth button with icon only.
class AuthIconButton extends StatelessWidget {
  /// Default constructor
  const AuthIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 52,
  });

  /// Callback to be executed when the button is pressed
  final VoidCallback? onPressed;

  /// Icon to be displayed on the button
  final Widget icon;

  /// Flag to indicate if the button is loading
  final bool isLoading;

  /// Optional width for the button (defaults to [double.infinity])
  final double? width;

  /// Optional height for the button (defaults to 52)
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: IconButton.outlined(
        icon: isLoading
            ? const CustomCircularLoadingIndicator(
                color: AppColors.purpleHard,
                size: 24,
                strokeWidth: 3,
              )
            : icon,
        onPressed: isLoading ? null : onPressed,
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
