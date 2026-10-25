import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PropertyItem {
  final String id;
  final String name;
  final String? address;

  const PropertyItem({required this.id, required this.name, this.address});
}

/// KosM standard property switcher component for AppBar.
/// Specification: dropdown in AppBar (active property name + chevron), bottom sheet selection with "Semua Kos".
class PropertySwitcher extends StatelessWidget {
  final String activePropertyId;
  final List<PropertyItem> properties;
  final ValueChanged<String> onSelected;

  const PropertySwitcher({
    super.key,
    required this.activePropertyId,
    required this.properties,
    required this.onSelected,
  });

  String get _activePropertyName {
    if (activePropertyId == 'all') {
      return 'Semua Kos';
    }
    final match = properties.where((p) => p.id == activePropertyId);
    if (match.isNotEmpty) {
      return match.first.name;
    }
    return 'Pilih Kos';
  }

  void _showPickerBottomSheet(BuildContext context) {
    final kosM = context.kosMColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kosM.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Pilih Kos',
                  style: AppTextStyles.title.copyWith(color: kosM.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Data kamar, penyewa, dan tagihan akan disesuaikan',
                  style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                // "Semua Kos" Option
                _buildOptionTile(
                  context: bottomSheetContext,
                  id: 'all',
                  title: 'Semua Kos',
                  subtitle: 'Tampilan gabungan seluruh properti kos',
                  icon: Icons.apartment_rounded,
                  isSelected: activePropertyId == 'all',
                ),
                const Divider(height: 1),
                // Properties list
                ...properties.map(
                  (prop) => _buildOptionTile(
                    context: bottomSheetContext,
                    id: prop.id,
                    title: prop.name,
                    subtitle: prop.address ?? 'Tidak ada alamat',
                    icon: Icons.home_work_rounded,
                    isSelected: activePropertyId == prop.id,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelected(id);
      },
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : kosM.surfaceMuted,
                borderRadius: AppRadius.buttonRadius,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : kosM.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : kosM.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(
                      color: kosM.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.buttonRadius,
      child: InkWell(
        onTap: () => _showPickerBottomSheet(context),
        borderRadius: AppRadius.buttonRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
            minWidth: AppSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    _activePropertyName,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      color: kosM.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kosM.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
