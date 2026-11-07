import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_card.dart';

/// KosM standard list tile card component.
/// Specification: avatar inisial 40dp, judul heading, subjudul body secondary, trailing chip di kanan, teks baris bawah keterangan.
/// Reference: docs/DESIGN.md section 7.
class ListTileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? initials;
  final Widget? avatar;
  final Widget? trailing;
  final String? bottomText;
  final VoidCallback? onTap;

  const ListTileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.initials,
    this.avatar,
    this.trailing,
    this.bottomText,
    this.onTap,
  });

  /// Helper to derive 1-2 uppercase initials from a full name.
  static String extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    final derivedInitials = initials ?? extractInitials(title);

    final avatarWidget =
        avatar ??
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: AppRadius.buttonRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            derivedInitials,
            style: AppTextStyles.bodyStrong.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatarWidget,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading.copyWith(
                        color: kosM.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.body.copyWith(
                          color: kosM.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
          if (bottomText != null && bottomText!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              bottomText!,
              style: AppTextStyles.label.copyWith(
                color: kosM.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
