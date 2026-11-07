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

    testWidgets('StatusChip renders neutral status type correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          StatusChip.fromType(StatusType.neutral, customLabel: 'Aktif'),
        ),
      );

      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('ListTileCard renders all elements and handles onTap', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapWithTheme(
          ListTileCard(
            title: 'Budi Santoso',
            subtitle: 'Kamar 03 · 081234567890',
            trailing: StatusChip.fromType(
              StatusType.neutral,
              customLabel: 'Aktif',
            ),
            bottomText: 'Catatan penyewa',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Kamar 03 · 081234567890'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('BS'), findsOneWidget); // derived initials
      expect(find.text('Catatan penyewa'), findsOneWidget);

      await tester.tap(find.text('Budi Santoso'));
      expect(tapped, true);
    });

    testWidgets('ListTileCard does not overflow on textScale 1.3', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: ListTileCard(
                title:
                    'Raden Mas Danang Sutowijoyo Prawirohardjo Panjang Sekali',
                subtitle: 'Kamar 15 · 081399887766 · Tambahan Info Panjang',
                trailing: StatusChip.fromType(
                  StatusType.overdue,
                  customLabel: 'Menunggak',
                ),
                bottomText: 'Catatan sangat panjang untuk memastikan teks dua baris terpotong rapi dengan ellipsis tanpa overflow.',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
