import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/app.dart';
import 'package:kosm/core/router/router.dart';

void main() {
  testWidgets('KosMApp smoke test renders shell with 5 tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: KosMApp()));
    await tester.pumpAndSettle();

    // Verify initial route /home renders Beranda placeholder and bottom nav
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsAtLeastNWidgets(1));
    expect(
      find.text('Ringkasan kos akan ditampilkan di sini.'),
      findsOneWidget,
    );
  });

  testWidgets('KosMApp debug route /dev/preview renders visual preview page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: KosMApp()));
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
  });
}
