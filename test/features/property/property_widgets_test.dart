import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/theme/theme.dart';
import 'package:kosm/features/property/data/property_dao.dart';
import 'package:kosm/features/property/data/property_repository_impl.dart';
import 'package:kosm/features/property/domain/property.dart';
import 'package:kosm/features/property/presentation/pages/onboarding_page.dart';
import 'package:kosm/features/property/presentation/pages/property_form_page.dart';
import 'package:kosm/features/property/presentation/pages/property_list_page.dart';

import '../../helpers/pump_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });
  });

  Widget wrapWithTheme(Widget child) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home Page')),
        ),
        GoRoute(
          path: '/more/properties/add',
          builder: (_, _) => const Scaffold(body: Text('Add Property Page')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('Property Feature Widget Tests', () {
    final now = DateTime.now().toUtc();

    testWidgets('OnboardingPage renders form and validates name', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme(const OnboardingPage()));
      await tester.pumpAndSettle();

      // Check header and inputs
      expect(find.text('Selamat Datang di KosM'), findsOneWidget);
      expect(find.text('Simpan & Mulai Kelola'), findsOneWidget);
      expect(find.text('Nama Kos'), findsOneWidget);

      // Ensure button is visible before tap
      await tester.ensureVisible(find.text('Simpan & Mulai Kelola'));
      await tester.pumpAndSettle();

      // Tap submit with empty name
      await tester.tap(find.text('Simpan & Mulai Kelola'));
      await tester.pumpAndSettle();

      // Error message should appear
      expect(find.text('Nama kos wajib diisi'), findsOneWidget);

      // Enter name and submit
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Kos Melati Indah');
      await tester.ensureVisible(find.text('Simpan & Mulai Kelola'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan & Mulai Kelola'));
      await tester.pumpAndSettle();

      // Verify property created in DB
      final props = await db.select(db.properties).get();
      expect(props.length, 1);
      expect(props.first.name, 'Kos Melati Indah');

      await disposeApp(tester);
    });

    testWidgets('PropertyListPage shows empty state when no properties exist', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme(const PropertyListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Kos'), findsOneWidget);
      expect(find.text('Tambah Kos'), findsWidgets);

      await disposeApp(tester);
    });

    testWidgets(
      'PropertyListPage shows list of properties and handles delete dialog',
      (tester) async {
        setPhoneScreen(tester);

        // Seed a property
        final prop = Property(
          id: 'prop-1',
          name: 'Kos Graha Melati',
          address: 'Jl. Melati No. 12',
          contact: '08123456789',
          createdAt: now,
          updatedAt: now,
        );
        final repo = PropertyRepositoryImpl(PropertyDao(db));
        await repo.create(prop);

        await tester.pumpWidget(wrapWithTheme(const PropertyListPage()));
        await tester.pumpAndSettle();

        // Verify property card renders
        expect(find.text('Kos Graha Melati'), findsOneWidget);
        expect(find.text('Jl. Melati No. 12'), findsOneWidget);

        // Tap delete button
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        // Verify confirm dialog opens
        expect(find.text('Hapus Kos?'), findsOneWidget);
        expect(
          find.text(
            'Menghapus kos ini akan menghapus data kamar yang terkait. Kos yang masih memiliki penghuni aktif tidak dapat dihapus. Tindakan ini tidak dapat dibatalkan.',
          ),
          findsOneWidget,
        );

        // Tap Batal
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        // Property still exists
        expect(find.text('Kos Graha Melati'), findsOneWidget);

        await disposeApp(tester);
      },
    );

    testWidgets('PropertyFormPage creates property on submit', (tester) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme(const PropertyFormPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Kos'), findsOneWidget);

      // Enter name, address, contact
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Kos Mawar');
      await tester.enterText(textFields.at(1), 'Jl. Mawar No. 5');
      await tester.enterText(textFields.at(2), '08123456789');

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final props = await db.select(db.properties).get();
      expect(props.length, 1);
      expect(props.first.name, 'Kos Mawar');
      expect(props.first.address, 'Jl. Mawar No. 5');
      expect(props.first.contact, '08123456789');

      await disposeApp(tester);
    });
  });
}
