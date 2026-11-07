import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Data Access Object for Tenant queries, cascade lookups, and batch data retrieval.
class TenantDao {
  final AppDatabase _db;

  TenantDao(this._db);

  /// Gets non-deleted tenants matching [propertyFilter] ordered by name ascending, then id ascending.
  /// If [propertyFilter] is null or 'all', returns all tenants.
  /// Otherwise, returns unassigned tenants (no occupancies) plus tenants who have occupancies in the filtered property.
  Future<List<TenantData>> getAllTenants({String? propertyFilter}) async {
    if (propertyFilter == null || propertyFilter == 'all') {
      return (_db.select(_db.tenants)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.asc(t.name),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();
    }

    const query = '''
      SELECT t.* FROM tenants t
      WHERE t.deleted_at IS NULL
        AND (
          NOT EXISTS (
            SELECT 1 FROM occupancies o
            WHERE o.tenant_id = t.id AND o.deleted_at IS NULL
          )
          OR
          EXISTS (
            SELECT 1 FROM occupancies o
            JOIN rooms r ON r.id = o.room_id AND r.deleted_at IS NULL
            JOIN properties p ON p.id = r.property_id AND p.deleted_at IS NULL
            WHERE o.tenant_id = t.id
              AND o.deleted_at IS NULL
              AND p.id = ?
          )
        )
      ORDER BY t.name ASC, t.id ASC
    ''';

    final rows = await _db
        .customSelect(
          query,
          variables: [Variable.withString(propertyFilter)],
          readsFrom: {_db.tenants, _db.occupancies, _db.rooms, _db.properties},
        )
        .get();

    return rows.map((row) => _db.tenants.map(row.data)).toList();
  }

  /// Watches tenants reactively.
  Stream<List<TenantData>> watchAllTenants({String? propertyFilter}) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.tenants, _db.occupancies, _db.rooms, _db.properties},
        )
        .watch()
        .asyncMap((_) => getAllTenants(propertyFilter: propertyFilter));
  }

  /// Watches all data sources needed for tenant status and triggers [fetcher] on any table change.
  Stream<T> watchStatusChanges<T>(Future<T> Function() fetcher) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.tenants,
            _db.occupancies,
            _db.rooms,
            _db.properties,
            _db.charges,
            _db.payments,
          },
        )
        .watch()
        .asyncMap((_) => fetcher());
  }

  /// Gets a specific non-deleted tenant by ID.
  Future<TenantData?> getTenantById(String id) {
    return (_db.select(
      _db.tenants,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// Inserts a new tenant record.
  Future<void> insertTenant(TenantsCompanion companion) {
    return _db.into(_db.tenants).insert(companion);
  }

  /// Updates an existing tenant record.
  Future<void> updateTenant(TenantsCompanion companion) {
    return (_db.update(
      _db.tenants,
    )..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

  /// Soft deletes a tenant by updating deleted_at and updated_at.
  Future<void> softDeleteTenant(String id, DateTime deletedAt) {
    return (_db.update(_db.tenants)..where((t) => t.id.equals(id))).write(
      TenantsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  /// Counts non-deleted active occupancies for a tenant.
  Future<int> countActiveOccupancies(String tenantId) async {
    final countExp = _db.occupancies.id.count();
    final query = _db.selectOnly(_db.occupancies)
      ..addColumns([countExp])
      ..where(
        _db.occupancies.tenantId.equals(tenantId) &
            _db.occupancies.status.equals('active') &
            _db.occupancies.deletedAt.isNull(),
      );

    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Batch fetches non-deleted occupancies for given tenant IDs.
  Future<List<OccupancyData>> getOccupanciesForTenants(
    List<String> tenantIds,
  ) async {
    if (tenantIds.isEmpty) return [];
    return (_db.select(
      _db.occupancies,
    )..where((o) => o.tenantId.isIn(tenantIds) & o.deletedAt.isNull())).get();
  }

  /// Batch fetches non-deleted charges for given occupancy IDs.
  Future<List<ChargeData>> getChargesForOccupancies(
    List<String> occupancyIds,
  ) async {
    if (occupancyIds.isEmpty) return [];
    return (_db.select(_db.charges)..where(
          (c) => c.occupancyId.isIn(occupancyIds) & c.deletedAt.isNull(),
        ))
        .get();
  }

  /// Batch fetches total paid amounts for given charge IDs, returning `Map<String, int>` mapping chargeId to totalPaid.
  Future<Map<String, int>> getPaymentsTotalForCharges(
    List<String> chargeIds,
  ) async {
    if (chargeIds.isEmpty) return {};

    final sumExp = _db.payments.amount.sum();
    final query = _db.selectOnly(_db.payments)
      ..addColumns([_db.payments.chargeId, sumExp])
      ..where(
        _db.payments.chargeId.isIn(chargeIds) & _db.payments.deletedAt.isNull(),
      )
      ..groupBy([_db.payments.chargeId]);

    final rows = await query.get();
    final result = <String, int>{};
    for (final row in rows) {
      final chargeId = row.read(_db.payments.chargeId);
      final totalPaid = row.read(sumExp);
      if (chargeId != null) {
        result[chargeId] = totalPaid ?? 0;
      }
    }
    return result;
  }
}
