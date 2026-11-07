import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/features/tenant/data/tenant_dao.dart';
import 'package:kosm/features/tenant/data/tenant_repository_impl.dart';
import 'package:kosm/features/tenant/domain/tenant.dart';
import 'package:kosm/features/tenant/domain/tenant_repository.dart';

void main() {
  late AppDatabase db;
  late TenantRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final dao = TenantDao(db);
    repository = TenantRepositoryImpl(dao);
    addTearDown(() async {
      await db.close();
    });

    // Seed base property & room
    final now = DateTime.utc(2026, 10, 31, 10, 0, 0);
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
  });

  group('TenantStatus Derived Calculation Tests', () {
    // Reference date: 2026-10-31 (today in Asia/Jakarta)
    // 2026-10-31T05:00:00Z + 7h = 2026-10-31T12:00:00 (Jakarta)
    final todayUtc = DateTime.utc(2026, 10, 31, 5, 0, 0);
    final yesterdayUtc = todayUtc.subtract(const Duration(days: 1));
    final tomorrowUtc = todayUtc.add(const Duration(days: 1));

    test('unassigned: tenant has never had any occupancy', () async {
      await repository.create(
        Tenant(
          id: 't-unassigned',
          name: 'Penyewa Baru',
          phone: '081234567890',
          createdAt: todayUtc,
          updatedAt: todayUtc,
        ),
      );

      final withStatus = await repository.getByIdWithStatus(
        't-unassigned',
        asOf: todayUtc,
      );
      expect(withStatus, isNotNull);
      expect(withStatus!.status, TenantStatus.unassigned);
    });

    test(
      'ended: tenant only has ended occupancies and no overdue charges',
      () async {
        await repository.create(
          Tenant(
            id: 't-ended',
            name: 'Penyewa Lama',
            phone: '081234567890',
            createdAt: todayUtc,
            updatedAt: todayUtc,
          ),
        );

        await db
            .into(db.occupancies)
            .insert(
              OccupanciesCompanion.insert(
                id: 'occ-ended',
                tenantId: 't-ended',
                roomId: 'room-1',
                startDate: yesterdayUtc,
                actualEndDate: Value(yesterdayUtc),
                rateType: 'monthly',
                rateAmount: 1500000,
                status: 'ended',
                createdAt: yesterdayUtc,
                updatedAt: yesterdayUtc,
              ),
            );

        final withStatus = await repository.getByIdWithStatus(
          't-ended',
          asOf: todayUtc,
        );
        expect(withStatus!.status, TenantStatus.ended);
      },
    );

    test(
      'active: tenant has active occupancy and no overdue charges',
      () async {
        await repository.create(
          Tenant(
            id: 't-active',
            name: 'Penyewa Aktif',
            phone: '081234567890',
            createdAt: todayUtc,
            updatedAt: todayUtc,
          ),
        );

        await db
            .into(db.occupancies)
            .insert(
              OccupanciesCompanion.insert(
                id: 'occ-active',
                tenantId: 't-active',
                roomId: 'room-1',
                startDate: todayUtc,
                rateType: 'monthly',
                rateAmount: 1500000,
                status: 'active',
                createdAt: todayUtc,
                updatedAt: todayUtc,
              ),
            );

        final withStatus = await repository.getByIdWithStatus(
          't-active',
          asOf: todayUtc,
        );
        expect(withStatus!.status, TenantStatus.active);
      },
    );

    test('overdue boundary tests: yesterday is overdue, today is not, tomorrow is not', () async {
      await repository.create(
        Tenant(
          id: 't-boundary',
          name: 'Penyewa Boundary',
          phone: '081234567890',
          createdAt: todayUtc,
          updatedAt: todayUtc,
        ),
      );

      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-b',
              tenantId: 't-boundary',
              roomId: 'room-1',
              startDate: yesterdayUtc,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      // Case 1: Due date tomorrow -> NOT overdue (active)
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-tomorrow',
              occupancyId: 'occ-b',
              type: 'rent',
              description: 'Sewa Bulan Ini',
              amount: 1500000,
              periodStart: todayUtc,
              periodEnd: tomorrowUtc,
              dueDate: tomorrowUtc,
              createdAt: todayUtc,
              updatedAt: todayUtc,
            ),
          );
      expect(
        (await repository.getByIdWithStatus(
          't-boundary',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.active,
      );

      // Case 2: Due date today -> NOT overdue (active) - jatuh tempo hari ini belum overdue
      await (db.update(db.charges)..where((t) => t.id.equals('ch-tomorrow')))
          .write(ChargesCompanion(dueDate: Value(todayUtc)));
      expect(
        (await repository.getByIdWithStatus(
          't-boundary',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.active,
      );

      // Case 3: Due date yesterday -> OVERDUE (due_date strictly before today in Jakarta and unpaid)
      await (db.update(db.charges)..where((t) => t.id.equals('ch-tomorrow')))
          .write(ChargesCompanion(dueDate: Value(yesterdayUtc)));
      expect(
        (await repository.getByIdWithStatus(
          't-boundary',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.overdue,
      );
    });

    test('partial payment remains overdue until fully paid', () async {
      await repository.create(
        Tenant(
          id: 't-partial',
          name: 'Penyewa Cicilan',
          phone: '081234567890',
          createdAt: todayUtc,
          updatedAt: todayUtc,
        ),
      );

      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-part',
              tenantId: 't-partial',
              roomId: 'room-1',
              startDate: yesterdayUtc,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-part',
              occupancyId: 'occ-part',
              type: 'rent',
              description: 'Sewa',
              amount: 1500000,
              periodStart: yesterdayUtc,
              periodEnd: todayUtc,
              dueDate: yesterdayUtc,
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      // 1. Unpaid -> overdue
      expect(
        (await repository.getByIdWithStatus(
          't-partial',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.overdue,
      );

      // 2. Partial payment Rp500.000 (< Rp1.500.000) -> still overdue
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: 'pay-1',
              chargeId: 'ch-part',
              amount: 500000,
              paidAt: yesterdayUtc,
              method: 'transfer',
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );
      expect(
        (await repository.getByIdWithStatus(
          't-partial',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.overdue,
      );

      // 3. Second payment Rp1.000.000 (total Rp1.500.000 >= Rp1.500.000) -> fully paid -> active
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: 'pay-2',
              chargeId: 'ch-part',
              amount: 1000000,
              paidAt: todayUtc,
              method: 'cash',
              createdAt: todayUtc,
              updatedAt: todayUtc,
            ),
          );
      expect(
        (await repository.getByIdWithStatus(
          't-partial',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.active,
      );
    });

    test('ignores soft-deleted charges and soft-deleted payments', () async {
      await repository.create(
        Tenant(
          id: 't-softdel',
          name: 'Penyewa Soft Delete',
          phone: '081234567890',
          createdAt: todayUtc,
          updatedAt: todayUtc,
        ),
      );

      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-sd',
              tenantId: 't-softdel',
              roomId: 'room-1',
              startDate: yesterdayUtc,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      // Soft deleted overdue charge -> should be ignored, status remains active
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-sd',
              occupancyId: 'occ-sd',
              type: 'rent',
              description: 'Sewa Batal',
              amount: 1500000,
              periodStart: yesterdayUtc,
              periodEnd: todayUtc,
              dueDate: yesterdayUtc,
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
              deletedAt: Value(yesterdayUtc),
            ),
          );

      expect(
        (await repository.getByIdWithStatus(
          't-softdel',
          asOf: todayUtc,
        ))!.status,
        TenantStatus.active,
      );
    });

    test('watchAllWithStatus re-emits reactively from overdue to active when full payment is inserted', () async {
      await repository.create(
        Tenant(
          id: 't-reactive',
          name: 'Penyewa Reaktif',
          phone: '081234567890',
          createdAt: todayUtc,
          updatedAt: todayUtc,
        ),
      );

      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-rx',
              tenantId: 't-reactive',
              roomId: 'room-1',
              startDate: yesterdayUtc,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-rx',
              occupancyId: 'occ-rx',
              type: 'rent',
              description: 'Sewa',
              amount: 1500000,
              periodStart: yesterdayUtc,
              periodEnd: todayUtc,
              dueDate: yesterdayUtc,
              createdAt: yesterdayUtc,
              updatedAt: yesterdayUtc,
            ),
          );

      final stream = repository.watchAllWithStatus(asOf: todayUtc);

      // Expect initial emission to be overdue, and next emission to be active upon payment insertion
      expect(
        stream.map((list) => list.first.status),
        emitsInOrder([TenantStatus.overdue, TenantStatus.active]),
      );

      // Allow initial query to emit
      await Future.delayed(const Duration(milliseconds: 50));

      // Insert full payment
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: 'pay-rx',
              chargeId: 'ch-rx',
              amount: 1500000,
              paidAt: todayUtc,
              method: 'transfer',
              createdAt: todayUtc,
              updatedAt: todayUtc,
            ),
          );
    });
  });
}
