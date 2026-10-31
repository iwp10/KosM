import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/errors/errors.dart';
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
    final now = DateTime.utc(2026, 10, 31, 10, 0, 0);

    final prop1 = Property(
      id: 'prop-1',
      name: 'Kos Graha Melati',
      createdAt: now,
      updatedAt: now,
    );

    final prop2 = Property(
      id: 'prop-2',
      name: 'Kos Mawar Indah',
      createdAt: now.add(const Duration(seconds: 1)),
      updatedAt: now.add(const Duration(seconds: 1)),
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
      'setActiveProperty updates state and persists to local settings',
      () async {
        final repo = container.read(propertyRepositoryProvider);
        await repo.create(prop1);
        await repo.create(prop2);

        // Await initial build completion before mutation
        await container.read(activePropertyProvider.future);

        // Change active to prop-2
        await container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('prop-2');

        final activeId = container.read(activePropertyProvider).value;
        expect(activeId, 'prop-2');

        final saved = await repo.readActivePropertyId();
        expect(saved, 'prop-2');

        // Change active to "all"
        await container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('all');
        expect(container.read(activePropertyProvider).value, 'all');
        expect(await repo.readActivePropertyId(), 'all');
        expect(container.read(selectedPropertyIdProvider), isNull);
      },
    );

    test('Regression test: setActiveProperty("all") persists across app restarts (new ProviderContainer)', () async {
      final repo = container.read(propertyRepositoryProvider);
      await repo.create(prop1);
      await repo.create(prop2);

      // Await initial build
      await container.read(activePropertyProvider.future);

      // Set active to "all"
      await container
          .read(activePropertyProvider.notifier)
          .setActiveProperty('all');
      expect(container.read(activePropertyProvider).value, 'all');

      // Simulate closing and reopening app with a new ProviderContainer on same DB
      final container2 = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container2.dispose);

      final activeIdAfterRestart = await container2.read(
        activePropertyProvider.future,
      );
      expect(activeIdAfterRestart, 'all');
      expect(container2.read(selectedPropertyIdProvider), isNull);
    });

    test('setActiveProperty throws AppException for invalid property id and leaves state unchanged', () async {
      final repo = container.read(propertyRepositoryProvider);
      await repo.create(prop1);

      await container.read(activePropertyProvider.future);
      expect(container.read(activePropertyProvider).value, 'prop-1');

      // Attempt to set non-existent property id
      expect(
        () => container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('non-existent-id'),
        throwsA(isA<AppException>()),
      );

      // State and saved ID must remain prop-1
      expect(container.read(activePropertyProvider).value, 'prop-1');
      expect(await repo.readActivePropertyId(), 'prop-1');
    });

    test(
      'deleteProperty cascades and falls back to remaining property or "all"',
      () async {
        final repo = container.read(propertyRepositoryProvider);
        await repo.create(prop1);
        await repo.create(prop2);

        await container.read(activePropertyProvider.future);
        await container
            .read(activePropertyProvider.notifier)
            .setActiveProperty('prop-1');
        expect(container.read(activePropertyProvider).value, 'prop-1');

        // Delete prop-1 via same path used by UI
        await container
            .read(activePropertyProvider.notifier)
            .deleteProperty('prop-1');

        expect(container.read(activePropertyProvider).value, 'prop-2');
        expect(await repo.readActivePropertyId(), 'prop-2');

        // Now delete prop-2 as well
        await container
            .read(activePropertyProvider.notifier)
            .deleteProperty('prop-2');

        expect(container.read(activePropertyProvider).value, 'all');
        expect(await repo.readActivePropertyId(), 'all');
      },
    );

    test('deleteProperty rejection prevents handlePropertyDeleted and retains active property', () async {
      final repo = container.read(propertyRepositoryProvider);
      await repo.create(prop1);
      await repo.create(prop2);

      // Add room to prop-1
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-1',
              propertyId: 'prop-1',
              number: '101',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add tenant
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 'tenant-1',
              name: 'Budi Santoso',
              phone: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add active occupancy
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-1',
              tenantId: 'tenant-1',
              roomId: 'room-1',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await container.read(activePropertyProvider.future);
      await container
          .read(activePropertyProvider.notifier)
          .setActiveProperty('prop-1');
      expect(container.read(activePropertyProvider).value, 'prop-1');

      // Deletion must be rejected due to active occupancy
      expect(
        () => container
            .read(activePropertyProvider.notifier)
            .deleteProperty('prop-1'),
        throwsA(isA<PropertyHasActiveOccupanciesException>()),
      );

      // Active property must not change
      expect(container.read(activePropertyProvider).value, 'prop-1');
      expect(await repo.readActivePropertyId(), 'prop-1');

      // Property must still exist in DB
      final prop = await repo.getById('prop-1');
      expect(prop, isNotNull);
    });

    test('onboarding flow: from "all", when new property is created and set active, active becomes new property', () async {
      final repo = container.read(propertyRepositoryProvider);

      // Initially no properties, active is "all"
      final activeInitial = await container.read(activePropertyProvider.future);
      expect(activeInitial, 'all');

      // Onboarding creates first property
      final newProp = Property(
        id: 'prop-new',
        name: 'Kos Pelangi',
        createdAt: now,
        updatedAt: now,
      );
      await repo.create(newProp);
      await container
          .read(activePropertyProvider.notifier)
          .setActiveProperty('prop-new');

      expect(container.read(activePropertyProvider).value, 'prop-new');
      expect(await repo.readActivePropertyId(), 'prop-new');
      expect(container.read(selectedPropertyIdProvider), 'prop-new');
    });

    test('PropertyRepository.getAll() returns only non-deleted properties ordered by createdAt asc then id asc', () async {
      final repo = container.read(propertyRepositoryProvider);

      final pA = Property(
        id: 'a',
        name: 'Kos A',
        createdAt: now.add(const Duration(seconds: 10)),
        updatedAt: now.add(const Duration(seconds: 10)),
      );
      final pB = Property(
        id: 'b',
        name: 'Kos B',
        createdAt: now,
        updatedAt: now,
      );
      final pC = Property(
        id: 'c',
        name: 'Kos C',
        createdAt: now,
        updatedAt: now,
      );
      final pD = Property(
        id: 'd',
        name: 'Kos D',
        createdAt: now.subtract(const Duration(seconds: 10)),
        updatedAt: now.subtract(const Duration(seconds: 10)),
      );

      await repo.create(pA);
      await repo.create(pB);
      await repo.create(pC);
      await repo.create(pD);

      // Soft delete pB
      await repo.softDelete('b');

      final all = await repo.getAll();

      // Check pB is excluded (soft deleted)
      expect(all.any((p) => p.id == 'b'), isFalse);

      // Check exact ordering: pD (earliest createdAt), then pC (same createdAt as B, id 'c'), then pA (latest)
      final ids = all.map((p) => p.id).toList();
      expect(ids, ['d', 'c', 'a']);
    });
  });
}
