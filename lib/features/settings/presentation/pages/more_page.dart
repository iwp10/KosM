import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Screen for the 5th tab (Lainnya).
/// Shows menu options where "Kelola Kos" is active and others are disabled ("Segera hadir").
/// Reference: docs/DESIGN.md section 6 & ARCHITECTURE.md section 6.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.moreMenuTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.md,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              AppStrings.moreMenuDesc,
              style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Active menu: Kelola Kos
          AppCard(
            onTap: () => context.push('/more/properties'),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: AppRadius.buttonRadius,
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.manageProperties,
                        style: AppTextStyles.heading.copyWith(
                          color: kosM.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.menuManagePropertiesDesc,
                        style: AppTextStyles.label.copyWith(
                          color: kosM.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: kosM.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Inactive menus
          _buildDisabledCard(
            context: context,
            icon: Icons.notifications_outlined,
            title: AppStrings.menuReminders,
            subtitle: AppStrings.menuRemindersDesc,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDisabledCard(
            context: context,
            icon: Icons.file_download_outlined,
            title: AppStrings.menuExport,
            subtitle: AppStrings.menuExportDesc,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDisabledCard(
            context: context,
            icon: Icons.cloud_upload_outlined,
            title: AppStrings.menuBackup,
            subtitle: AppStrings.menuBackupDesc,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDisabledCard(
            context: context,
            icon: Icons.person_outline_rounded,
            title: AppStrings.menuProfile,
            subtitle: AppStrings.menuProfileDesc,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDisabledCard(
            context: context,
            icon: Icons.tune_rounded,
            title: AppStrings.menuPreferences,
            subtitle: AppStrings.menuPreferencesDesc,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildDisabledCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final kosM = context.kosMColors;

    return Opacity(
      opacity: 0.6,
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kosM.surfaceMuted,
                borderRadius: AppRadius.buttonRadius,
              ),
              child: Icon(icon, color: kosM.textTertiary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.heading.copyWith(
                            color: kosM.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: kosM.surfaceMuted,
                          borderRadius: AppRadius.chipRadius,
                        ),
                        child: Text(
                          AppStrings.comingSoon,
                          style: AppTextStyles.label.copyWith(
                            color: kosM.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(
                      color: kosM.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
