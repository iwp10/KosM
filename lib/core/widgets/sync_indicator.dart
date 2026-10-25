import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum SyncState { synced, waiting, offline, failed }

/// KosM standard sync status indicator.
/// Specification: cloud icon + text: "Tersinkron", "Menunggu sinkron", "Offline", "Gagal, coba lagi".
class SyncIndicator extends StatelessWidget {
  final SyncState state;
  final bool showLabel;
  final VoidCallback? onTap;

  const SyncIndicator({
    super.key,
    required this.state,
    this.showLabel = true,
    this.onTap,
  });

  IconData get icon {
    switch (state) {
      case SyncState.synced:
        return Icons.cloud_done_rounded;
      case SyncState.waiting:
        return Icons.cloud_upload_rounded;
      case SyncState.offline:
        return Icons.cloud_off_rounded;
      case SyncState.failed:
        return Icons.sync_problem_rounded;
    }
  }

  String get label {
    switch (state) {
      case SyncState.synced:
        return 'Tersinkron';
      case SyncState.waiting:
        return 'Menunggu sinkron';
      case SyncState.offline:
        return 'Offline';
      case SyncState.failed:
        return 'Gagal, coba lagi';
    }
  }

  Color get color {
    switch (state) {
      case SyncState.synced:
        return AppColors.syncSynced;
      case SyncState.waiting:
        return AppColors.syncWaiting;
      case SyncState.offline:
        return AppColors.syncOffline;
      case SyncState.failed:
        return AppColors.syncFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}
