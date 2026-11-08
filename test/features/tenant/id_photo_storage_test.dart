import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/errors/app_exception.dart';
import 'package:kosm/features/tenant/data/id_photo_storage_impl.dart';

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
        final sampleSource = File('${tempDir.path}/source.jpg');
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
        final sampleSource = File('${tempDir.path}/source.$ext');
        await sampleSource.writeAsString('bytes-$ext');

        final relPath = await storage.savePhoto(
          tempPath: sampleSource.path,
          tenantId: 't-$ext',
        );
        expect(relPath.endsWith('.${ext.toLowerCase()}'), isTrue);
      }
    });

    test('savePhoto throws UnsupportedImageFormatException for unapproved extensions', () async {
      for (final ext in ['pdf', 'gif', 'webp', 'bmp', 'txt']) {
        final sampleSource = File('${tempDir.path}/doc.$ext');
        await sampleSource.writeAsString('content');

        expect(
          () => storage.savePhoto(
            tempPath: sampleSource.path,
            tenantId: 't-invalid',
          ),
          throwsA(isA<UnsupportedImageFormatException>()),
        );
      }
    });

    test('savePhoto throws IdPhotoStorageException when source file does not exist', () async {
      expect(
        () => storage.savePhoto(
          tempPath: '${tempDir.path}/missing.jpg',
          tenantId: 't-missing',
        ),
        throwsA(isA<IdPhotoStorageException>()),
      );
    });

    test(
      'deletePhoto removes existing file and ignores missing file silently',
      () async {
        final sampleSource = File('${tempDir.path}/to_delete.jpg');
        await sampleSource.writeAsString('to delete');

        final relPath = await storage.savePhoto(
          tempPath: sampleSource.path,
          tenantId: 't-del',
        );
        expect(await storage.fileExists(relPath), isTrue);

        await storage.deletePhoto(relPath);
        expect(await storage.fileExists(relPath), isFalse);

        // Deleting again does not throw
        await expectLater(storage.deletePhoto(relPath), completes);
      },
    );

    test('cleanupOrphans keeps newly modified unreferenced files and deletes old unreferenced files', () async {
      final photoDir = Directory('${tempDir.path}/id_photos');
      await photoDir.create(recursive: true);

      // 1. Referenced file (must be kept regardless of age)
      final refFile = File('${photoDir.path}/t1-100.jpg');
      await refFile.writeAsString('referenced');
      refFile.setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 60)),
      );

      // 2. Newly copied unreferenced file (modified 2 minutes ago, within 10-minute threshold -> MUST be kept)
      final newUnrefFile = File('${photoDir.path}/t2-200.jpg');
      await newUnrefFile.writeAsString('new-unref');
      newUnrefFile.setLastModifiedSync(
        DateTime.now().subtract(const Duration(minutes: 2)),
      );

      // 3. Old unreferenced file (modified 20 minutes ago, outside 10-minute threshold -> MUST be deleted)
      final oldUnrefFile = File('${photoDir.path}/t3-300.jpg');
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
