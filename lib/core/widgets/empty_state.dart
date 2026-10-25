import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'primary_button.dart';

/// KosM standard empty state component.
/// Specification: large 48dp gray icon, title, 1 sentence description, optional action button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final kosM = context.kosMColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kosM.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: kosM.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.heading.copyWith(color: kosM.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ] else if (customAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}
