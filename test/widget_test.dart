import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/app.dart';
import 'package:kosm/core/database/database.dart';
import 'package:kosm/core/router/router.dart';

import 'helpers/pump_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await db.close();
    });

    // Seed a property so shell renders on /home without redirecting to onboarding
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
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const KosMApp(),
    );
  }

  testWidgets('KosMApp smoke test renders shell with 5 tabs', (
    WidgetTester tester,
  ) async {
    setPhoneScreen(tester);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Verify initial route /home renders Beranda placeholder and bottom nav
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsAtLeastNWidgets(1));
    expect(
      find.text('Ringkasan kos akan ditampilkan di sini.'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('KosMApp debug route /dev/preview renders visual preview page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Navigate to debug preview route
    appRouter.go('/dev/preview');
    await tester.pumpAndSettle();

    // Verify header and preview sections
    expect(find.text('1. Tipografi (Plus Jakarta Sans)'), findsOneWidget);
    expect(find.text('Display 28: Rp1.500.000'), findsOneWidget);
    expect(find.text('Status Kamar:'), findsOneWidget);

    // Scroll down to reveal buttons and form sections
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Simpan Data Penyewa'), findsOneWidget);

    await disposeApp(tester);
  });
}
