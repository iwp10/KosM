/// Interface for managing identity photo files in local app private storage.
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.1.
abstract class IdPhotoStorage {
  /// Validates the file extension (.jpg, .jpeg, .png) and copies the temporary file
  /// into the storage directory with versioned naming:
  /// `id_photos/<tenantId>-<epochMillis>.<ext>`.
  ///
  /// Returns the relative path stored in the database.
  /// Throws [UnsupportedImageFormatException] if extension is not supported.
  /// Throws [IdPhotoStorageException] on I/O failure.
  Future<String> savePhoto({
    required String tempPath,
    required String tenantId,
  });

  /// Deletes the photo file corresponding to [relativePath].
  /// Does not throw if the file is already missing.
  Future<void> deletePhoto(String relativePath);

  /// Resolves the absolute file system path for a given [relativePath].
  Future<String> resolveAbsolutePath(String relativePath);

  /// Returns `true` if a file exists at [relativePath].
  Future<bool> fileExists(String relativePath);

  /// Scans the `id_photos` directory and deletes any files whose relative path
  /// is not present in [referencedRelativePaths].
  ///
  /// Files modified within [orphanThreshold] (default 10 minutes) are skipped
  /// to prevent deleting newly copied files that are not yet committed to the database.
  Future<void> cleanupOrphans(
    List<String> referencedRelativePaths, {
    Duration orphanThreshold = const Duration(minutes: 10),
  });

  /// Safely discards/deletes an unpersisted temporary photo file at [tempPath].
  /// Does not throw if the file does not exist or if deletion encounters an error.
  Future<void> discardTemp(String tempPath);
}
