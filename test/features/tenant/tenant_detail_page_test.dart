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
import 'package:kosm/features/tenant/domain/tenant.dart';
import 'package:kosm/features/tenant/presentation/pages/tenant_detail_page.dart';
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

    // Seed property and room
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

  Widget wrapWithTheme({
    required String tenantId,
    List<dynamic> overrides = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/tenants/$tenantId',
      routes: [
        GoRoute(
          path: '/tenants',
          builder: (_, _) => const Scaffold(body: Text('Daftar Penyewa Page')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  TenantDetailPage(id: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, state) => Scaffold(
                    body: Text(
                      'Edit Tenant Page ${state.pathParameters['id']}',
                    ),
                  ),
                ),
              ],
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

  group('TenantDetailPage Widget Tests', () {
    testWidgets('Loading State: renders skeleton cards without timers', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          tenantId: 't-loading',
          overrides: [
            tenantDetailProvider('t-loading')
                .overrideWith((ref) => const Stream.empty()),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(AppCard), findsWidgets);

      await disposeApp(tester);
    });

    testWidgets('Not Found State: displays friendly message and back button', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme(tenantId: 't-non-existent'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.tenantNotFoundTitle), findsOneWidget);
      expect(find.text(AppStrings.tenantNotFoundDesc), findsOneWidget);
      expect(find.text(AppStrings.backToTenantList), findsOneWidget);

      // Tap back button
      await tester.tap(
        find.widgetWithText(PrimaryButton, AppStrings.backToTenantList),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daftar Penyewa Page'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Error State: renders error message and retry button', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          tenantId: 't-error',
          overrides: [
            tenantDetailProvider('t-error').overrideWith(
              (ref) => Stream<TenantWithStatus?>.error('Gagal membuka koneksi'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loadTenantsError), findsOneWidget);
      expect(find.text('Gagal membuka koneksi'), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets(
      'Data State: renders profile, status chip, info, and placeholders',
      (tester) async {
        setPhoneScreen(tester);

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-1',
                name: 'Budi Santoso',
                phone: '+6281234567890',
                note: const Value('Catatan kunci pos satpam'),
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

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-1'));
        await tester.pumpAndSettle();

        // Check header info
        expect(find.text('Budi Santoso'), findsOneWidget);
        expect(find.text('BS'), findsOneWidget); // Initials
        expect(find.text('Kamar 101'), findsOneWidget);
        expect(find.text(AppStrings.statusActive), findsOneWidget);

        // Check info card
        expect(find.text('+6281234567890'), findsOneWidget);
        expect(find.text('Catatan kunci pos satpam'), findsOneWidget);

        // Check Fase 2 placeholders
        expect(find.text(AppStrings.noOccupancyTitle), findsOneWidget);
        expect(find.text(AppStrings.noPaymentTitle), findsOneWidget);

        await disposeApp(tester);
      },
    );

    testWidgets(
      'Stream reactivity: detail page updates when tenant data changes',
      (tester) async {
        setPhoneScreen(tester);

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-stream',
                name: 'Nama Awal',
                phone: '+6281234567890',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-stream'));
        await tester.pumpAndSettle();

        expect(find.text('Nama Awal'), findsOneWidget);

        // Update tenant in DB
        await (db.update(db.tenants)..where((t) => t.id.equals('t-stream')))
            .write(const TenantsCompanion(name: Value('Nama Terbarui')));

        await tester.pumpAndSettle();

        expect(find.text('Nama Terbarui'), findsOneWidget);
        expect(find.text('Nama Awal'), findsNothing);

        await disposeApp(tester);
      },
    );

    testWidgets('Menu navigates to edit page', (tester) async {
      setPhoneScreen(tester);

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

      await tester.pumpWidget(wrapWithTheme(tenantId: 't-1'));
      await tester.pumpAndSettle();

      // Open 3-dots popup menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Tap Ubah
      await tester.tap(find.text(AppStrings.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Tenant Page t-1'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets(
      'Delete flow: confirms and soft-deletes tenant without flashing 404',
      (tester) async {
        setPhoneScreen(tester);

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-del',
                name: 'Penyewa Dihapus',
                phone: '+6281234567890',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-del'));
        await tester.pumpAndSettle();

        // Open menu
        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();

        // Tap Hapus
        await tester.tap(find.text(AppStrings.delete));
        await tester.pumpAndSettle();

        // ConfirmDialog is displayed
        expect(find.text(AppStrings.deleteTenantTitle), findsOneWidget);
        expect(
          find.text(AppStrings.deleteTenantConfirmMessage),
          findsOneWidget,
        );

        // Tap confirm button
        final confirmBtn = find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text(AppStrings.delete),
        );
        await tester.tap(confirmBtn);
        await tester.pump();

        // Regression test: ensure 404 message did NOT flash
        expect(find.text(AppStrings.tenantNotFoundTitle), findsNothing);

        await tester.pumpAndSettle();

        // Popped back to tenant list with snackbar
        expect(find.text('Daftar Penyewa Page'), findsOneWidget);
        expect(find.text(AppStrings.tenantDeletedSuccess), findsOneWidget);

        // Verify soft delete in DB
        final record = await (db.select(
          db.tenants,
        )..where((t) => t.id.equals('t-del'))).getSingle();
        expect(record.deletedAt, isNotNull);

        await disposeApp(tester);
      },
    );

    testWidgets(
      'Delete rejection when tenant has active occupancy shows single-button dialog',
      (tester) async {
        setPhoneScreen(tester);

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-active-occ',
                name: 'Penyewa Masih Aktif',
                phone: '+6281234567890',
                createdAt: now,
                updatedAt: now,
              ),
            );
        await db
            .into(db.occupancies)
            .insert(
              OccupanciesCompanion.insert(
                id: 'occ-active',
                tenantId: 't-active-occ',
                roomId: 'room-1',
                startDate: now,
                rateType: 'monthly',
                rateAmount: 1500000,
                status: 'active',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-active-occ'));
        await tester.pumpAndSettle();

        // Open menu -> tap Hapus
        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.delete));
        await tester.pumpAndSettle();

        // Confirm in ConfirmDialog
        final confirmBtn = find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text(AppStrings.delete),
        );
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Rejection dialog is displayed with single 'Mengerti' button
        expect(find.text(AppStrings.cannotDeleteTenantTitle), findsOneWidget);
        expect(find.text(AppStrings.cannotDeleteTenantMessage), findsOneWidget);
        expect(find.text(AppStrings.understandAction), findsOneWidget);
        expect(find.text(AppStrings.cancel), findsNothing); // Single button!

        // Tap Mengerti
        await tester.tap(find.text(AppStrings.understandAction));
        await tester.pumpAndSettle();

        // Detail page remains open and tenant is not deleted
        expect(find.text('Penyewa Masih Aktif'), findsOneWidget);
        final record = await (db.select(
          db.tenants,
        )..where((t) => t.id.equals('t-active-occ'))).getSingle();
        expect(record.deletedAt, isNull);

        await disposeApp(tester);
      },
    );

    testWidgets('textScale 1.3 renders TenantDetailPage without overflow', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 't-scale',
              name: 'Raden Mas Danang Sutowijoyo Prawirohardjo',
              phone: '+6281234567890',
              note: const Value(
                'Catatan sangat panjang untuk memastikan teks tidak menyebabkan overflow.',
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: ProviderScope(
              overrides: [appDatabaseProvider.overrideWithValue(db)],
              child: const TenantDetailPage(id: 't-scale'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    });
  });
}
