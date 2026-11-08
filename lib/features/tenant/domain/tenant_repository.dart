import 'tenant.dart';

/// Repository interface for Tenant management.
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.1.
abstract class TenantRepository {
  /// Watches all non-deleted tenants matching the given [propertyFilter].
  /// [propertyFilter] can be null or 'all' to show all tenants, or a specific property ID.
  Stream<List<Tenant>> watchAll({String? propertyFilter});

  /// Gets all non-deleted tenants matching the given [propertyFilter].
  Future<List<Tenant>> getAll({String? propertyFilter});

  /// Watches all non-deleted tenants along with their derived status.
  /// Re-emits reactively whenever tenants, occupancies, rooms, charges, or payments change.
  Stream<List<TenantWithStatus>> watchAllWithStatus({
    String? propertyFilter,
    DateTime? asOf,
  });

  /// Gets all non-deleted tenants along with their derived status.
  Future<List<TenantWithStatus>> getAllWithStatus({
    String? propertyFilter,
    DateTime? asOf,
  });

  /// Gets a specific tenant by unique ID.
  Future<Tenant?> getById(String id);

  /// Gets a specific tenant by ID along with their derived status.
  Future<TenantWithStatus?> getByIdWithStatus(String id, {DateTime? asOf});

  /// Watches a specific tenant along with their derived status.
  /// Re-emits reactively whenever tenants, occupancies, rooms, charges, or payments change.
  /// Emits `null` if the tenant does not exist or has been soft-deleted.
  Stream<TenantWithStatus?> watchByIdWithStatus(String id, {DateTime? asOf});

  /// Creates a new tenant. Validates name and normalizes phone number.
  Future<void> create(Tenant tenant);

  /// Updates an existing tenant. Validates name and normalizes phone number.
  Future<void> update(Tenant tenant);

  /// Soft deletes a tenant by setting deleted_at.
  /// Throws [TenantHasActiveOccupancyException] if the tenant still has an active occupancy.
  Future<void> softDelete(String id);

  /// Saves a tenant (create or update) orchestrating atomic photo storage operations:
  /// 1. If [newPhotoTempPath] is provided, copies new photo to versioned permanent storage.
  /// 2. Saves tenant record in the database. If DB save fails, deletes the newly copied photo and rethrows.
  /// 3. If DB save succeeds:
  ///    - If a previous photo existed and was replaced or [removePhoto] is true, deletes the old photo.
  ///    - If [newPhotoTempPath] was provided, cleans up the temporary source file.
  Future<void> saveTenant(
    Tenant tenant, {
    String? newPhotoTempPath,
    bool removePhoto = false,
  });

  /// Cleans up orphaned photo files that are no longer referenced by any tenant in the database.
  Future<void> cleanupOrphanPhotos();
}
