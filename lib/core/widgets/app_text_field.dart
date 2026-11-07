import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// KosM standard text field component.
/// Specification: radius 12, label on top, error message in red below.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.maxLengthEnforcement,
    this.enabled = true,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final kosM = context.kosMColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: kosM.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          maxLengthEnforcement: maxLengthEnforcement,
          enabled: enabled,
          validator: validator,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          onTap: onTap,
          readOnly: readOnly,
          style: AppTextStyles.body.copyWith(color: kosM.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.body.copyWith(
              color: kosM.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
