import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/features/property/domain/property.dart';
import 'package:kosm/features/property/presentation/providers/property_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('ActivePropertyNotifier Tests', () {
    final now = DateTime.now().toUtc();

    final prop1 = Property(
      id: 'prop-1',
      name: 'Kos Graha Melati',
      createdAt: now,
      updatedAt: now,
    );

    final prop2 = Property(
      id: 'prop-2',
      name: 'Kos Mawar Indah',
      createdAt: now,
      updatedAt: now,
    );

    test('defaults to "all" when database has no properties', () async {
      final activeId = await container.read(activePropertyProvider.future);
      expect(activeId, 'all');

      final selectedId = container.read(selectedPropertyIdProvider);
      expect(selectedId, isNull);
    });

    test('defaults to first property when properties exist', () async {
      final repo = container.read(propertyRepositoryProvider);
      await repo.create(prop1);
      await repo.create(prop2);

      final activeId = await container.read(activePropertyProvider.future);
      expect(activeId, 'prop-1');

      final selectedId = container.read(selectedPropertyIdProvider);
      expect(selectedId, 'prop-1');
    });

    test(
      'setActiveProperty updates state and persists to app_settings',
      () async {
        final repo = container.read(propertyRepositoryProvider);
        await repo.create(prop1);
        await repo.create(prop2);

        // Change active to prop-2
        await container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('prop-2');

        final activeId = container.read(activePropertyProvider).value;
        expect(activeId, 'prop-2');

        // Check app_settings persisted
        final dao = container.read(propertyDaoProvider);
        final saved = await dao.getAppSetting(kActivePropertyIdKey);
        expect(saved, 'prop-2');

        // Change active to "all"
        await container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('all');
        expect(container.read(activePropertyProvider).value, 'all');
        expect(container.read(selectedPropertyIdProvider), isNull);
      },
    );

    test('auto-fallback to remaining property or "all" when active property is deleted', () async {
      final repo = container.read(propertyRepositoryProvider);
      await repo.create(prop1);
      await repo.create(prop2);

      // Set active to prop-1
      await container
          .read(activePropertyProvider.notifier)
          .setActiveProperty('prop-1');
      expect(container.read(activePropertyProvider).value, 'prop-1');

      // Delete prop-1
      await repo.softDelete('prop-1');

      // Refresh / wait for provider re-evaluation
      final newActiveId = await container.refresh(
        activePropertyProvider.future,
      );
      expect(newActiveId, 'prop-2');

      // Now delete prop-2 as well
      await repo.softDelete('prop-2');
      final fallbackToAll = await container.refresh(
        activePropertyProvider.future,
      );
      expect(fallbackToAll, 'all');
    });
  });
}
