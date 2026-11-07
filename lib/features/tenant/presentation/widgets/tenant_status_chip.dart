import 'package:flutter/material.dart';

import '../../../../core/strings/strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/tenant.dart';

/// Data class holding UI label and variant for tenant status chip.
class TenantStatusChipData {
  final String label;
  final StatusType type;

  const TenantStatusChipData({required this.label, required this.type});
}

/// Pure helper mapping [TenantStatus] to chip label and [StatusType].
TenantStatusChipData getTenantStatusChipData(TenantStatus status) {
  switch (status) {
    case TenantStatus.overdue:
      return const TenantStatusChipData(
        label: AppStrings.statusOverdue,
        type: StatusType.overdue,
      );
    case TenantStatus.active:
      return const TenantStatusChipData(
        label: AppStrings.statusActive,
        type: StatusType.neutral,
      );
    case TenantStatus.ended:
      return const TenantStatusChipData(
        label: AppStrings.statusEnded,
        type: StatusType.neutral,
      );
    case TenantStatus.unassigned:
      return const TenantStatusChipData(
        label: AppStrings.statusUnassigned,
        type: StatusType.neutral,
      );
  }
}

/// Standard KosM status chip for a [TenantStatus].
/// Single status chip per card/detail header:
/// - Menunggak: danger/overdue (merah)
/// - Aktif: neutral (netral)
/// - Keluar: neutral (netral)
/// - Belum Menghuni: neutral (netral)
class TenantStatusChip extends StatelessWidget {
  final TenantStatus status;

  const TenantStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final chipData = getTenantStatusChipData(status);
    return StatusChip.fromType(chipData.type, customLabel: chipData.label);
  }
}
