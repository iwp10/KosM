import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/app.dart';

void main() {
  testWidgets('KosMApp smoke test and visual preview renders', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const KosMApp());
    await tester.pumpAndSettle();

    // Verify header and first sections.
    expect(find.text('1. Tipografi (Plus Jakarta Sans)'), findsOneWidget);
    expect(find.text('Display 28: Rp1.500.000'), findsOneWidget);
    expect(find.text('Status Kamar:'), findsOneWidget);

    // Scroll down to reveal buttons and form sections.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Simpan Data Penyewa'), findsOneWidget);

    // Scroll further down to reveal empty state.
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Penyewa'), findsOneWidget);
  });
}
