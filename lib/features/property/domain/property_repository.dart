import 'property.dart';

/// Repository interface for property management (Kos / multi-lokasi).
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.9.
abstract class PropertyRepository {
  /// Watches all non-deleted properties as a reactive stream.
  Stream<List<Property>> watchAll();

  /// Gets all non-deleted properties.
  Future<List<Property>> getAll();

  /// Gets a specific property by its unique ID.
  Future<Property?> getById(String id);

  /// Creates a new property.
  Future<void> create(Property property);

  /// Updates an existing property.
  Future<void> update(Property property);

  /// Soft deletes a property and its associated rooms in a single transaction.
  /// Throws [PropertyHasActiveOccupanciesException] if any room has an active occupancy.
  Future<void> softDelete(String id);

  /// Reads the saved active property ID from local settings.
  Future<String?> readActivePropertyId();

  /// Saves the active property ID to local settings.
  Future<void> saveActivePropertyId(String id);
}
