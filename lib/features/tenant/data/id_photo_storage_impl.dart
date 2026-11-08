import 'dart:io';

import 'package:flutter/foundation.dart';
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

  String _getExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return '';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  String _getBasename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final slashIndex = normalized.lastIndexOf('/');
    if (slashIndex == -1) return path;
    return normalized.substring(slashIndex + 1);
  }

  String _join(String dir, String sub) {
    if (dir.endsWith(Platform.pathSeparator) || dir.endsWith('/')) {
      return '$dir$sub';
    }
    return '$dir${Platform.pathSeparator}$sub';
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

    final ext = _getExtension(tempPath);
    if (!_allowedExtensions.contains(ext)) {
      throw const UnsupportedImageFormatException();
    }

    try {
      final baseDir = await _baseDirResolver();
      final photoDir = Directory(_join(baseDir.path, 'id_photos'));
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$tenantId-$timestamp.$ext';
      final destinationPath = _join(photoDir.path, fileName);

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
    final normalizedRel = relativePath.replaceAll('\\', '/');
    final parts = normalizedRel.split('/').where((s) => s.isNotEmpty).toList();
    var current = baseDir.path;
    for (final part in parts) {
      current = _join(current, part);
    }
    return current;
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
      final photoDir = Directory(_join(baseDir.path, 'id_photos'));
      if (!await photoDir.exists()) return;

      final normalizedReferenced = referencedRelativePaths
          .map((r) => r.replaceAll('\\', '/'))
          .toSet();

      final now = DateTime.now();
      final entities = photoDir.listSync();

      for (final entity in entities) {
        if (entity is File) {
          final filename = _getBasename(entity.path);
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
      debugPrint('Gagal menjalankan pembersihan foto yatim: $e');
    }
  }
}
