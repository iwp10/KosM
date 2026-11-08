import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/id_photo_storage.dart';

/// Implementation of [IdPhotoStorage] for managing local identity photos.
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.1.
class IdPhotoStorageImpl implements IdPhotoStorage {
  final Future<Directory> Function() _baseDirResolver;

  IdPhotoStorageImpl({Future<Directory> Function()? baseDirResolver})
    : _baseDirResolver = baseDirResolver ?? getApplicationDocumentsDirectory;

  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png'};

  String _cleanExtension(String path) {
    final ext = p.extension(path);
    if (ext.startsWith('.')) {
      return ext.substring(1).toLowerCase();
    }
    return ext.toLowerCase();
  }

  @override
  Future<String> savePhoto({
    required String tempPath,
    required String tenantId,
  }) async {
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      throw const IdPhotoStorageException('File foto sumber tidak ditemukan.');
    }

    final ext = _cleanExtension(tempPath);
    if (!_allowedExtensions.contains(ext)) {
      throw const UnsupportedImageFormatException();
    }

    try {
      final baseDir = await _baseDirResolver();
      final photoDir = Directory(p.join(baseDir.path, 'id_photos'));
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$tenantId-$timestamp.$ext';
      final destinationPath = p.join(photoDir.path, fileName);

      await tempFile.copy(destinationPath);
      return 'id_photos/$fileName';
    } catch (e) {
      if (e is AppException) rethrow;
      throw const IdPhotoStorageException();
    }
  }

  @override
  Future<void> deletePhoto(String relativePath) async {
    try {
      final absPath = await resolveAbsolutePath(relativePath);
      final file = File(absPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Deletion is best-effort; orphaned files will be cleaned up by cleanupOrphans.
    }
  }

  @override
  Future<String> resolveAbsolutePath(String relativePath) async {
    final baseDir = await _baseDirResolver();
    // Normalize relative path segments
    final normalized = p.normalize(relativePath);
    return p.join(baseDir.path, normalized);
  }

  @override
  Future<bool> fileExists(String relativePath) async {
    try {
      final absPath = await resolveAbsolutePath(relativePath);
      return await File(absPath).exists();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cleanupOrphans(
    List<String> referencedRelativePaths, {
    Duration orphanThreshold = const Duration(minutes: 10),
  }) async {
    try {
      final baseDir = await _baseDirResolver();
      final photoDir = Directory(p.join(baseDir.path, 'id_photos'));
      if (!await photoDir.exists()) return;

      final normalizedReferenced = referencedRelativePaths
          .map((r) => p.normalize(r).replaceAll('\\', '/'))
          .toSet();

      final now = DateTime.now();
      final entities = photoDir.listSync();

      for (final entity in entities) {
        if (entity is File) {
          final filename = p.basename(entity.path);
          final relPath = 'id_photos/$filename';

          if (!normalizedReferenced.contains(relPath)) {
            try {
              final lastModified = entity.lastModifiedSync();
              if (now.difference(lastModified) > orphanThreshold) {
                entity.deleteSync();
              }
            } catch (e) {
              debugPrint('Gagal membersihkan file foto yatim: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error saat menjalankan cleanupOrphans: $e');
    }
  }

  @override
  Future<void> discardTemp(String tempPath) async {
    try {
      final file = File(tempPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup
    }
  }
}
