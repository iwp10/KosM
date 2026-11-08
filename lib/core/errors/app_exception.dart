/// Base application exception for KosM.
/// Reference: docs/ARCHITECTURE.md section 9.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// Thrown when an operation on a property is rejected because
/// there are still active occupancies in rooms belonging to the property.
class PropertyHasActiveOccupanciesException extends AppException {
  const PropertyHasActiveOccupanciesException([
    super.message = 'Kos tidak dapat dihapus karena masih ada penghuni aktif di kamar kos ini.',
  ]) : super(code: 'PROPERTY_HAS_ACTIVE_OCCUPANCIES');
}

/// Thrown when a property is not found in the database.
class PropertyNotFoundException extends AppException {
  const PropertyNotFoundException([super.message = 'Data kos tidak ditemukan.'])
    : super(code: 'PROPERTY_NOT_FOUND');
}

/// Thrown when tenant validation fails (e.g. invalid name or phone number).
class TenantValidationException extends AppException {
  final String field;

  const TenantValidationException({
    required this.field,
    required String message,
  }) : super(message, code: 'TENANT_VALIDATION_ERROR');
}

/// Thrown when an operation on a tenant is rejected because
/// the tenant still has an active occupancy.
class TenantHasActiveOccupancyException extends AppException {
  const TenantHasActiveOccupancyException([
    super.message = 'Penyewa tidak dapat dihapus karena masih menempati kamar (hunian aktif).',
  ]) : super(code: 'TENANT_HAS_ACTIVE_OCCUPANCY');
}

/// Thrown when a tenant is not found in the database.
class TenantNotFoundException extends AppException {
  const TenantNotFoundException([
    super.message = 'Data penyewa tidak ditemukan.',
  ]) : super(code: 'TENANT_NOT_FOUND');
}

/// Thrown when image picker operation fails.
class IdPhotoPickerException extends AppException {
  const IdPhotoPickerException([
    super.message = 'Gagal mengambil atau memilih foto.',
  ]) : super(code: 'ID_PHOTO_PICKER_ERROR');
}

/// Thrown when camera permission is denied.
class CameraPermissionDeniedException extends AppException {
  const CameraPermissionDeniedException([
    super.message = 'Izin kamera tidak diberikan. Izinkan akses kamera di pengaturan perangkat.',
  ]) : super(code: 'CAMERA_PERMISSION_DENIED');
}

/// Thrown when no camera application or device is available.
class NoCameraAvailableException extends AppException {
  const NoCameraAvailableException([
    super.message =
        'Kamera tidak ditemukan atau tidak tersedia pada perangkat ini.',
  ]) : super(code: 'NO_CAMERA_AVAILABLE');
}

/// Thrown when an image with an unsupported format / extension is uploaded.
class UnsupportedImageFormatException extends AppException {
  const UnsupportedImageFormatException([
    super.message =
        'Format foto tidak didukung. Gunakan format JPG, JPEG, atau PNG.',
  ]) : super(code: 'UNSUPPORTED_IMAGE_FORMAT');
}

/// Thrown when photo storage operations (save/delete/read) fail.
class IdPhotoStorageException extends AppException {
  const IdPhotoStorageException([
    super.message = 'Gagal memproses penyimpanan foto. Pastikan ruang penyimpanan mencukupi.',
  ]) : super(code: 'ID_PHOTO_STORAGE_ERROR');
}
