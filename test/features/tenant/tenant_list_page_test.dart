import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/strings/strings.dart';
import 'package:kosm/core/theme/theme.dart';
import 'package:kosm/core/widgets/widgets.dart';
import 'package:kosm/features/tenant/presentation/pages/tenant_list_page.dart';
import 'package:kosm/features/tenant/presentation/providers/tenant_providers.dart';

import '../../helpers/pump_helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 11, 7, 10, 0, 0);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });

    // Seed default active property
    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: 'prop-1',
            name: 'Kos Melati',
            address: 'Jl. Melati No. 12',
            contact: '081234567890',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  Widget wrapWithTheme({List<dynamic> overrides = const []}) {
    final router = GoRouter(
      initialLocation: '/tenants',
      routes: [
        GoRoute(
          path: '/tenants',
          builder: (_, _) => const TenantListPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) =>
                  const Scaffold(body: Text('Tambah Penyewa Form Page')),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => Scaffold(
                body: Text('Detail Tenant: ${state.pathParameters['id']}'),
              ),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        ...overrides.cast(),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('TenantListPage Widget Tests', () {
    testWidgets('Empty State: shows empty state when property has no tenants', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.emptyTenantsTitle), findsOneWidget);
      expect(find.text(AppStrings.emptyTenantsDesc), findsOneWidget);
      expect(find.text(AppStrings.addTenant), findsWidgets);

      // Tap action button on EmptyState
      await tester.tap(
        find.widgetWithText(PrimaryButton, AppStrings.addTenant),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tambah Penyewa Form Page'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Loading State: renders skeleton cards without timers', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          overrides: [
            tenantListProvider.overrideWith((ref) => const Stream.empty()),
          ],
        ),
      );
      await tester.pump();

      // AppCards for static skeleton
      expect(find.byType(AppCard), findsWidgets);

      await disposeApp(tester);
    });

    testWidgets('Error State: renders error message and retry button', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          overrides: [
            tenantListProvider.overrideWith(
              (ref) => Stream.error('Koneksi database terputus'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loadTenantsError), findsOneWidget);
      expect(find.text('Koneksi database terputus'), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Data State: renders tenants, filter counts, and chips', (
      tester,
    ) async {
      setPhoneScreen(tester);

      // Seed 2 rooms
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
              number: '102',
              referenceRateType: 'monthly',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Seed tenants
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-1',
              name: 'Budi Santoso',
              phone: '081234567890',
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
              startDate: now.subtract(const Duration(days: 40)),
              actualEndDate: Value(now.subtract(const Duration(days: 10))),
              rateType: 'monthly',
              rateAmount: 1500000,
              status: 'ended',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      // Check tenant cards
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Kamar 101 · 081234567890'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('Kamar 102 · 085712345678'), findsOneWidget);

      // Check chips: exactly 1 chip per card
      expect(
        find.text(AppStrings.statusActive),
        findsWidgets,
      ); // chip in filter row & on card
      expect(
        find.text(AppStrings.statusEnded),
        findsWidgets,
      ); // chip in filter row & on card

      // Check filter counts
      expect(find.text('Semua (2)'), findsOneWidget);
      expect(find.text('Aktif (1)'), findsOneWidget);
      expect(find.text('Menunggak (0)'), findsOneWidget);
      expect(find.text('Keluar (1)'), findsOneWidget);

      // Filter by 'Keluar'
      await tester.ensureVisible(find.text('Keluar (1)'));
      await tester.tap(find.text('Keluar (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNothing);

      // Reset to 'Semua'
      await tester.ensureVisible(find.text('Semua (2)'));
      await tester.tap(find.text('Semua (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Search Debounce and Empty Search Results', (tester) async {
      setPhoneScreen(tester);

      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-1',
              name: 'Budi Santoso',
              phone: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );
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

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);

      // Type in search field
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Budi');

      // Before 250ms debounce
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Siti Rahma'), findsOneWidget);

      // After 250ms debounce
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsNothing);

      // Clear search via clear icon button
      final clearButton = find.byIcon(Icons.close_rounded);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);

      // Search with no matching result
      await tester.enterText(searchField, 'ZzzTidakAda');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noMatchingTenantsTitle), findsOneWidget);
      expect(find.text(AppStrings.noMatchingTenantsDesc), findsOneWidget);
      expect(find.text(AppStrings.clearSearch), findsOneWidget);

      // Tap 'Hapus Pencarian' button
      await tester.tap(
        find.widgetWithText(PrimaryButton, AppStrings.clearSearch),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Rahma'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('FAB navigates to /tenants/new', (tester) async {
      setPhoneScreen(tester);

      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-1',
              name: 'Budi Santoso',
              phone: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      // Find FloatingActionButton with label
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Tambah Penyewa Form Page'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Tapping tenant card navigates to /tenants/:id', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-budi',
              name: 'Budi Santoso',
              phone: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budi Santoso'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Tenant: t-budi'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Tapping tenant card navigates to /tenants/:id', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-budi',
              name: 'Budi Santoso',
              phone: '081234567890',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Budi Santoso'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Tenant: t-budi'), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
