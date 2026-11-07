import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../property/presentation/providers/property_providers.dart';
import '../../data/tenant_dao.dart';
import '../../data/tenant_repository_impl.dart';
import '../../domain/tenant.dart';
import '../../domain/tenant_repository.dart';

/// Provider for [TenantDao].
final tenantDaoProvider = Provider<TenantDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TenantDao(db);
});

/// Provider for [TenantRepository].
final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final dao = ref.watch(tenantDaoProvider);
  return TenantRepositoryImpl(dao);
});

/// Filter status options for tenant list.
enum TenantFilter { all, active, overdue, ended }

/// Pure filter function determining whether a tenant matches the selected [TenantFilter].
/// - [TenantFilter.all]: matches all tenants (including unassigned).
/// - [TenantFilter.active]: matches tenants with active occupancy ([hasActiveOccupancy] == true).
/// - [TenantFilter.overdue]: matches tenants with status [TenantStatus.overdue].
/// - [TenantFilter.ended]: matches tenants who are no longer active ([hasActiveOccupancy] == false)
///   and either ended or overdue without active occupancy.
/// - Unassigned tenants only appear in [TenantFilter.all].
bool matchesFilter(TenantWithStatus tenant, TenantFilter filter) {
  switch (filter) {
    case TenantFilter.all:
      return true;
    case TenantFilter.active:
      return tenant.hasActiveOccupancy;
    case TenantFilter.overdue:
      return tenant.status == TenantStatus.overdue;
    case TenantFilter.ended:
      return !tenant.hasActiveOccupancy &&
          (tenant.status == TenantStatus.ended ||
              tenant.status == TenantStatus.overdue);
  }
}

/// Pure search function matching name, room number, or phone number.
/// - Name: case-insensitive substring.
/// - Room number: case-insensitive substring.
/// - Phone: only checked if [query] contains at least 4 digits after stripping non-digits.
///   Leading '0' in query is normalized to '62'.
///   Query "03" has < 4 digits and does not match phone numbers (but may match room "03").
bool matchesSearch(TenantWithStatus tenantWithStatus, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return true;

  final lowerQuery = trimmed.toLowerCase();

  // 1. Name match
  if (tenantWithStatus.tenant.name.toLowerCase().contains(lowerQuery)) {
    return true;
  }

  // 2. Room number match
  final roomNumber = tenantWithStatus.currentRoomNumber;
  if (roomNumber != null && roomNumber.toLowerCase().contains(lowerQuery)) {
    return true;
  }

  // 3. Phone match (only when query has >= 4 digits after removing non-digits)
  final tenantPhone = tenantWithStatus.tenant.phone;
  if (tenantPhone.isNotEmpty) {
    final queryDigits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (queryDigits.length >= 4) {
      final normalizedQueryDigits = queryDigits.startsWith('0')
          ? '62${queryDigits.substring(1)}'
          : queryDigits;

      final tenantDigits = tenantPhone.replaceAll(RegExp(r'\D'), '');
      final normalizedTenantDigits = tenantDigits.startsWith('0')
          ? '62${tenantDigits.substring(1)}'
          : tenantDigits;

      if (normalizedTenantDigits.contains(normalizedQueryDigits)) {
        return true;
      }
    }
  }

  return false;
}

/// Reactive search query notifier.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// Reactive search query string provider.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Selected status filter notifier.
class StatusFilterNotifier extends Notifier<TenantFilter> {
  @override
  TenantFilter build() => TenantFilter.all;

  void setFilter(TenantFilter filter) => state = filter;
}

/// Selected status filter provider.
final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, TenantFilter>(
      StatusFilterNotifier.new,
    );

/// Stream provider for tenants in the active property.
/// Guards against un-resolved active property: stays in loading and does not query prematurely with null.
final tenantListProvider = StreamProvider<List<TenantWithStatus>>((ref) async* {
  final activeProperty = await ref.watch(activePropertyProvider.future);
  final repo = ref.watch(tenantRepositoryProvider);
  final propertyFilter = activeProperty == 'all' ? null : activeProperty;
  yield* repo.watchAllWithStatus(propertyFilter: propertyFilter);
});

/// Tenant count per status filter, computed BEFORE search query is applied.
class TenantChipCounts {
  final int all;
  final int active;
  final int overdue;
  final int ended;

  const TenantChipCounts({
    required this.all,
    required this.active,
    required this.overdue,
    required this.ended,
  });

  const TenantChipCounts.zero() : all = 0, active = 0, overdue = 0, ended = 0;
}

/// Provider computing counts for filter chips based on all tenants in the active property.
final tenantChipCountsProvider = Provider<TenantChipCounts>((ref) {
  final tenants = ref.watch(tenantListProvider).value ?? const [];

  int allCount = tenants.length;
  int activeCount = 0;
  int overdueCount = 0;
  int endedCount = 0;

  for (final t in tenants) {
    if (matchesFilter(t, TenantFilter.active)) activeCount++;
    if (matchesFilter(t, TenantFilter.overdue)) overdueCount++;
    if (matchesFilter(t, TenantFilter.ended)) endedCount++;
  }

  return TenantChipCounts(
    all: allCount,
    active: activeCount,
    overdue: overdueCount,
    ended: endedCount,
  );
});

/// Combined filtered and searched tenants provider.
final filteredTenantsProvider = Provider<List<TenantWithStatus>>((ref) {
  final tenants = ref.watch(tenantListProvider).value ?? const [];
  final filter = ref.watch(statusFilterProvider);
  final query = ref.watch(searchQueryProvider);

  return tenants.where((t) {
    return matchesFilter(t, filter) && matchesSearch(t, query);
  }).toList();
});
