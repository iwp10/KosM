import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/errors/errors.dart';
import 'package:kosm/features/tenant/data/tenant_dao.dart';
import 'package:kosm/features/tenant/data/tenant_repository_impl.dart';
import 'package:kosm/features/tenant/domain/tenant.dart';
import 'package:kosm/features/tenant/domain/tenant_repository.dart';

void main() {
  late AppDatabase db;
  late TenantRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final dao = TenantDao(db);
    repository = TenantRepositoryImpl(dao);
    addTearDown(() async {
      await db.close();
    });
  });

  group('TenantRepository Tests', () {
    final now = DateTime.utc(2026, 10, 31, 10, 0, 0);

    test('create and getById retrieves tenant with normalized phone', () async {
      final tenant = Tenant(
        id: '',
        name: '  Budi Santoso  ',
        phone: '0812-3456-7890',
        note: 'Penyewa baru',
        createdAt: now,
        updatedAt: now,
      );

      await repository.create(tenant);

      final all = await repository.getAll();
      expect(all.length, 1);
      final saved = all.first;
      expect(saved.id, isNotEmpty);
      expect(saved.name, 'Budi Santoso');
      expect(saved.phone, '+6281234567890');
      expect(saved.note, 'Penyewa baru');

      final byId = await repository.getById(saved.id);
      expect(byId, isNotNull);
      expect(byId!.name, 'Budi Santoso');
    });

    test('update modifies name and phone with normalization', () async {
      final tenant = Tenant(
        id: 'tenant-1',
        name: 'Siti Aminah',
        phone: '081234567890',
        createdAt: now,
        updatedAt: now,
      );
      await repository.create(tenant);

      final updated = tenant.copyWith(
        name: '  Siti Aminah, S.Kom  ',
        phone: '+62 899-8877-6655',
      );
      await repository.update(updated);

      final fetched = await repository.getById('tenant-1');
      expect(fetched!.name, 'Siti Aminah, S.Kom');
      expect(fetched.phone, '+6289988776655');
    });

    test('validates name: rejects empty or over 100 chars', () async {
      expect(
        () => repository.create(
          Tenant(
            id: '',
            name: '   ',
            phone: '081234567890',
            createdAt: now,
            updatedAt: now,
          ),
        ),
        throwsA(
          isA<TenantValidationException>().having(
            (e) => e.field,
            'field',
            'name',
          ),
        ),
      );

      final longName = 'A' * 101;
      expect(
        () => repository.create(
          Tenant(
            id: '',
            name: longName,
            phone: '081234567890',
            createdAt: now,
            updatedAt: now,
          ),
        ),
        throwsA(
          isA<TenantValidationException>().having(
            (e) => e.field,
            'field',
            'name',
          ),
        ),
      );
    });

    test(
      'validates and normalizes phone variations and rejects invalid formats',
      () async {
        // Valid inputs
        final t1 = Tenant(
          id: 't-1',
          name: 'T1',
          phone: '08123456789',
          createdAt: now,
          updatedAt: now,
        );
        final t2 = Tenant(
          id: 't-2',
          name: 'T2',
          phone: '+62 812-3456-7890',
          createdAt: now,
          updatedAt: now,
        );
        final t3 = Tenant(
          id: 't-3',
          name: 'T3',
          phone: '62812.3456.7890',
          createdAt: now,
          updatedAt: now,
        );

        await repository.create(t1);
        await repository.create(t2);
        await repository.create(t3);

        expect((await repository.getById('t-1'))!.phone, '+628123456789');
        expect((await repository.getById('t-2'))!.phone, '+6281234567890');
        expect((await repository.getById('t-3'))!.phone, '+6281234567890');

        // Invalid: foreign prefix
        expect(
          () => repository.create(
            Tenant(
              id: 'err-1',
              name: 'Err',
              phone: '+15551234567',
              createdAt: now,
              updatedAt: now,
            ),
          ),
          throwsA(
            isA<TenantValidationException>().having(
              (e) => e.field,
              'field',
              'phone',
            ),
          ),
        );

        // Invalid: zero after country code
        expect(
          () => repository.create(
            Tenant(
              id: 'err-2',
              name: 'Err',
              phone: '+6208123456789',
              createdAt: now,
              updatedAt: now,
            ),
          ),
          throwsA(
            isA<TenantValidationException>().having(
              (e) => e.field,
              'field',
              'phone',
            ),
          ),
        );

        // Invalid: non-digit letters
        expect(
          () => repository.create(
            Tenant(
              id: 'err-3',
              name: 'Err',
              phone: '0812-ABC-7890',
              createdAt: now,
              updatedAt: now,
            ),
          ),
          throwsA(
            isA<TenantValidationException>().having(
              (e) => e.field,
              'field',
              'phone',
            ),
          ),
        );

        // Invalid: too short (< 9 digits after +62)
        expect(
          () => repository.create(
            Tenant(
              id: 'err-4',
              name: 'Err',
              phone: '0812345',
              createdAt: now,
              updatedAt: now,
            ),
          ),
          throwsA(
            isA<TenantValidationException>().having(
              (e) => e.field,
              'field',
              'phone',
            ),
          ),
        );

        // Invalid: too long (> 13 digits after +62)
        expect(
          () => repository.create(
            Tenant(
              id: 'err-5',
              name: 'Err',
              phone: '08123456789012345',
              createdAt: now,
              updatedAt: now,
            ),
          ),
          throwsA(
            isA<TenantValidationException>().having(
              (e) => e.field,
              'field',
              'phone',
            ),
          ),
        );
      },
    );

    test('softDelete is rejected when active occupancy exists, succeeds when ended', () async {
      await repository.create(
        Tenant(
          id: 'tenant-1',
          name: 'Budi',
          phone: '081234567890',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Seed property & room
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-1',
              name: 'Kos Melati',
              address: 'Jl. Melati No. 12',
              contact: '08123456789',
              createdAt: now,
              updatedAt: now,
            ),
          );
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

      // Insert active occupancy
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

      // Soft delete must be rejected
      expect(
        () => repository.softDelete('tenant-1'),
        throwsA(isA<TenantHasActiveOccupancyException>()),
      );

      // End occupancy
      await (db.update(db.occupancies)..where((t) => t.id.equals('occ-1')))
          .write(const OccupanciesCompanion(status: Value('ended')));

      // Now soft delete must succeed
      await repository.softDelete('tenant-1');

      final fetched = await repository.getById('tenant-1');
      expect(fetched, isNull);

      final all = await repository.getAll();
      expect(all.isEmpty, isTrue);
    });

    test('propertyFilter rules: unassigned visible in all, assigned visible in respective properties, deleted room excluded', () async {
      // Seed 2 properties
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-1',
              name: 'Kos Melati',
              address: 'Jl. Melati No. 12',
              contact: '08123456789',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-2',
              name: 'Kos Mawar',
              address: 'Jl. Mawar No. 45',
              contact: '08123456788',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-del',
              name: 'Kos Hapus',
              address: 'Jl. Hapus No. 1',
              contact: '08123456787',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Rooms
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'r-1',
              propertyId: 'prop-1',
              number: '101',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'r-2',
              propertyId: 'prop-2',
              number: '201',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'r-del',
              propertyId: 'prop-del',
              number: '301',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
              deletedAt: Value(now),
            ),
          );

      // 4 tenants
      // t-unassigned: no occupancies -> visible in all
      await repository.create(
        Tenant(
          id: 't-unassigned',
          name: 'Unassigned Person',
          phone: '081234567890',
          createdAt: now,
          updatedAt: now,
        ),
      );
      // t-prop1: occupancy in prop-1
      await repository.create(
        Tenant(
          id: 't-prop1',
          name: 'Prop 1 Tenant',
          phone: '081234567891',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'o-1',
              tenantId: 't-prop1',
              roomId: 'r-1',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1000000,
              status: 'ended',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // t-both: occupancy in prop-1 and prop-2
      await repository.create(
        Tenant(
          id: 't-both',
          name: 'Both Tenant',
          phone: '081234567892',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'o-2a',
              tenantId: 't-both',
              roomId: 'r-1',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1000000,
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'o-2b',
              tenantId: 't-both',
              roomId: 'r-2',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1000000,
              status: 'ended',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // t-only-del: occupancy only in deleted room
      await repository.create(
        Tenant(
          id: 't-only-del',
          name: 'Deleted Room Tenant',
          phone: '081234567893',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'o-del',
              tenantId: 't-only-del',
              roomId: 'r-del',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1000000,
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Test 'all' filter: all 4 non-deleted tenants appear
      final allTenants = await repository.getAll(propertyFilter: 'all');
      expect(allTenants.map((t) => t.id).toList(), [
        't-both',
        't-only-del',
        't-prop1',
        't-unassigned',
      ]);

      // Test prop-1 filter:
      // - t-unassigned appears
      // - t-prop1 appears
      // - t-both appears
      // - t-only-del does NOT appear
      final prop1Tenants = await repository.getAll(propertyFilter: 'prop-1');
      expect(prop1Tenants.map((t) => t.id).toList(), [
        't-both',
        't-prop1',
        't-unassigned',
      ]);

      // Test prop-2 filter:
      // - t-unassigned appears
      // - t-both appears
      // - t-prop1 does NOT appear
      // - t-only-del does NOT appear
      final prop2Tenants = await repository.getAll(propertyFilter: 'prop-2');
      expect(prop2Tenants.map((t) => t.id).toList(), [
        't-both',
        't-unassigned',
      ]);
    });
  });
}
