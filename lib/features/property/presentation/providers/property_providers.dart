import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
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

/// Key name in app_settings table for active property.
const String kActivePropertyIdKey = 'active_property_id';

/// AsyncNotifier managing the active property ID ("all" or a specific property ID).
/// Automatically persists to [app_settings] and falls back if the active property is deleted.
class ActivePropertyNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final dao = ref.watch(propertyDaoProvider);
    final repo = ref.watch(propertyRepositoryProvider);
    final savedId = await dao.getAppSetting(kActivePropertyIdKey);

    // Watch properties list reactively to handle auto-fallback on deletion
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final properties = propertiesAsync.value ?? await repo.getAll();

    // 1. If saved as "all", keep "all"
    if (savedId == 'all') {
      return 'all';
    }

    // 2. If savedId matches an existing property, use it
    if (savedId != null && properties.any((p) => p.id == savedId)) {
      return savedId;
    }

    // 3. Fallback: If properties exist, default to the first one and save
    if (properties.isNotEmpty) {
      final firstId = properties.first.id;
      await dao.setAppSetting(kActivePropertyIdKey, firstId);
      return firstId;
    }

    // 4. If no properties exist, default to "all"
    return 'all';
  }

  /// Sets the active property and persists it to app_settings.
  Future<void> setActiveProperty(String propertyId) async {
    final dao = ref.read(propertyDaoProvider);
    state = AsyncData(propertyId);
    await dao.setAppSetting(kActivePropertyIdKey, propertyId);
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
