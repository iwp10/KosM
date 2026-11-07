import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/tenant.dart';
import '../providers/tenant_providers.dart';

/// Screen displaying the list of tenants with search, status filtering, and property awareness.
/// F1.1 (Daftar semua penyewa) & F1.3 (Cari & saring penyewa).
/// Reference: docs/DESIGN.md & docs/design/tenants.png.
class TenantListPage extends ConsumerStatefulWidget {
  const TenantListPage({super.key});

  @override
  ConsumerState<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends ConsumerState<TenantListPage> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // Updates clear icon visibility
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(searchQueryProvider.notifier).setQuery(value);
      }
    });
  }

  void _clearSearchAndFilter() {
    _debounceTimer?.cancel();
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).setQuery('');
    ref.read(statusFilterProvider.notifier).setFilter(TenantFilter.all);
    setState(() {});
  }

  Widget _buildStatusChip(TenantStatus status) {
    switch (status) {
      case TenantStatus.overdue:
        return StatusChip.fromType(
          StatusType.overdue,
          customLabel: AppStrings.statusOverdue,
        );
      case TenantStatus.active:
        return StatusChip.fromType(
          StatusType.neutral,
          customLabel: AppStrings.statusActive,
        );
      case TenantStatus.ended:
        return StatusChip.fromType(
          StatusType.neutral,
          customLabel: AppStrings.statusEnded,
        );
      case TenantStatus.unassigned:
        return StatusChip.fromType(
          StatusType.neutral,
          customLabel: AppStrings.statusUnassigned,
        );
    }
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    final borderColor = isSelected ? theme.colorScheme.primary : kosM.outline;
    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;
    final fgColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : kosM.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.chipRadius,
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Text(
            '$label ($count)',
            style: AppTextStyles.label.copyWith(
              color: fgColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final kosM = context.kosMColors;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kosM.surfaceMuted,
                borderRadius: AppRadius.buttonRadius,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: kosM.surfaceMuted,
                      borderRadius: AppRadius.inputRadius,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 90,
                    height: 12,
                    decoration: BoxDecoration(
                      color: kosM.surfaceMuted,
                      borderRadius: AppRadius.inputRadius,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: kosM.surfaceMuted,
                borderRadius: AppRadius.chipRadius,
              ),
            ),
          ],
        ),
      ),
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
              onPressed: () => ref.invalidate(tenantListProvider),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantListAsync = ref.watch(tenantListProvider);
    final chipCounts = ref.watch(tenantChipCountsProvider);
    final selectedFilter = ref.watch(statusFilterProvider);
    final filteredTenants = ref.watch(filteredTenantsProvider);

    return Scaffold(
      appBar: AppBar(title: const PropertyAwareAppBarTitle()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tenants/new'),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(AppStrings.addTenant),
      ),
      body: Builder(
        builder: (context) {
          if (tenantListAsync.hasError) {
            return _buildErrorState(context, ref, tenantListAsync.error!);
          }

          if (tenantListAsync.isLoading) {
            return _buildLoadingSkeleton(context);
          }

          final allTenants = tenantListAsync.value ?? const [];

          // If property has no tenants at all
          if (allTenants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: AppStrings.emptyTenantsTitle,
                  description: AppStrings.emptyTenantsDesc,
                  actionLabel: AppStrings.addTenant,
                  onAction: () => context.push('/tenants/new'),
                ),
              ),
            );
          }

          // When tenants exist, show search bar, filter chips, and list/empty state
          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                ),
                child: AppTextField(
                  controller: _searchController,
                  hintText: AppStrings.searchTenantHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _debounceTimer?.cancel();
                            ref.read(searchQueryProvider.notifier).setQuery('');
                            setState(() {});
                          },
                        )
                      : null,
                  onChanged: _onSearchChanged,
                ),
              ),

              // Filter chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context: context,
                      label: AppStrings.filterAll,
                      count: chipCounts.all,
                      isSelected: selectedFilter == TenantFilter.all,
                      onTap: () {
                        ref
                            .read(statusFilterProvider.notifier)
                            .setFilter(TenantFilter.all);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip(
                      context: context,
                      label: AppStrings.filterActive,
                      count: chipCounts.active,
                      isSelected: selectedFilter == TenantFilter.active,
                      onTap: () {
                        ref
                            .read(statusFilterProvider.notifier)
                            .setFilter(TenantFilter.active);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip(
                      context: context,
                      label: AppStrings.filterOverdue,
                      count: chipCounts.overdue,
                      isSelected: selectedFilter == TenantFilter.overdue,
                      onTap: () {
                        ref
                            .read(statusFilterProvider.notifier)
                            .setFilter(TenantFilter.overdue);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip(
                      context: context,
                      label: AppStrings.filterEnded,
                      count: chipCounts.ended,
                      isSelected: selectedFilter == TenantFilter.ended,
                      onTap: () {
                        ref
                            .read(statusFilterProvider.notifier)
                            .setFilter(TenantFilter.ended);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // List or Empty Search
              Expanded(
                child: filteredTenants.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppSpacing.screenHorizontal,
                          ),
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: AppStrings.noMatchingTenantsTitle,
                            description: AppStrings.noMatchingTenantsDesc,
                            actionLabel: AppStrings.clearSearch,
                            onAction: _clearSearchAndFilter,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.screenHorizontal,
                          right: AppSpacing.screenHorizontal,
                          top: AppSpacing.sm,
                          bottom: AppSpacing.xxl * 3, // space for FAB
                        ),
                        itemCount: filteredTenants.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = filteredTenants[index];
                          final roomStr = item.currentRoomNumber != null
                              ? '${AppStrings.roomPrefix} ${item.currentRoomNumber}'
                              : AppStrings.noRoomAssigned;
                          final subtitle = item.tenant.phone.isNotEmpty
                              ? '$roomStr · ${item.tenant.phone}'
                              : roomStr;

                          return ListTileCard(
                            title: item.tenant.name,
                            subtitle: subtitle,
                            trailing: _buildStatusChip(item.status),
                            bottomText: item.tenant.note,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
