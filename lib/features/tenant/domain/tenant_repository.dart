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

  /// Creates a new tenant. Validates name and normalizes phone number.
  Future<void> create(Tenant tenant);

  /// Updates an existing tenant. Validates name and normalizes phone number.
  Future<void> update(Tenant tenant);

  /// Soft deletes a tenant by setting deleted_at.
  /// Throws [TenantHasActiveOccupancyException] if the tenant still has an active occupancy.
  Future<void> softDelete(String id);
}
