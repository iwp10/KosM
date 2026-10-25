import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum SnackbarType { info, success, error }

/// KosM standard snackbar component.
/// Specification: floating, radius 12, duration 3 seconds.
abstract class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (type) {
      case SnackbarType.info:
        bgColor = AppColors.textPrimary;
        fgColor = Colors.white;
        icon = Icons.info_outline_rounded;
        break;
      case SnackbarType.success:
        bgColor = AppColors.statusPaidText;
        fgColor = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.error:
        bgColor = AppColors.statusOverdueText;
        fgColor = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.snackbarRadius),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      content: Row(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: fgColor),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: fgColor,
              onPressed: onAction,
            )
          : null,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}
