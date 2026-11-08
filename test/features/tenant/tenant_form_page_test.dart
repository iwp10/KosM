import 'dart:io';

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
import 'package:kosm/features/tenant/data/id_photo_storage_impl.dart';
import 'package:kosm/features/tenant/domain/id_photo_picker.dart';
import 'package:kosm/features/tenant/domain/id_photo_storage.dart';
import 'package:kosm/features/tenant/presentation/pages/tenant_form_page.dart';
import 'package:kosm/features/tenant/presentation/providers/tenant_providers.dart';

import '../../helpers/pump_helpers.dart';

class FakeIdPhotoPicker implements IdPhotoPicker {
  String? nextPhotoPath;
  Exception? errorToThrow;

  @override
  Future<String?> takePhoto() async {
    if (errorToThrow != null) throw errorToThrow!;
    return nextPhotoPath;
  }

  @override
  Future<String?> pickFromGallery() async {
    if (errorToThrow != null) throw errorToThrow!;
    return nextPhotoPath;
  }
}

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late IdPhotoStorage storage;
  late FakeIdPhotoPicker picker;
  final now = DateTime.utc(2026, 11, 7, 10, 0, 0);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('kosm_form_test_');
    storage = IdPhotoStorageImpl(baseDirResolver: () async => tempDir);
    picker = FakeIdPhotoPicker();
    addTearDown(() async {
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Seed property
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

  Widget wrapWithTheme({String? tenantId}) {
    final router = GoRouter(
      initialLocation: tenantId == null
          ? '/tenants/new'
          : '/tenants/$tenantId/edit',
      routes: [
        GoRoute(
          path: '/tenants',
          builder: (_, _) =>
              const Scaffold(body: Text('Daftar Penyewa Placeholder')),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const TenantFormPage()),
            GoRoute(
              path: ':id/edit',
              builder: (_, state) =>
                  TenantFormPage(tenantId: state.pathParameters['id']),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        idPhotoStorageProvider.overrideWithValue(storage),
        idPhotoPickerProvider.overrideWithValue(picker),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('TenantFormPage Widget Tests', () {
    testWidgets('Validates name and displays error on name field', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      // Enter phone but leave name empty
      final phoneField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantPhoneLabel,
      );
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextField)),
        '81234567890',
      );

      final saveButton = find.widgetWithText(
        PrimaryButton,
        AppStrings.saveTenant,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Nama penyewa wajib diisi.'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Validates phone and displays error on phone field', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNameLabel,
      );
      await tester.enterText(
        find.descendant(of: nameField, matching: find.byType(TextField)),
        'Budi Santoso',
      );

      // Invalid short phone number
      final phoneField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantPhoneLabel,
      );
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextField)),
        '123',
      );

      final saveButton = find.widgetWithText(
        PrimaryButton,
        AppStrings.saveTenant,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Nomor HP Indonesia harus berawalan 8.'),
        findsOneWidget,
      );

      await disposeApp(tester);
    });

    testWidgets('Validates max length for name and note', (tester) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNameLabel,
      );
      final phoneField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantPhoneLabel,
      );
      final noteField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNoteLabel,
      );

      await tester.enterText(
        find.descendant(of: nameField, matching: find.byType(TextField)),
        'Budi Santoso',
      );
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextField)),
        '81234567890',
      );
      // 301 characters note
      await tester.enterText(
        find.descendant(of: noteField, matching: find.byType(TextField)),
        'A' * 301,
      );

      final saveButton = find.widgetWithText(
        PrimaryButton,
        AppStrings.saveTenant,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noteMaxLengthExceeded), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('Saves tenant with normalized phone (+62 format)', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNameLabel,
      );
      final phoneField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantPhoneLabel,
      );
      final noteField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNoteLabel,
      );

      await tester.enterText(
        find.descendant(of: nameField, matching: find.byType(TextField)),
        'Budi Santoso',
      );
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextField)),
        '81234567890',
      );
      await tester.enterText(
        find.descendant(of: noteField, matching: find.byType(TextField)),
        'Catatan penyewa baru',
      );

      final saveButton = find.widgetWithText(
        PrimaryButton,
        AppStrings.saveTenant,
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify snackbar message
      expect(find.text(AppStrings.tenantSavedSuccess), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify DB record
      final tenantsInDb = await db.select(db.tenants).get();
      expect(tenantsInDb.length, 1);
      expect(tenantsInDb.first.name, 'Budi Santoso');
      expect(tenantsInDb.first.phone, '+6281234567890');
      expect(tenantsInDb.first.note, 'Catatan penyewa baru');

      await disposeApp(tester);
    });

    testWidgets(
      'Three phone input formats (0812..., 812..., +62812...) all save identically',
      (tester) async {
        setPhoneScreen(tester);

        final testFormats = ['081234567890', '81234567890', '+6281234567890'];

        for (var i = 0; i < testFormats.length; i++) {
          final format = testFormats[i];
          await tester.pumpWidget(wrapWithTheme());
          await tester.pumpAndSettle();

          final nameField = find.widgetWithText(
            AppTextField,
            AppStrings.tenantNameLabel,
          );
          final phoneField = find.widgetWithText(
            AppTextField,
            AppStrings.tenantPhoneLabel,
          );

          await tester.enterText(
            find.descendant(of: nameField, matching: find.byType(TextField)),
            'Penyewa $i',
          );
          await tester.enterText(
            find.descendant(of: phoneField, matching: find.byType(TextField)),
            format,
          );

          final saveButton = find.widgetWithText(
            PrimaryButton,
            AppStrings.saveTenant,
          );
          await tester.ensureVisible(saveButton);
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }

        final allTenants = await db.select(db.tenants).get();
        expect(allTenants.length, 3);
        for (final t in allTenants) {
          expect(t.phone, '+6281234567890');
        }

        await disposeApp(tester);
      },
    );

    testWidgets(
      'Edit mode: loads existing tenant, strips +62 prefix, and updates data',
      (tester) async {
        setPhoneScreen(tester);

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-edit',
                name: 'Budi Lama',
                phone: '+6281234567890',
                note: const Value('Catatan lama'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-edit'));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.editTenantTitle), findsOneWidget);
        expect(find.text('Budi Lama'), findsOneWidget);
        // In edit mode: phone controller has 81234567890 (stripped of +62)
        final phoneInput = tester.widget<TextField>(
          find.descendant(
            of: find.widgetWithText(AppTextField, AppStrings.tenantPhoneLabel),
            matching: find.byType(TextField),
          ),
        );
        expect(phoneInput.controller?.text, '81234567890');
        expect(find.text('Catatan lama'), findsOneWidget);

        // Edit name and note
        final nameField = find.widgetWithText(
          AppTextField,
          AppStrings.tenantNameLabel,
        );
        final noteField = find.widgetWithText(
          AppTextField,
          AppStrings.tenantNoteLabel,
        );

        await tester.enterText(
          find.descendant(of: nameField, matching: find.byType(TextField)),
          'Budi Baru',
        );
        await tester.enterText(
          find.descendant(of: noteField, matching: find.byType(TextField)),
          'Catatan baru',
        );

        final saveButton = find.widgetWithText(
          PrimaryButton,
          AppStrings.saveTenant,
        );
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify update in DB
        final updated = await (db.select(
          db.tenants,
        )..where((t) => t.id.equals('t-edit'))).getSingle();
        expect(updated.name, 'Budi Baru');
        expect(updated.phone, '+6281234567890');
        expect(updated.note, 'Catatan baru');

        await disposeApp(tester);
      },
    );

    testWidgets('Rapid double tap on save button creates only ONE tenant', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(wrapWithTheme());
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantNameLabel,
      );
      final phoneField = find.widgetWithText(
        AppTextField,
        AppStrings.tenantPhoneLabel,
      );

      await tester.enterText(
        find.descendant(of: nameField, matching: find.byType(TextField)),
        'Budi Santoso',
      );
      await tester.enterText(
        find.descendant(of: phoneField, matching: find.byType(TextField)),
        '81234567890',
      );

      final saveButton = find.widgetWithText(
        PrimaryButton,
        AppStrings.saveTenant,
      );
      await tester.ensureVisible(saveButton);

      // Rapid consecutive taps (simulating user tapping screen twice rapidly)
      await tester.tap(saveButton);
      await tester.tapAt(tester.getCenter(saveButton));
      await tester.pumpAndSettle();

      final allTenants = await db.select(db.tenants).get();
      expect(allTenants.length, 1);

      await disposeApp(tester);
    });

    testWidgets(
      'Save button is reachable on small viewport 400x500 via scroll',
      (tester) async {
        tester.view.physicalSize = const Size(400, 500);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(wrapWithTheme());
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithText(
          PrimaryButton,
          AppStrings.saveTenant,
        );
        await tester.ensureVisible(saveButton);
        await tester.pumpAndSettle();

        expect(saveButton, findsOneWidget);

        await disposeApp(tester);
      },
    );

    testWidgets('textScale 1.3 renders TenantFormPage without overflow', (
      tester,
    ) async {
      setPhoneScreen(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: ProviderScope(
              overrides: [appDatabaseProvider.overrideWithValue(db)],
              child: const TenantFormPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await disposeApp(tester);
    });

    testWidgets(
      'Photo card: picking photo shows preview, pop without save cleans up temp file',
      (tester) async {
        setPhoneScreen(tester);

        final tempKtp = File('${tempDir.path}/temp_sample.jpg');
        await tempKtp.writeAsString('fake-ktp-data');
        picker.nextPhotoPath = tempKtp.path;

        await tester.pumpWidget(wrapWithTheme());
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.idPhotoSectionTitle), findsOneWidget);
        expect(find.text(AppStrings.takePhoto), findsOneWidget);
        expect(find.text(AppStrings.chooseFromGallery), findsOneWidget);

        // Tap Ambil Foto
        final takePhotoBtn = find.text(AppStrings.takePhoto);
        await tester.ensureVisible(takePhotoBtn);
        await tester.tap(takePhotoBtn);
        await tester.pumpAndSettle();

        // Preview should now show "Ganti Foto" and "Hapus Foto"
        expect(find.text(AppStrings.changePhoto), findsOneWidget);
        expect(find.text(AppStrings.deletePhoto), findsOneWidget);

        // Now leave the page without saving (dispose/pop)
        await disposeApp(tester);

        // Temp file should be deleted on dispose when not saved
        expect(await tempKtp.exists(), isFalse);
      },
    );

    testWidgets(
      'Photo card: saving persists chosen photo to database and storage',
      (tester) async {
        setPhoneScreen(tester);

        final tempKtp = File('${tempDir.path}/temp_save.jpg');
        await tempKtp.writeAsString('saved-ktp-bytes');
        picker.nextPhotoPath = tempKtp.path;

        await tester.pumpWidget(wrapWithTheme());
        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(
          AppTextField,
          AppStrings.tenantNameLabel,
        );
        final phoneField = find.widgetWithText(
          AppTextField,
          AppStrings.tenantPhoneLabel,
        );

        await tester.enterText(
          find.descendant(of: nameField, matching: find.byType(TextField)),
          'Budi Ada Foto',
        );
        await tester.enterText(
          find.descendant(of: phoneField, matching: find.byType(TextField)),
          '81234567890',
        );

        // Tap Pilih dari Galeri
        final galleryBtn = find.text(AppStrings.chooseFromGallery);
        await tester.ensureVisible(galleryBtn);
        await tester.tap(galleryBtn);
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithText(
          PrimaryButton,
          AppStrings.saveTenant,
        );
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(AppStrings.tenantSavedSuccess), findsOneWidget);
        await tester.pumpAndSettle();

        final inDb = await db.select(db.tenants).get();
        expect(inDb.length, 1);
        expect(inDb.first.idPhotoPath, isNotNull);
        expect(inDb.first.idPhotoPath!.startsWith('id_photos/'), isTrue);
        expect(await storage.fileExists(inDb.first.idPhotoPath!), isTrue);

        await disposeApp(tester);
      },
    );

    testWidgets(
      'Photo card: delete photo button removes preview and clears photo on save',
      (tester) async {
        setPhoneScreen(tester);

        // Seed tenant with existing photo
        final existingPhotoFile = File(
          '${tempDir.path}/id_photos/t-delphoto-1.jpg',
        );
        await existingPhotoFile.create(recursive: true);
        await existingPhotoFile.writeAsString('existing-photo');

        await db
            .into(db.tenants)
            .insert(
              TenantsCompanion.insert(
                id: 't-delphoto',
                name: 'Budi Edit Foto',
                phone: '+6281234567890',
                idPhotoPath: const Value('id_photos/t-delphoto-1.jpg'),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await tester.pumpWidget(wrapWithTheme(tenantId: 't-delphoto'));
        await tester.pumpAndSettle();

        // Should show change and delete photo buttons
        expect(find.text(AppStrings.changePhoto), findsOneWidget);
        final deletePhotoBtn = find.text(AppStrings.deletePhoto);
        expect(deletePhotoBtn, findsOneWidget);

        // Tap delete photo
        await tester.ensureVisible(deletePhotoBtn);
        await tester.tap(deletePhotoBtn);
        await tester.pumpAndSettle();

        // Now buttons should revert to Ambil Foto & Pilih dari Galeri
        expect(find.text(AppStrings.takePhoto), findsOneWidget);
        expect(find.text(AppStrings.chooseFromGallery), findsOneWidget);

        // Save
        final saveButton = find.widgetWithText(
          PrimaryButton,
          AppStrings.saveTenant,
        );
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        final inDb = await (db.select(
          db.tenants,
        )..where((t) => t.id.equals('t-delphoto'))).getSingle();
        expect(inDb.idPhotoPath, isNull);
        expect(await existingPhotoFile.exists(), isFalse);

        await disposeApp(tester);
      },
    );
  });
}
