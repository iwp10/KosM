import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/app.dart';

void main() {
  testWidgets('Router shell bottom navigation switches tabs correctly', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: KosMApp()));
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
    expect(find.text('Kelola data penyewa kos Anda di sini.'), findsOneWidget);

    // Switch to Kamar tab
    await tester.tap(find.text('Kamar'));
    await tester.pumpAndSettle();
    expect(find.text('Data Kamar'), findsAtLeastNWidgets(1));
    expect(find.text('Daftar dan ketersediaan kamar di sini.'), findsOneWidget);

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
    expect(find.text('Menu Lainnya'), findsAtLeastNWidgets(1));
    expect(
      find.text('Pengingat, cadangan, laporan, dan pengaturan.'),
      findsOneWidget,
    );
  });
}
