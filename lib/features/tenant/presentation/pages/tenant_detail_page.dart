import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/tenant_providers.dart';
import '../widgets/tenant_status_chip.dart';

/// Detail page displaying comprehensive tenant information, occupancy history, and payment history.
/// Route: `/tenants/:id`.
/// Reference: docs/DESIGN.md & docs/prd.md section 6.1.
class TenantDetailPage extends ConsumerStatefulWidget {
  final String id;

  const TenantDetailPage({super.key, required this.id});

  @override
  ConsumerState<TenantDetailPage> createState() => _TenantDetailPageState();
}

class _TenantDetailPageState extends ConsumerState<TenantDetailPage> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: AppStrings.deleteTenantTitle,
      message: AppStrings.deleteTenantConfirmMessage,
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.cancel,
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final repo = ref.read(tenantRepositoryProvider);
      // Soft delete tenant in database
      // TODO(F1.4b): File foto KTP ikut dihapus dari penyimpanan perangkat saat soft delete
      await repo.softDelete(widget.id);

      if (mounted) {
        context.pop();
        AppSnackbar.show(
          context,
          message: AppStrings.tenantDeletedSuccess,
          type: SnackbarType.success,
        );
      }
    } on TenantHasActiveOccupancyException {
      if (mounted) {
        setState(() => _isDeleting = false);
        await ConfirmDialog.show(
          context: context,
          title: AppStrings.cannotDeleteTenantTitle,
          message: AppStrings.cannotDeleteTenantMessage,
          confirmLabel: AppStrings.understandAction,
          showCancel: false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        AppSnackbar.show(
          context,
          message: e.toString(),
          type: SnackbarType.error,
        );
      }
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final kosM = context.kosMColors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kosM.surfaceMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: kosM.surfaceMuted,
                  borderRadius: AppRadius.inputRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: kosM.surfaceMuted,
                  borderRadius: AppRadius.chipRadius,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: kosM.surfaceMuted,
                  borderRadius: AppRadius.inputRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: kosM.surfaceMuted,
                  borderRadius: AppRadius.inputRadius,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final kosM = context.kosMColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.statusOverdueText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.loadTenantsError,
              style: AppTextStyles.heading.copyWith(color: kosM.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: AppStrings.retry,
              onPressed: () => ref.invalidate(tenantDetailProvider(widget.id)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantAsync = ref.watch(tenantDetailProvider(widget.id));
    final kosM = context.kosMColors;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tenantDetailTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/tenants/${widget.id}/edit');
              } else if (value == 'delete') {
                _handleDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: kosM.textPrimary),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      AppStrings.edit,
                      style: AppTextStyles.body.copyWith(
                        color: kosM.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppColors.statusErrorText,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      AppStrings.delete,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.statusErrorText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (tenantAsync.hasError) {
            return _buildErrorState(context, ref, tenantAsync.error!);
          }

          if (tenantAsync.isLoading) {
            return _buildLoadingSkeleton(context);
          }

          final tenantWithStatus = tenantAsync.value;

          // If tenant not found or soft-deleted
          if (tenantWithStatus == null) {
            // Guard: during deletion, pop is underway; do NOT momentarily flash 404
            if (_isDeleting) {
              return const SizedBox.shrink();
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: EmptyState(
                  icon: Icons.person_off_rounded,
                  title: AppStrings.tenantNotFoundTitle,
                  description: AppStrings.tenantNotFoundDesc,
                  actionLabel: AppStrings.backToTenantList,
                  onAction: () => context.pop(),
                ),
              ),
            );
          }

          final tenant = tenantWithStatus.tenant;
          final initials = ListTileCard.extractInitials(tenant.name);
          final roomStr = tenantWithStatus.currentRoomNumber != null
              ? '${AppStrings.roomPrefix} ${tenantWithStatus.currentRoomNumber}'
              : AppStrings.noRoomAssigned;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Header Card
                AppCard(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTextStyles.title.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        tenant.name,
                        style: AppTextStyles.title.copyWith(
                          color: kosM.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        roomStr,
                        style: AppTextStyles.body.copyWith(
                          color: kosM.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TenantStatusChip(status: tenantWithStatus.status),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 2. Contact & Info Card
                AppCard(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.infoSectionTitle,
                        style: AppTextStyles.heading.copyWith(
                          color: kosM.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoRow(
                        label: AppStrings.tenantPhoneLabel,
                        value: tenant.phone.isNotEmpty ? tenant.phone : '-',
                        textColor: kosM.textPrimary,
                        labelColor: kosM.textSecondary,
                      ),
                      const Divider(height: AppSpacing.xl),
                      _buildInfoRow(
                        label: AppStrings.tenantNoteLabel,
                        value: (tenant.note != null && tenant.note!.isNotEmpty)
                            ? tenant.note!
                            : '-',
                        textColor: kosM.textPrimary,
                        labelColor: kosM.textSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Occupancy History Section (TODO Fase 2)
                AppCard(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.occupancySectionTitle,
                        style: AppTextStyles.heading.copyWith(
                          color: kosM.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      EmptyState(
                        icon: Icons.meeting_room_outlined,
                        title: AppStrings.noOccupancyTitle,
                        description: AppStrings.noOccupancyDesc,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Payment History Section (TODO Fase 2)
                AppCard(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.paymentSectionTitle,
                        style: AppTextStyles.heading.copyWith(
                          color: kosM.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: AppStrings.noPaymentTitle,
                        description: AppStrings.noPaymentDesc,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: labelColor)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyStrong.copyWith(color: textColor)),
      ],
    );
  }
}
