import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/errors.dart';
import '../../../core/utils/utils.dart';
import '../domain/tenant.dart';
import '../domain/tenant_repository.dart';
import '../domain/tenant_validators.dart';
import 'tenant_dao.dart';

/// Implementation of [TenantRepository] using Drift SQLite.
/// Reference: docs/ARCHITECTURE.md section 3 & 4.
class TenantRepositoryImpl implements TenantRepository {
  final TenantDao _dao;

  TenantRepositoryImpl(this._dao);

  Tenant _toDomain(TenantData data) {
    return Tenant(
      id: data.id,
      name: data.name,
      phone: data.phone,
      note: data.note,
      idPhotoPath: data.idPhotoPath,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  TenantsCompanion _toCompanion(Tenant tenant) {
    return TenantsCompanion(
      id: Value(tenant.id),
      name: Value(tenant.name),
      phone: Value(tenant.phone),
      note: Value(tenant.note),
      idPhotoPath: Value(tenant.idPhotoPath),
      createdAt: Value(tenant.createdAt),
      updatedAt: Value(tenant.updatedAt),
      deletedAt: Value(tenant.deletedAt),
    );
  }

  /// Converts a [DateTime] to Asia/Jakarta (UTC+7) calendar date (year, month, day).
  static DateTime toJakartaDate(DateTime dt) {
    final jakarta = dt.toUtc().add(const Duration(hours: 7));
    return DateTime(jakarta.year, jakarta.month, jakarta.day);
  }

  /// Pure calculation of [TenantStatus] for a tenant given their occupancies, charges, and payments.
  /// Priority: overdue > active > ended > unassigned.
  static TenantStatus calculateStatus({
    required List<OccupancyData> occupancies,
    required List<ChargeData> charges,
    required Map<String, int> paymentsMap,
    DateTime? asOf,
  }) {
    if (occupancies.isEmpty) {
      return TenantStatus.unassigned;
    }

    final nowUtc = DateTime.now().toUtc();
    final asOfJakarta = asOf != null
        ? toJakartaDate(asOf)
        : toJakartaDate(nowUtc);

    // 1. Overdue check: any non-deleted charge with due_date strictly before asOf date and totalPaid < amount
    for (final charge in charges) {
      final dueJakarta = toJakartaDate(charge.dueDate);
      if (dueJakarta.isBefore(asOfJakarta)) {
        final totalPaid = paymentsMap[charge.id] ?? 0;
        if (totalPaid < charge.amount) {
          return TenantStatus.overdue;
        }
      }
    }

    // 2. Active check: any non-deleted occupancy with status == 'active'
    if (occupancies.any((o) => o.status == 'active')) {
      return TenantStatus.active;
    }

    // 3. Ended check: occupancies exist but all are ended
    return TenantStatus.ended;
  }

  @override
  Stream<List<Tenant>> watchAll({String? propertyFilter}) {
    return _dao
        .watchAllTenants(propertyFilter: propertyFilter)
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<Tenant>> getAll({String? propertyFilter}) async {
    final list = await _dao.getAllTenants(propertyFilter: propertyFilter);
    return list.map(_toDomain).toList();
  }

  @override
  Stream<List<TenantWithStatus>> watchAllWithStatus({
    String? propertyFilter,
    DateTime? asOf,
  }) {
    return _dao.watchStatusChanges(
      () => getAllWithStatus(propertyFilter: propertyFilter, asOf: asOf),
    );
  }

  @override
  Future<List<TenantWithStatus>> getAllWithStatus({
    String? propertyFilter,
    DateTime? asOf,
  }) async {
    final tenantDataList = await _dao.getAllTenants(
      propertyFilter: propertyFilter,
    );
    if (tenantDataList.isEmpty) return [];

    final tenantIds = tenantDataList.map((t) => t.id).toList();

    // Batch query occupancies
    final occupancies = await _dao.getOccupanciesForTenants(tenantIds);
    final occupanciesByTenant = <String, List<OccupancyData>>{};
    final allOccupancyIds = <String>[];
    for (final occ in occupancies) {
      occupanciesByTenant.putIfAbsent(occ.tenantId, () => []).add(occ);
      allOccupancyIds.add(occ.id);
    }

    // Batch query charges
    final charges = await _dao.getChargesForOccupancies(allOccupancyIds);
    final chargesByOccupancy = <String, List<ChargeData>>{};
    final allChargeIds = <String>[];
    for (final charge in charges) {
      chargesByOccupancy.putIfAbsent(charge.occupancyId, () => []).add(charge);
      allChargeIds.add(charge.id);
    }

    // Batch query payments
    final paymentsMap = await _dao.getPaymentsTotalForCharges(allChargeIds);

    return tenantDataList.map((tenantData) {
      final tenant = _toDomain(tenantData);
      final tenantOccs = occupanciesByTenant[tenant.id] ?? const [];

      final tenantCharges = <ChargeData>[];
      for (final occ in tenantOccs) {
        final occCharges = chargesByOccupancy[occ.id];
        if (occCharges != null) {
          tenantCharges.addAll(occCharges);
        }
      }

      final status = calculateStatus(
        occupancies: tenantOccs,
        charges: tenantCharges,
        paymentsMap: paymentsMap,
        asOf: asOf,
      );

      return TenantWithStatus(tenant: tenant, status: status);
    }).toList();
  }

  @override
  Future<Tenant?> getById(String id) async {
    final data = await _dao.getTenantById(id);
    if (data == null) return null;
    return _toDomain(data);
  }

  @override
  Future<TenantWithStatus?> getByIdWithStatus(
    String id, {
    DateTime? asOf,
  }) async {
    final tenant = await getById(id);
    if (tenant == null) return null;

    final occupancies = await _dao.getOccupanciesForTenants([id]);
    final occupancyIds = occupancies.map((o) => o.id).toList();
    final charges = await _dao.getChargesForOccupancies(occupancyIds);
    final chargeIds = charges.map((c) => c.id).toList();
    final paymentsMap = await _dao.getPaymentsTotalForCharges(chargeIds);

    final status = calculateStatus(
      occupancies: occupancies,
      charges: charges,
      paymentsMap: paymentsMap,
      asOf: asOf,
    );

    return TenantWithStatus(tenant: tenant, status: status);
  }

  @override
  Future<void> create(Tenant tenant) async {
    final validName = TenantValidators.validateName(tenant.name);
    final validPhone = TenantValidators.normalizePhone(tenant.phone);
    final id = tenant.id.isEmpty ? generateUuid() : tenant.id;
    final now = DateTime.now().toUtc();

    final validated = tenant.copyWith(
      id: id,
      name: validName,
      phone: validPhone,
      createdAt: now,
      updatedAt: now,
    );

    await _dao.insertTenant(_toCompanion(validated));
  }

  @override
  Future<void> update(Tenant tenant) async {
    final validName = TenantValidators.validateName(tenant.name);
    final validPhone = TenantValidators.normalizePhone(tenant.phone);
    final now = DateTime.now().toUtc();

    final validated = tenant.copyWith(
      name: validName,
      phone: validPhone,
      updatedAt: now,
    );

    await _dao.updateTenant(_toCompanion(validated));
  }

  @override
  Future<void> softDelete(String id) async {
    final activeCount = await _dao.countActiveOccupancies(id);
    if (activeCount > 0) {
      throw const TenantHasActiveOccupancyException(
        'Penyewa tidak dapat dihapus karena masih menempati kamar (hunian aktif).',
      );
    }

    // TODO(F1.4b): File foto ikut dihapus dari penyimpanan lokal saat softDelete penyewa.
    final now = DateTime.now().toUtc();
    await _dao.softDeleteTenant(id, now);
  }
}
