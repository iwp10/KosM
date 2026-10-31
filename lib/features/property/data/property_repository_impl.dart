import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/errors.dart';
import '../domain/property.dart';
import '../domain/property_repository.dart';
import 'property_dao.dart';

/// Implementation of [PropertyRepository] using Drift SQLite DAO.
/// Reference: docs/ARCHITECTURE.md section 3 & 4.
class PropertyRepositoryImpl implements PropertyRepository {
  static const String activePropertyKey = 'active_property_id';

  final PropertyDao _dao;

  PropertyRepositoryImpl(this._dao);

  Property _toDomain(PropertyData data) {
    return Property(
      id: data.id,
      name: data.name,
      address: data.address,
      contact: data.contact,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  PropertiesCompanion _toCompanion(Property property) {
    return PropertiesCompanion(
      id: Value(property.id),
      name: Value(property.name),
      address: Value(property.address),
      contact: Value(property.contact),
      createdAt: Value(property.createdAt),
      updatedAt: Value(property.updatedAt),
      deletedAt: Value(property.deletedAt),
    );
  }

  @override
  Stream<List<Property>> watchAll() {
    return _dao.watchAllProperties().map(
      (list) => list.map(_toDomain).toList(),
    );
  }

  @override
  Future<List<Property>> getAll() async {
    final list = await _dao.getAllProperties();
    return list.map(_toDomain).toList();
  }

  @override
  Future<Property?> getById(String id) async {
    final data = await _dao.getPropertyById(id);
    if (data == null) return null;
    return _toDomain(data);
  }

  @override
  Future<void> create(Property property) {
    return _dao.insertProperty(_toCompanion(property));
  }

  @override
  Future<void> update(Property property) {
    final updated = property.copyWith(updatedAt: DateTime.now().toUtc());
    return _dao.updateProperty(_toCompanion(updated));
  }

  @override
  Future<void> softDelete(String id) async {
    final activeCount = await _dao.countActiveOccupancies(id);
    if (activeCount > 0) {
      throw PropertyHasActiveOccupanciesException(
        'Kos tidak dapat dihapus karena masih ada $activeCount penghuni aktif di kamar kos ini.',
      );
    }

    final now = DateTime.now().toUtc();
    await _dao.softDeletePropertyAndRooms(id, now);
  }

  @override
  Future<String?> readActivePropertyId() =>
      _dao.getAppSetting(activePropertyKey);

  @override
  Future<void> saveActivePropertyId(String id) =>
      _dao.setAppSetting(activePropertyKey, id);
}
