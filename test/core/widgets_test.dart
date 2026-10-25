import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/theme/theme.dart';
import 'package:kosm/core/widgets/widgets.dart';

void main() {
  Widget wrapWithTheme(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('Core Widgets', () {
    testWidgets('AppCard renders child and responds to onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapWithTheme(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, true);
    });

    testWidgets('StatusChip renders label and icon correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              StatusChip.fromType(StatusType.vacant),
              StatusChip.fromType(StatusType.paid),
              StatusChip.fromType(StatusType.overdue),
            ],
          ),
        ),
      );

      expect(find.text('Kosong'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      expect(find.text('Menunggak'), findsOneWidget);
    });

    testWidgets('PrimaryButton and SecondaryButton trigger onPressed', (
      tester,
    ) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          Column(
            children: [
              PrimaryButton(
                label: 'Simpan',
                onPressed: () => primaryTapped = true,
              ),
              SecondaryButton(
                label: 'Batal',
                onPressed: () => secondaryTapped = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Simpan'));
      expect(primaryTapped, true);

      await tester.tap(find.text('Batal'));
      expect(secondaryTapped, true);
    });

    testWidgets('SlotIndicator renders correct filled and empty dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(const SlotIndicator(occupied: 2, capacity: 3)),
      );

      expect(find.text('2/3 penghuni'), findsOneWidget);
    });

    testWidgets('RateTypeChip renders label and triggers onSelected', (
      tester,
    ) async {
      RateType? selected;
      await tester.pumpWidget(
        wrapWithTheme(
          RateTypeChip(
            rateType: RateType.monthly,
            onSelected: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Bulanan'), findsOneWidget);
      await tester.tap(find.text('Bulanan'));
      expect(selected, RateType.monthly);
    });

    testWidgets('SyncIndicator renders label and icon', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(const SyncIndicator(state: SyncState.synced)),
      );

      expect(find.text('Tersinkron'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
    });
  });
}
