import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// KosM standard primary button component.
/// Specification: height 52, radius 12, full width, primary color.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    final child = isLoading
        ? SizedBox(
            height: AppSpacing.xl,
            width: AppSpacing.xl,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: isEnabled
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ],
          );

    final button = ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(isFullWidth ? double.infinity : 0, 52),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      child: child,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: 52, child: button);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 52,
        minWidth: AppSpacing.minTouchTarget,
      ),
      child: button,
    );
  }
}
