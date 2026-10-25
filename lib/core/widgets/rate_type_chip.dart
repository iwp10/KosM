import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum RateType { daily, weekly, monthly }

/// KosM standard rate type chip component.
/// Specification: neutral chip (outline) 'Harian' / 'Mingguan' / 'Bulanan'.
class RateTypeChip extends StatelessWidget {
  final RateType rateType;
  final bool isSelected;
  final ValueChanged<RateType>? onSelected;

  const RateTypeChip({
    super.key,
    required this.rateType,
    this.isSelected = false,
    this.onSelected,
  });

  String get label {
    switch (rateType) {
      case RateType.daily:
        return 'Harian';
      case RateType.weekly:
        return 'Mingguan';
      case RateType.monthly:
        return 'Bulanan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    final borderColor = isSelected ? theme.colorScheme.primary : kosM.outline;
    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;
    final fgColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : kosM.textSecondary;

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.chipRadius,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: fgColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );

    if (onSelected != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppRadius.chipRadius,
        child: InkWell(
          onTap: () => onSelected!(rateType),
          borderRadius: AppRadius.chipRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}
