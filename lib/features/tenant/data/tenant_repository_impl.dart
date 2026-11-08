import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/errors.dart';
import '../../../core/utils/utils.dart';
import '../domain/id_photo_storage.dart';
import '../domain/tenant.dart';
import '../domain/tenant_repository.dart';
import '../domain/tenant_validators.dart';
import 'id_photo_storage_impl.dart';
import 'tenant_dao.dart';

/// Implementation of [TenantRepository] using Drift SQLite.
/// Reference: docs/ARCHITECTURE.md section 3 & 4.
class TenantRepositoryImpl implements TenantRepository {
  final TenantDao _dao;
  final IdPhotoStorage _photoStorage;

  TenantRepositoryImpl(this._dao, {IdPhotoStorage? photoStorage})
    : _photoStorage = photoStorage ?? IdPhotoStorageImpl();

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

  /// Resolves the current room number:
  /// - The room number of the active occupancy if available.
  /// - Otherwise, the room number of the most recently ended occupancy.
  /// - Returns `null` if the tenant has never had any occupancies.
  static String? resolveCurrentRoomNumber(
    List<OccupancyData> occupancies,
    Map<String, String> roomNumbersById,
  ) {
    if (occupancies.isEmpty) return null;

    final activeOccupancies = occupancies
        .where((o) => o.status == 'active')
        .toList();
    if (activeOccupancies.isNotEmpty) {
      activeOccupancies.sort((a, b) => b.startDate.compareTo(a.startDate));
      return roomNumbersById[activeOccupancies.first.roomId];
    }

    final sorted = List<OccupancyData>.from(occupancies)
      ..sort((a, b) {
        final aEnd = a.actualEndDate ?? a.plannedEndDate ?? a.startDate;
        final bEnd = b.actualEndDate ?? b.plannedEndDate ?? b.startDate;
        return bEnd.compareTo(aEnd);
      });

    return roomNumbersById[sorted.first.roomId];
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

    // Batch query room numbers
    final allRoomIds = occupancies.map((o) => o.roomId).toSet().toList();
    final roomNumbersById = await _dao.getRoomNumbersByIds(allRoomIds);

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

      final hasActive = tenantOccs.any((o) => o.status == 'active');
      final roomNumber = resolveCurrentRoomNumber(tenantOccs, roomNumbersById);

      return TenantWithStatus(
        tenant: tenant,
        status: status,
        hasActiveOccupancy: hasActive,
        currentRoomNumber: roomNumber,
      );
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

    final allRoomIds = occupancies.map((o) => o.roomId).toSet().toList();
    final roomNumbersById = await _dao.getRoomNumbersByIds(allRoomIds);

    final status = calculateStatus(
      occupancies: occupancies,
      charges: charges,
      paymentsMap: paymentsMap,
      asOf: asOf,
    );

    final hasActive = occupancies.any((o) => o.status == 'active');
    final roomNumber = resolveCurrentRoomNumber(occupancies, roomNumbersById);

    return TenantWithStatus(
      tenant: tenant,
      status: status,
      hasActiveOccupancy: hasActive,
      currentRoomNumber: roomNumber,
    );
  }

  @override
  Stream<TenantWithStatus?> watchByIdWithStatus(String id, {DateTime? asOf}) {
    return _dao.watchStatusChanges(() => getByIdWithStatus(id, asOf: asOf));
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

    final existing = await _dao.getTenantById(id);
    final photoPath = existing?.idPhotoPath;

    final now = DateTime.now().toUtc();
    await _dao.softDeleteTenant(id, now);

    if (photoPath != null) {
      try {
        await _photoStorage.deletePhoto(photoPath);
      } catch (e) {
        debugPrint('Gagal menghapus file foto saat softDelete penyewa: $e');
      }
    }
  }

  @override
  Future<void> saveTenant(
    Tenant tenant, {
    String? newPhotoTempPath,
    bool removePhoto = false,
  }) async {
    final validName = TenantValidators.validateName(tenant.name);
    final validPhone = TenantValidators.normalizePhone(tenant.phone);
    final id = tenant.id.isEmpty ? generateUuid() : tenant.id;
    final now = DateTime.now().toUtc();

    final existing = await _dao.getTenantById(id);
    final oldPhotoPath = existing?.idPhotoPath;

    String? newRelativePath;
    if (newPhotoTempPath != null) {
      newRelativePath = await _photoStorage.savePhoto(
        tempPath: newPhotoTempPath,
        tenantId: id,
      );
    }

    final String? finalPhotoPath =
        newRelativePath ??
        (removePhoto ? null : (oldPhotoPath ?? tenant.idPhotoPath));

    final tenantToSave = Tenant(
      id: id,
      name: validName,
      phone: validPhone,
      note: tenant.note,
      idPhotoPath: finalPhotoPath,
      updatedAt: now,
      createdAt: existing == null ? now : tenant.createdAt,
    );

    try {
      if (existing == null) {
        await _dao.insertTenant(_toCompanion(tenantToSave));
      } else {
        await _dao.updateTenant(_toCompanion(tenantToSave));
      }
    } catch (e) {
      // Failure-safety: if DB save fails, remove newly saved file and leave existing intact
      if (newRelativePath != null) {
        try {
          await _photoStorage.deletePhoto(newRelativePath);
        } catch (_) {}
      }
      rethrow;
    }

    // On DB success: clean up old photo or temporary file
    if (newRelativePath != null) {
      if (oldPhotoPath != null && oldPhotoPath != newRelativePath) {
        await _photoStorage.deletePhoto(oldPhotoPath);
      }
      await _photoStorage.discardTemp(newPhotoTempPath!);
    } else if (removePhoto && oldPhotoPath != null) {
      await _photoStorage.deletePhoto(oldPhotoPath);
    }
  }

  @override
  Future<void> cleanupOrphanPhotos() async {
    final referenced = await _dao.getAllReferencedIdPhotoPaths();
    await _photoStorage.cleanupOrphans(referenced);
  }
}
