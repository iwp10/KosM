import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum StatusType {
  full,
  partial,
  vacant,
  maintenance,
  paid,
  unpaid,
  overdue,
  error,
}

/// KosM standard status chip component.
/// Specification: pill, background & text per status table, label 12/500.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType? type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusChip({
    super.key,
    required this.label,
    this.type,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  factory StatusChip.fromType(
    StatusType type, {
    String? customLabel,
    IconData? icon,
  }) {
    switch (type) {
      case StatusType.full:
        return StatusChip(
          label: customLabel ?? 'Penuh',
          type: type,
          icon: icon,
          backgroundColor: AppColors.statusFullBg,
          textColor: AppColors.statusFullText,
        );
      case StatusType.partial:
        return StatusChip(
          label: customLabel ?? 'Terisi Sebagian',
          type: type,
          icon: icon,
          backgroundColor: AppColors.statusPartialBg,
          textColor: AppColors.statusPartialText,
        );
      case StatusType.vacant:
        return StatusChip(
          label: customLabel ?? 'Kosong',
          type: type,
          icon: icon,
          backgroundColor: AppColors.statusVacantBg,
          textColor: AppColors.statusVacantText,
        );
      case StatusType.maintenance:
        return StatusChip(
          label: customLabel ?? 'Perbaikan',
          type: type,
          icon: icon,
          backgroundColor: AppColors.statusMaintenanceBg,
          textColor: AppColors.statusMaintenanceText,
        );
      case StatusType.paid:
        return StatusChip(
          label: customLabel ?? 'Lunas',
          type: type,
          icon: icon ?? Icons.check_circle_outline_rounded,
          backgroundColor: AppColors.statusPaidBg,
          textColor: AppColors.statusPaidText,
        );
      case StatusType.unpaid:
        return StatusChip(
          label: customLabel ?? 'Belum Bayar',
          type: type,
          icon: icon ?? Icons.schedule_rounded,
          backgroundColor: AppColors.statusUnpaidBg,
          textColor: AppColors.statusUnpaidText,
        );
      case StatusType.overdue:
        return StatusChip(
          label: customLabel ?? 'Menunggak',
          type: type,
          icon: icon ?? Icons.error_outline_rounded,
          backgroundColor: AppColors.statusOverdueBg,
          textColor: AppColors.statusOverdueText,
        );
      case StatusType.error:
        return StatusChip(
          label: customLabel ?? 'Error',
          type: type,
          icon: icon ?? Icons.warning_amber_rounded,
          backgroundColor: AppColors.statusErrorBg,
          textColor: AppColors.statusErrorText,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg = backgroundColor ?? AppColors.primaryContainer;
    Color fg = textColor ?? AppColors.onPrimaryContainer;

    if (type != null && backgroundColor == null && textColor == null) {
      switch (type!) {
        case StatusType.full:
          bg = AppColors.statusFullBg;
          fg = AppColors.statusFullText;
          break;
        case StatusType.partial:
          bg = AppColors.statusPartialBg;
          fg = AppColors.statusPartialText;
          break;
        case StatusType.vacant:
          bg = AppColors.statusVacantBg;
          fg = AppColors.statusVacantText;
          break;
        case StatusType.maintenance:
          bg = AppColors.statusMaintenanceBg;
          fg = AppColors.statusMaintenanceText;
          break;
        case StatusType.paid:
          bg = AppColors.statusPaidBg;
          fg = AppColors.statusPaidText;
          break;
        case StatusType.unpaid:
          bg = AppColors.statusUnpaidBg;
          fg = AppColors.statusUnpaidText;
          break;
        case StatusType.overdue:
          bg = AppColors.statusOverdueBg;
          fg = AppColors.statusOverdueText;
          break;
        case StatusType.error:
          bg = AppColors.statusErrorBg;
          fg = AppColors.statusErrorText;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chipRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
