import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase In-Memory Tests', () {
    final now = DateTime.now().toUtc();

    test('schemaVersion is 1', () {
      expect(db.schemaVersion, 1);
    });

    test('can insert and read from all 9 tables', () async {
      // 1. owner_profile
      await db
          .into(db.ownerProfiles)
          .insert(
            OwnerProfilesCompanion.insert(
              id: 'owner-1',
              ownerName: 'Budi Santoso',
              contact: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final owners = await db.select(db.ownerProfiles).get();
      expect(owners.length, 1);
      expect(owners.first.ownerName, 'Budi Santoso');

      // 2. properties
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-1',
              name: 'Kos Sejahtera',
              address: 'Jl. Melati No. 12',
              contact: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final properties = await db.select(db.properties).get();
      expect(properties.length, 1);
      expect(properties.first.name, 'Kos Sejahtera');

      // 3. rooms
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-1',
              propertyId: 'prop-1',
              number: 'A01',
              capacity: const Value(2),
              referenceRateType: 'monthly',
              referenceRate: const Value(1500000),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final rooms = await db.select(db.rooms).get();
      expect(rooms.length, 1);
      expect(rooms.first.number, 'A01');
      expect(rooms.first.capacity, 2);

      // 4. tenants
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 'tenant-1',
              name: 'Ahmad Dahlan',
              phone: '089876543210',
              note: const Value('Penyewa ramah'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final tenants = await db.select(db.tenants).get();
      expect(tenants.length, 1);
      expect(tenants.first.name, 'Ahmad Dahlan');

      // 5. occupancies
      final startDate = DateTime.utc(2026, 10, 1);
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-1',
              tenantId: 'tenant-1',
              roomId: 'room-1',
              startDate: startDate,
              rateType: 'monthly',
              rateAmount: 1500000,
              dueDay: const Value(5),
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final occupancies = await db.select(db.occupancies).get();
      expect(occupancies.length, 1);
      expect(occupancies.first.rateAmount, 1500000);

      // 6. charges
      final periodStart = DateTime.utc(2026, 10, 1);
      final periodEnd = DateTime.utc(2026, 10, 31);
      final dueDate = DateTime.utc(2026, 10, 5);
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'charge-1',
              occupancyId: 'occ-1',
              type: 'rent',
              description: 'Sewa Oktober 2026',
              amount: 1500000,
              periodStart: periodStart,
              periodEnd: periodEnd,
              dueDate: dueDate,
              createdAt: now,
              updatedAt: now,
            ),
          );
      final charges = await db.select(db.charges).get();
      expect(charges.length, 1);
      expect(charges.first.amount, 1500000);

      // 7. payments
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: 'pay-1',
              chargeId: 'charge-1',
              amount: 1500000,
              paidAt: now,
              method: 'transfer',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final payments = await db.select(db.payments).get();
      expect(payments.length, 1);
      expect(payments.first.amount, 1500000);

      // 8. reminders
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              id: 'rem-1',
              type: 'charge_due',
              occupancyId: 'occ-1',
              chargeId: const Value('charge-1'),
              remindAt: dueDate.subtract(const Duration(days: 3)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final reminders = await db.select(db.reminders).get();
      expect(reminders.length, 1);
      expect(reminders.first.isDone, false);

      // 9. app_settings
      await db
          .into(db.appSettings)
          .insert(
            AppSettingsCompanion.insert(
              key: 'theme_mode',
              value: 'system',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final settings = await db.select(db.appSettings).get();
      expect(settings.length, 1);
      expect(settings.first.key, 'theme_mode');
      expect(settings.first.value, 'system');
    });

    test('supports soft delete by setting deleted_at', () async {
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 'tenant-del',
              name: 'Siti Aminah',
              phone: '085555555555',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Soft delete by updating deletedAt
      final deletedTime = DateTime.now().toUtc();
      await (db.update(db.tenants)..where((t) => t.id.equals('tenant-del')))
          .write(TenantsCompanion(deletedAt: Value(deletedTime)));

      final tenant = await (db.select(
        db.tenants,
      )..where((t) => t.id.equals('tenant-del'))).getSingle();

      expect(tenant.deletedAt, isNotNull);
      expect(
        tenant.deletedAt!.toUtc().difference(deletedTime).inSeconds.abs() <= 1,
        isTrue,
      );
    });

    test('enforces unique index on charges (occupancy_id, type, period_start)', () async {
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-unique',
              name: 'Kos B',
              address: 'Jl. B',
              contact: '081',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-unique',
              propertyId: 'prop-unique',
              number: 'B01',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 'tenant-unique',
              name: 'Rudi',
              phone: '082',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-unique',
              tenantId: 'tenant-unique',
              roomId: 'room-unique',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1000000,
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final period = DateTime.utc(2026, 11, 1);

      // Insert first charge
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'charge-u1',
              occupancyId: 'occ-unique',
              type: 'rent',
              description: 'Sewa Nov',
              amount: 1000000,
              periodStart: period,
              periodEnd: DateTime.utc(2026, 11, 30),
              dueDate: DateTime.utc(2026, 11, 5),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Attempt duplicate charge with identical occupancyId, type, periodStart
      expect(
        () async => db
            .into(db.charges)
            .insert(
              ChargesCompanion.insert(
                id: 'charge-u2',
                occupancyId: 'occ-unique',
                type: 'rent',
                description: 'Sewa Nov Duplikat',
                amount: 1000000,
                periodStart: period,
                periodEnd: DateTime.utc(2026, 11, 30),
                dueDate: DateTime.utc(2026, 11, 5),
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('enforces unique room number per property', () async {
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-room-u',
              name: 'Kos C',
              address: 'Jl. C',
              contact: '083',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-u1',
              propertyId: 'prop-room-u',
              number: '101',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Inserting duplicate room '101' for same property should throw SqliteException
      expect(
        () async => db
            .into(db.rooms)
            .insert(
              RoomsCompanion.insert(
                id: 'room-u2',
                propertyId: 'prop-room-u',
                number: '101',
                referenceRateType: 'monthly',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
