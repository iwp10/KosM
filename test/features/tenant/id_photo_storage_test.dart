import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/errors/app_exception.dart';
import 'package:kosm/features/tenant/data/id_photo_storage_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late IdPhotoStorageImpl storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kosm_storage_test_');
    storage = IdPhotoStorageImpl(baseDirResolver: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('IdPhotoStorageImpl Tests', () {
    test(
      'savePhoto copies file with versioned naming and returns relative path',
      () async {
        final sampleSource = File(p.join(tempDir.path, 'source.jpg'));
        await sampleSource.writeAsString('fake-image-bytes');

        final relPath = await storage.savePhoto(
          tempPath: sampleSource.path,
          tenantId: 'tenant-123',
        );

        expect(relPath.startsWith('id_photos/tenant-123-'), isTrue);
        expect(relPath.endsWith('.jpg'), isTrue);

        final absPath = await storage.resolveAbsolutePath(relPath);
        expect(await File(absPath).exists(), isTrue);
        expect(await File(absPath).readAsString(), 'fake-image-bytes');
      },
    );

    test('savePhoto supports jpg, jpeg, and png (case-insensitive)', () async {
      for (final ext in ['jpg', 'jpeg', 'png', 'JPG', 'PNG']) {
        final sampleSource = File(p.join(tempDir.path, 'source.$ext'));
        await sampleSource.writeAsString('bytes-$ext');

        final relPath = await storage.savePhoto(
          tempPath: sampleSource.path,
          tenantId: 't-$ext',
        );

        expect(relPath.toLowerCase().endsWith('.${ext.toLowerCase()}'), isTrue);
        final absPath = await storage.resolveAbsolutePath(relPath);
        expect(await File(absPath).exists(), isTrue);
      }
    });

    test(
      'savePhoto throws UnsupportedImageFormatException for invalid extension',
      () async {
        final sampleSource = File(p.join(tempDir.path, 'source.pdf'));
        await sampleSource.writeAsString('fake-pdf');

        expect(
          () =>
              storage.savePhoto(tempPath: sampleSource.path, tenantId: 't-pdf'),
          throwsA(isA<UnsupportedImageFormatException>()),
        );
      },
    );

    test('deletePhoto removes existing file and does not throw for non-existent file', () async {
      final sampleSource = File(p.join(tempDir.path, 'source.jpg'));
      await sampleSource.writeAsString('delete-me');

      final relPath = await storage.savePhoto(
        tempPath: sampleSource.path,
        tenantId: 't-del',
      );
      final absPath = await storage.resolveAbsolutePath(relPath);
      expect(await File(absPath).exists(), isTrue);

      await storage.deletePhoto(relPath);
      expect(await File(absPath).exists(), isFalse);

      // Deleting again should not throw
      await expectLater(storage.deletePhoto(relPath), completes);
    });

    test('fileExists accurately checks presence of photo', () async {
      final sampleSource = File(p.join(tempDir.path, 'source.png'));
      await sampleSource.writeAsString('check-exists');

      final relPath = await storage.savePhoto(
        tempPath: sampleSource.path,
        tenantId: 't-exist',
      );

      expect(await storage.fileExists(relPath), isTrue);
      expect(await storage.fileExists('id_photos/non-existent.png'), isFalse);
    });

    test(
      'discardTemp removes temporary file and handles missing file quietly',
      () async {
        final tempFile = File(p.join(tempDir.path, 'temp_sample.png'));
        await tempFile.writeAsString('temp-data');
        expect(await tempFile.exists(), isTrue);

        await storage.discardTemp(tempFile.path);
        expect(await tempFile.exists(), isFalse);

        // Discarding non-existent file should complete without throwing
        await expectLater(storage.discardTemp(tempFile.path), completes);
      },
    );

    test('cleanupOrphans keeps newly modified unreferenced files and deletes old unreferenced files', () async {
      final photoDir = Directory(p.join(tempDir.path, 'id_photos'));
      await photoDir.create(recursive: true);

      // 1. Referenced file (must be kept regardless of age)
      final refFile = File(p.join(photoDir.path, 't1-100.jpg'));
      await refFile.writeAsString('referenced');
      refFile.setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 60)),
      );

      // 2. Newly copied unreferenced file (modified 2 minutes ago, within 10-minute threshold -> MUST be kept)
      final newUnrefFile = File(p.join(photoDir.path, 't2-200.jpg'));
      await newUnrefFile.writeAsString('new-unref');
      newUnrefFile.setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 2)),
      );

      // 3. Old unreferenced file (modified 20 minutes ago, outside 10-minute threshold -> MUST be deleted)
      final oldUnrefFile = File(p.join(photoDir.path, 't3-300.jpg'));
      await oldUnrefFile.writeAsString('old-unref');
      oldUnrefFile.setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 20)),
      );

      // Run cleanup with only t1 referenced
      await storage.cleanupOrphans(['id_photos/t1-100.jpg']);

      // Assertions
      expect(
        await refFile.exists(),
        isTrue,
        reason: 'Referenced file must not be deleted',
      );
      expect(
        await newUnrefFile.exists(),
        isTrue,
        reason: 'Recent unreferenced file (< 10 mins) must be retained',
      );
      expect(
        await oldUnrefFile.exists(),
        isFalse,
        reason: 'Old unreferenced file (> 10 mins) must be deleted',
      );
    });
  });
}
