import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_spacing.dart';
import 'package:scriptless/common/resources/app_typography.dart';
import 'package:scriptless/common/resources/image_resources.dart';
import 'package:scriptless/common/widgets/label_text.dart';

/// A custom text field with label and password toggle.
class CustomTextField extends StatefulWidget {
  /// A custom text field with label and password toggle.
  const CustomTextField({
    required this.hintText,
    required this.controller,
    super.key,
    this.labelText,
    this.validator,
    this.titleColor,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.isHour = false,
    this.isNumberField = false,
    this.autoFocus = false,
    this.keyboardType,
    this.isPassword = false,
    this.readOnly = false,
    this.isRequired = false,
    this.formatNumber = true,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.suffixIcon,
    this.titleStyle,
    this.contentPadding,
    this.constraintValue,
  });

  /// Label text for the text field.
  final String? labelText;

  /// Hint text for the text field.
  final String hintText;

  /// Color of the label text.
  final Color? titleColor;

  /// Callback for when the text field is tapped.
  final VoidCallback? onTap;

  /// Controller for the text field.
  final TextEditingController controller;

  /// Text input action for the text field.
  final TextInputAction? textInputAction;

  /// Keyboard type for the text field.
  final TextInputType? keyboardType;

  /// Whether the text field is a password field.
  final bool isPassword;

  /// Whether the text field is a number field.
  final bool isNumberField;

  /// Whether the text field is read only.
  final bool readOnly;

  /// Whether the text field is auto focused.
  final bool autoFocus;

  /// Whether the text field is an hour field.
  final bool isHour;

  /// Whether the text field is required.
  final bool isRequired;

  /// Whether the text field is formatted as a number.
  final bool formatNumber;

  /// Validator for the text field.
  final String? Function(String?)? validator;

  /// Maximum number of lines for the text field.
  final int? maxLines;

  /// Minimum number of lines for the text field.
  final int? minLines;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Callback for when the text field is changed.
  final void Function(String)? onChanged;

  /// Suffix icon for the text field.
  final Widget? suffixIcon;

  /// Style for the label text.
  final TextStyle? titleStyle;

  /// Content padding for the text field.
  final EdgeInsetsGeometry? contentPadding;

  /// Constraint value for the text field.
  final double? constraintValue;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.constraintValue ?? 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.spacing4,
        children: [
          if (widget.labelText != null) LabelText(text: widget.labelText!),
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            errorBuilder: buildErrorWidget,
            autofocus: widget.autoFocus,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines ?? 1,
            onChanged: widget.onChanged,
            style: AppTypography.bodyMSemiBold.copyWith(
              color: AppColors.grey950,
            ),
            obscureText: widget.isPassword && isObscure,
            textInputAction: widget.textInputAction,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            onTap: widget.readOnly ? widget.onTap : null,
            decoration: InputDecoration(
              contentPadding: widget.contentPadding,
              hintText: widget.hintText,
              suffixIcon: (widget.suffixIcon != null)
                  ? widget.suffixIcon
                  : widget.isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: SvgPicture.asset(
                        isObscure
                            ? ImageResources.eyeOpenIcon
                            : ImageResources.eyeCloseIcon,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey950,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Build error widget for text field validation errors
Widget buildErrorWidget(BuildContext context, String error) {
  return Row(
    spacing: 5,
    children: [
      SvgPicture.asset(
        ImageResources.alertIcon,
        colorFilter: const ColorFilter.mode(AppColors.red, BlendMode.srcIn),
      ),
      Expanded(
        child: Text(
          error,
          style: const TextStyle(
            color: AppColors.red,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}
