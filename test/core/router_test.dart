import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/app.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/strings/strings.dart';

import '../helpers/pump_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const KosMApp(),
    );
  }

  testWidgets(
    'Router redirects to /onboarding when database has no properties',
    (tester) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify redirected to onboarding
      expect(find.text('Selamat Datang di KosM'), findsOneWidget);
      expect(find.text('Simpan & Mulai Kelola'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await disposeApp(tester);
    },
  );

  testWidgets(
    'Router shell bottom navigation switches tabs correctly when property exists',
    (tester) async {
      setPhoneScreen(tester);

      // Seed a property so shell renders on /home
      final now = DateTime.now().toUtc();
      await db
          .into(db.properties)
          .insert(
            PropertiesCompanion.insert(
              id: 'prop-1',
              name: 'Kos Graha Melati',
              address: 'Jl. Melati No. 12',
              contact: '08123456789',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify initial route is /home and shows Beranda placeholder
      expect(find.text('Beranda'), findsAtLeastNWidgets(1));
      expect(
        find.text('Ringkasan kos akan ditampilkan di sini.'),
        findsOneWidget,
      );

      // Verify all 5 navigation tabs exist
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Beranda'), findsAtLeastNWidgets(1));
      expect(find.text('Penyewa'), findsOneWidget);
      expect(find.text('Kamar'), findsOneWidget);
      expect(find.text('Bayar'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Switch to Penyewa tab
      await tester.tap(find.text('Penyewa'));
      await tester.pumpAndSettle();
      expect(find.text('Daftar Penyewa'), findsAtLeastNWidgets(1));
      expect(
        find.text('Kelola data penyewa kos Anda di sini.'),
        findsOneWidget,
      );

      // Switch to Kamar tab
      await tester.tap(find.text('Kamar'));
      await tester.pumpAndSettle();
      expect(find.text('Data Kamar'), findsAtLeastNWidgets(1));
      expect(
        find.text('Daftar dan ketersediaan kamar di sini.'),
        findsOneWidget,
      );

      // Switch to Bayar tab
      await tester.tap(find.text('Bayar'));
      await tester.pumpAndSettle();
      expect(find.text('Tagihan & Bayar'), findsAtLeastNWidgets(1));
      expect(
        find.text('Pencatatan tagihan dan pembayaran di sini.'),
        findsOneWidget,
      );

      // Switch to Lainnya tab
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.moreMenuTitle), findsAtLeastNWidgets(1));
      expect(find.text(AppStrings.moreMenuDesc), findsOneWidget);
      expect(find.text(AppStrings.manageProperties), findsOneWidget);

      await disposeApp(tester);
    },
  );
}
