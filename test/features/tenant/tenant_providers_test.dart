import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/features/property/presentation/providers/property_providers.dart';
import 'package:kosm/features/tenant/domain/tenant.dart';
import 'package:kosm/features/tenant/presentation/providers/tenant_providers.dart';

void main() {
  final now = DateTime.utc(2026, 11, 7, 10, 0, 0);
  final yesterday = now.subtract(const Duration(days: 1));

  final tenantActive = TenantWithStatus(
    tenant: Tenant(
      id: 't-1',
      name: 'Budi Santoso',
      phone: '+6281234567890',
      createdAt: now,
      updatedAt: now,
    ),
    status: TenantStatus.active,
    hasActiveOccupancy: true,
    currentRoomNumber: '101',
  );

  final tenantOverdueActive = TenantWithStatus(
    tenant: Tenant(
      id: 't-2',
      name: 'Siti Rahma',
      phone: '085712345678',
      createdAt: now,
      updatedAt: now,
    ),
    status: TenantStatus.overdue,
    hasActiveOccupancy: true,
    currentRoomNumber: '03',
  );

  final tenantOverdueEnded = TenantWithStatus(
    tenant: Tenant(
      id: 't-3',
      name: 'Ahmad Fauzi',
      phone: '081987654321',
      createdAt: now,
      updatedAt: now,
    ),
    status: TenantStatus.overdue,
    hasActiveOccupancy: false,
    currentRoomNumber: '102',
  );

  final tenantEnded = TenantWithStatus(
    tenant: Tenant(
      id: 't-4',
      name: 'Dewi Lestari',
      phone: '082133445566',
      createdAt: now,
      updatedAt: now,
    ),
    status: TenantStatus.ended,
    hasActiveOccupancy: false,
    currentRoomNumber: '103',
  );

  final tenantUnassigned = TenantWithStatus(
    tenant: Tenant(
      id: 't-5',
      name: 'Eko Prasetyo',
      phone: '081399887766',
      createdAt: now,
      updatedAt: now,
    ),
    status: TenantStatus.unassigned,
    hasActiveOccupancy: false,
    currentRoomNumber: null,
  );

  group('Pure Filter Tests (matchesFilter)', () {
    test('TenantFilter.all matches every tenant status', () {
      expect(matchesFilter(tenantActive, TenantFilter.all), isTrue);
      expect(matchesFilter(tenantOverdueActive, TenantFilter.all), isTrue);
      expect(matchesFilter(tenantOverdueEnded, TenantFilter.all), isTrue);
      expect(matchesFilter(tenantEnded, TenantFilter.all), isTrue);
      expect(matchesFilter(tenantUnassigned, TenantFilter.all), isTrue);
    });

    test('TenantFilter.active matches only tenants with hasActiveOccupancy == true', () {
      expect(matchesFilter(tenantActive, TenantFilter.active), isTrue);
      expect(matchesFilter(tenantOverdueActive, TenantFilter.active), isTrue);
      expect(matchesFilter(tenantOverdueEnded, TenantFilter.active), isFalse);
      expect(matchesFilter(tenantEnded, TenantFilter.active), isFalse);
      expect(matchesFilter(tenantUnassigned, TenantFilter.active), isFalse);
    });

    test(
      'TenantFilter.overdue matches only tenants with status == overdue',
      () {
        expect(matchesFilter(tenantActive, TenantFilter.overdue), isFalse);
        expect(
          matchesFilter(tenantOverdueActive, TenantFilter.overdue),
          isTrue,
        );
        expect(matchesFilter(tenantOverdueEnded, TenantFilter.overdue), isTrue);
        expect(matchesFilter(tenantEnded, TenantFilter.overdue), isFalse);
        expect(matchesFilter(tenantUnassigned, TenantFilter.overdue), isFalse);
      },
    );

    test(
      'TenantFilter.ended matches ended or overdue without active occupancy',
      () {
        expect(matchesFilter(tenantActive, TenantFilter.ended), isFalse);
        expect(matchesFilter(tenantOverdueActive, TenantFilter.ended), isFalse);
        expect(matchesFilter(tenantOverdueEnded, TenantFilter.ended), isTrue);
        expect(matchesFilter(tenantEnded, TenantFilter.ended), isTrue);
        expect(matchesFilter(tenantUnassigned, TenantFilter.ended), isFalse);
      },
    );

    test('unassigned tenant only ever matches TenantFilter.all', () {
      expect(matchesFilter(tenantUnassigned, TenantFilter.all), isTrue);
      expect(matchesFilter(tenantUnassigned, TenantFilter.active), isFalse);
      expect(matchesFilter(tenantUnassigned, TenantFilter.overdue), isFalse);
      expect(matchesFilter(tenantUnassigned, TenantFilter.ended), isFalse);
    });
  });

  group('Pure Search Tests (matchesSearch)', () {
    test('empty query matches all', () {
      expect(matchesSearch(tenantActive, ''), isTrue);
      expect(matchesSearch(tenantActive, '   '), isTrue);
    });

    test('name substring match is case-insensitive', () {
      expect(matchesSearch(tenantActive, 'budi'), isTrue);
      expect(matchesSearch(tenantActive, 'BUDI'), isTrue);
      expect(matchesSearch(tenantActive, 'SANTO'), isTrue);
      expect(matchesSearch(tenantActive, 'joko'), isFalse);
    });

    test('room number substring match', () {
      expect(matchesSearch(tenantActive, '101'), isTrue);
      expect(matchesSearch(tenantOverdueActive, '03'), isTrue);
      expect(matchesSearch(tenantActive, '999'), isFalse);
    });

    test('phone match: query < 4 digits does NOT match phone', () {
      // tenantOverdueActive phone is '085712345678', room is '03'
      // Query '03' matches room '03'
      expect(matchesSearch(tenantOverdueActive, '03'), isTrue);

      // tenantActive phone contains '12' ('+6281234567890'), room is '101'
      // Query '12' has only 2 digits -> must NOT match phone
      expect(matchesSearch(tenantActive, '12'), isFalse);
    });

    test('phone match: query with >= 4 digits normalizes leading 0 to 62', () {
      // tenantActive phone is '+6281234567890'
      expect(matchesSearch(tenantActive, '0812'), isTrue);
      expect(matchesSearch(tenantActive, '+62812'), isTrue);
      expect(matchesSearch(tenantActive, '62 812'), isTrue);
      expect(matchesSearch(tenantActive, '3456'), isTrue);
      expect(matchesSearch(tenantActive, '9999'), isFalse);
    });

    test('phone match: query with 0857 matches 085712345678', () {
      expect(matchesSearch(tenantOverdueActive, '0857'), isTrue);
      expect(matchesSearch(tenantOverdueActive, '+62857'), isTrue);
      expect(matchesSearch(tenantOverdueActive, '1234'), isTrue);
    });
  });

  group('Tenant Providers State and Counts with In-Memory DB', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      // 1. Seed property
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-1',
              name: 'Kos Melati',
              address: 'Jl. Melati',
              contact: '081234',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 2. Seed rooms
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
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-2',
              propertyId: 'prop-1',
              number: '03',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-3',
              propertyId: 'prop-1',
              number: '102',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: 'room-4',
              propertyId: 'prop-1',
              number: '103',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 3. Seed tenants and occupancies
      // Tenant 1: Budi Santoso (Active in room 101)
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-1',
              name: 'Budi Santoso',
              phone: '+6281234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-1',
              tenantId: 't-1',
              roomId: 'room-1',
              startDate: now,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Tenant 2: Siti Rahma (Overdue & Active in room 03)
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-2',
              name: 'Siti Rahma',
              phone: '085712345678',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-2',
              tenantId: 't-2',
              roomId: 'room-2',
              startDate: yesterday,
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'active',
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          );
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-2',
              occupancyId: 'occ-2',
              type: 'rent',
              description: 'Sewa',
              amount: 1500000,
              periodStart: yesterday,
              periodEnd: now,
              dueDate: yesterday,
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          );

      // Tenant 3: Ahmad Fauzi (Overdue & Ended from room 102)
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-3',
              name: 'Ahmad Fauzi',
              phone: '081987654321',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-3',
              tenantId: 't-3',
              roomId: 'room-3',
              startDate: yesterday.subtract(const Duration(days: 30)),
              actualEndDate: Value(yesterday),
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'ended',
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          );
      await db
          .into(db.charges)
          .insert(
            ChargesCompanion.insert(
              id: 'ch-3',
              occupancyId: 'occ-3',
              type: 'rent',
              description: 'Sewa',
              amount: 1500000,
              periodStart: yesterday.subtract(const Duration(days: 30)),
              periodEnd: yesterday,
              dueDate: yesterday,
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          );

      // Tenant 4: Dewi Lestari (Ended from room 103)
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-4',
              name: 'Dewi Lestari',
              phone: '082133445566',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.occupancies)
          .insert(
            OccupanciesCompanion.insert(
              id: 'occ-4',
              tenantId: 't-4',
              roomId: 'room-4',
              startDate: yesterday.subtract(const Duration(days: 30)),
              actualEndDate: Value(yesterday),
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'ended',
              createdAt: yesterday,
              updatedAt: yesterday,
            ),
          );

      // Tenant 5: Eko Prasetyo (Unassigned)
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-5',
              name: 'Eko Prasetyo',
              phone: '081399887766',
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test(
      'tenantChipCountsProvider calculates counts before search query',
      () async {
        await container.read(activePropertyProvider.future);
        final sub = container.listen(tenantListProvider, (_, _) {});
        addTearDown(sub.close);

        final initialTenants = await container.read(tenantListProvider.future);
        expect(initialTenants.length, 5);

        final countsInitial = container.read(tenantChipCountsProvider);
        expect(countsInitial.all, 5);
        expect(
          countsInitial.active,
          2,
        ); // Budi (active), Siti (overdue & active)
        expect(countsInitial.overdue, 2); // Siti, Ahmad
        expect(countsInitial.ended, 2); // Ahmad, Dewi

        // Apply search query that matches only 1 tenant
        container.read(searchQueryProvider.notifier).setQuery('Budi');

        final filtered = container.read(filteredTenantsProvider);
        expect(filtered.length, 1);
        expect(filtered.first.tenant.name, 'Budi Santoso');

        // Chip counts must REMAIN 5 / 2 / 2 / 2 (unaffected by search)
        final countsAfterSearch = container.read(tenantChipCountsProvider);
        expect(countsAfterSearch.all, 5);
        expect(countsAfterSearch.active, 2);
        expect(countsAfterSearch.overdue, 2);
        expect(countsAfterSearch.ended, 2);
      },
    );

    test(
      'filteredTenantsProvider applies filter and search together',
      () async {
        await container.read(activePropertyProvider.future);
        final sub = container.listen(tenantListProvider, (_, _) {});
        addTearDown(sub.close);

        await container.read(tenantListProvider.future);

        // Select 'Menunggak' filter
        container
            .read(statusFilterProvider.notifier)
            .setFilter(TenantFilter.overdue);
        var filtered = container.read(filteredTenantsProvider);
        expect(filtered.length, 2);

        // Search 'Rahma' within 'Menunggak'
        container.read(searchQueryProvider.notifier).setQuery('Rahma');
        filtered = container.read(filteredTenantsProvider);
        expect(filtered.length, 1);
        expect(filtered.first.tenant.name, 'Siti Rahma');

        // Search 'Budi' within 'Menunggak' -> none
        container.read(searchQueryProvider.notifier).setQuery('Budi');
        filtered = container.read(filteredTenantsProvider);
        expect(filtered.isEmpty, isTrue);
      },
    );

    test('tenantListProvider loading guard: stays in loading while active property resolves', () async {
      // Fresh container without awaiting activePropertyProvider
      final testContainer = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(testContainer.dispose);

      // Before activeProperty finishes, tenantListProvider is in AsyncLoading
      final initialValue = testContainer.read(tenantListProvider);
      expect(initialValue.isLoading, isTrue);
      expect(initialValue.hasValue, isFalse);

      // After activeProperty resolves, tenantListProvider emits data
      final sub = testContainer.listen(tenantListProvider, (_, _) {});
      addTearDown(sub.close);

      final loaded = await testContainer.read(tenantListProvider.future);
      expect(loaded, isNotEmpty);
    });
  });
}
