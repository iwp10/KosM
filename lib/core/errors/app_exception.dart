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
