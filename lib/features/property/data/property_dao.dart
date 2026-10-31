import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Data Access Object for Property entity and related cascade queries.
/// Reference: docs/ARCHITECTURE.md section 3 & 4.
class PropertyDao {
  final AppDatabase _db;

  PropertyDao(this._db);

  /// Watches all non-deleted properties ordered by name.
  Stream<List<PropertyData>> watchAllProperties() {
    return (_db.select(_db.properties)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Gets all non-deleted properties.
  Future<List<PropertyData>> getAllProperties() {
    return (_db.select(_db.properties)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Gets a property by its ID if not deleted.
  Future<PropertyData?> getPropertyById(String id) {
    return (_db.select(
      _db.properties,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// Inserts a new property record.
  Future<void> insertProperty(PropertiesCompanion companion) {
    return _db.into(_db.properties).insert(companion);
  }

  /// Updates an existing property record.
  Future<void> updateProperty(PropertiesCompanion companion) {
    return (_db.update(
      _db.properties,
    )..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

  /// Counts active occupancies across all rooms in the given property.
  Future<int> countActiveOccupancies(String propertyId) async {
    final query =
        _db.select(_db.occupancies).join([
          innerJoin(_db.rooms, _db.rooms.id.equalsExp(_db.occupancies.roomId)),
        ])..where(
          _db.rooms.propertyId.equals(propertyId) &
              _db.rooms.deletedAt.isNull() &
              _db.occupancies.status.equals('active') &
              _db.occupancies.deletedAt.isNull(),
        );

    final rows = await query.get();
    return rows.length;
  }

  /// Soft deletes a property and all its rooms in a single transaction.
  Future<void> softDeletePropertyAndRooms(String propertyId, DateTime now) {
    return _db.transaction(() async {
      // 1. Soft delete property
      await (_db.update(
        _db.properties,
      )..where((t) => t.id.equals(propertyId))).write(
        PropertiesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );

      // 2. Cascade soft delete rooms belonging to this property
      await (_db.update(_db.rooms)..where(
            (t) => t.propertyId.equals(propertyId) & t.deletedAt.isNull(),
          ))
          .write(RoomsCompanion(deletedAt: Value(now), updatedAt: Value(now)));

      // TODO(F7.2): Penandaan dirty dikerjakan terpusat di F7.2.
    });
  }

  /// Reads a value from app_settings by key.
  Future<String?> getAppSetting(String key) async {
    final record =
        await (_db.select(_db.appSettings)
              ..where((t) => t.key.equals(key) & t.deletedAt.isNull()))
            .getSingleOrNull();
    return record?.value;
  }

  /// Writes or updates a key-value pair in app_settings.
  Future<void> setAppSetting(String key, String value) async {
    final now = DateTime.now().toUtc();
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
