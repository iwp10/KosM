import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/errors/errors.dart';
import 'package:kosm/features/property/data/property_dao.dart';
import 'package:kosm/features/property/data/property_repository_impl.dart';
import 'package:kosm/features/property/domain/property.dart';

void main() {
  late AppDatabase db;
  late PropertyDao dao;
  late PropertyRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = PropertyDao(db);
    repository = PropertyRepositoryImpl(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('PropertyRepository Tests', () {
    final now = DateTime.now().toUtc();

    final testProp1 = Property(
      id: 'prop-1',
      name: 'Kos Graha Melati',
      address: 'Jl. Melati No. 12',
      contact: '081234567890',
      createdAt: now,
      updatedAt: now,
    );

    final testProp2 = Property(
      id: 'prop-2',
      name: 'Kos Mawar Indah',
      address: 'Jl. Mawar No. 5',
      contact: '089876543210',
      createdAt: now,
      updatedAt: now,
    );

    test('create and getById retrieves property correctly', () async {
      await repository.create(testProp1);

      final fetched = await repository.getById('prop-1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'prop-1');
      expect(fetched.name, 'Kos Graha Melati');
      expect(fetched.address, 'Jl. Melati No. 12');
      expect(fetched.contact, '081234567890');
    });

    test('getAll and watchAll only return non-deleted properties', () async {
      await repository.create(testProp1);
      await repository.create(testProp2);

      final all = await repository.getAll();
      expect(all.length, 2);

      // Verify stream
      final streamFuture = repository.watchAll().first;
      final streamed = await streamFuture;
      expect(streamed.length, 2);
    });

    test('update modifies property data correctly', () async {
      await repository.create(testProp1);

      final updated = testProp1.copyWith(
        name: 'Kos Graha Melati Baru',
        address: 'Jl. Melati No. 99',
      );
      await repository.update(updated);

      final fetched = await repository.getById('prop-1');
      expect(fetched!.name, 'Kos Graha Melati Baru');
      expect(fetched.address, 'Jl. Melati No. 99');
    });

    test(
      'softDelete cascades to rooms when no active occupancy exists',
      () async {
        await repository.create(testProp1);

        // Insert room belonging to prop-1
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

        // Soft delete property
        await repository.softDelete('prop-1');

        // Property should now be soft deleted
        final prop = await repository.getById('prop-1');
        expect(prop, isNull);

        final all = await repository.getAll();
        expect(all.isEmpty, true);

        // Room should also be soft deleted
        final room =
            await (db.select(db.rooms)
                  ..where((t) => t.id.equals('room-1') & t.deletedAt.isNull()))
                .getSingleOrNull();
        expect(room, isNull);

        final deletedRoom = await (db.select(
          db.rooms,
        )..where((t) => t.id.equals('room-1'))).getSingle();
        expect(deletedRoom.deletedAt, isNotNull);
      },
    );

    test('softDelete is rejected when active occupancy exists', () async {
      await repository.create(testProp1);

      // Insert room
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

      // Insert tenant
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

      // Insert ACTIVE occupancy
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

      // Attempt soft delete -> should throw PropertyHasActiveOccupanciesException
      expect(
        () => repository.softDelete('prop-1'),
        throwsA(isA<PropertyHasActiveOccupanciesException>()),
      );

      // Verify property and room are NOT deleted
      final prop = await repository.getById('prop-1');
      expect(prop, isNotNull);
    });

    test('softDelete succeeds if occupancies are already ended', () async {
      await repository.create(testProp1);

      // Insert room
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

      // Insert tenant
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

      // Insert ENDED occupancy (status = 'ended')
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-1',
              tenantId: 'tenant-1',
              roomId: 'room-1',
              startDate: now,
              actualEndDate: Value(now),
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'ended',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Should succeed because occupancy is ended
      await repository.softDelete('prop-1');

      final prop = await repository.getById('prop-1');
      expect(prop, isNull);
    });
  });
}
