import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/errors/errors.dart';
import '../../data/property_dao.dart';
import '../../data/property_repository_impl.dart';
import '../../domain/property.dart';
import '../../domain/property_repository.dart';

/// Provider for [PropertyDao].
final propertyDaoProvider = Provider<PropertyDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PropertyDao(db);
});

/// Provider for [PropertyRepository].
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final dao = ref.watch(propertyDaoProvider);
  return PropertyRepositoryImpl(dao);
});

/// Stream provider for all active (non-deleted) properties.
final propertiesStreamProvider = StreamProvider<List<Property>>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return repository.watchAll();
});

/// AsyncNotifier managing the active property ID ("all" or a specific property ID).
/// Automatically persists to repository local settings and falls back if the active property is deleted.
class ActivePropertyNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final repo = ref.watch(propertyRepositoryProvider);
    final savedId = await repo.readActivePropertyId();
    final properties = await repo.getAll();

    // 1. If saved as "all", keep "all"
    if (savedId == 'all') {
      return 'all';
    }

    // 2. If savedId matches an existing non-deleted property, use it
    if (savedId != null && properties.any((p) => p.id == savedId)) {
      return savedId;
    }

    // 3. Fallback: If properties exist, default to the first one and save
    if (properties.isNotEmpty) {
      final firstId = properties.first.id;
      await repo.saveActivePropertyId(firstId);
      return firstId;
    }

    // 4. If no properties exist, default to "all"
    return 'all';
  }

  /// Sets the active property and persists it to local settings.
  /// Accepts 'all' or an existing, non-deleted property ID.
  /// Awaits [future] before mutating. Saves to repository first; only updates [state] on success.
  /// Throws [PropertyNotFoundException] if the property ID is not 'all' and does not exist.
  Future<void> setActiveProperty(String propertyId) async {
    await future;

    final repo = ref.read(propertyRepositoryProvider);
    if (propertyId != 'all') {
      final prop = await repo.getById(propertyId);
      if (prop == null) {
        throw const PropertyNotFoundException(
          'Kos tidak ditemukan atau telah dihapus.',
        );
      }
    }

    await repo.saveActivePropertyId(propertyId);
    state = AsyncData(propertyId);
  }

  /// Deletes a property and manages fallback if the deleted property was active.
  /// Throws [PropertyHasActiveOccupanciesException] if the property has active occupancies.
  /// If soft delete is rejected, active property remains unchanged and fallback is skipped.
  Future<void> deleteProperty(String id) async {
    await future;
    final repo = ref.read(propertyRepositoryProvider);
    await repo.softDelete(id);
    await handlePropertyDeleted(id);
  }

  /// Handles fallback when a property has been deleted.
  /// If the deleted property was the active one, falls back to the first remaining property or 'all'.
  Future<void> handlePropertyDeleted(String deletedPropertyId) async {
    await future;
    final currentActive = state.value;
    if (currentActive == deletedPropertyId) {
      final repo = ref.read(propertyRepositoryProvider);
      final remaining = await repo.getAll();
      final nextActive = remaining.isNotEmpty ? remaining.first.id : 'all';
      await repo.saveActivePropertyId(nextActive);
      state = AsyncData(nextActive);
    }
  }
}

/// Provider for active property ID ("all" or a specific property ID).
final activePropertyProvider =
    AsyncNotifierProvider<ActivePropertyNotifier, String>(
      ActivePropertyNotifier.new,
    );

/// Helper provider for feature queries (Fase 2).
/// Returns `null` if "Semua Kos" ('all') is selected, or the specific property ID.
final selectedPropertyIdProvider = Provider<String?>((ref) {
  final activeAsync = ref.watch(activePropertyProvider);
  final activeId = activeAsync.value ?? 'all';
  return activeId == 'all' ? null : activeId;
});
