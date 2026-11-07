import '../../../core/errors/errors.dart';

/// Pure validation and normalization functions for Tenant domain.
class TenantValidators {
  /// Validates tenant name: trimmed, not empty, maximum 100 characters.
  /// Throws [TenantValidationException] with field 'name' if invalid.
  static String validateName(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) {
      throw const TenantValidationException(
        field: 'name',
        message: 'Nama penyewa wajib diisi.',
      );
    }
    if (trimmed.length > 100) {
      throw const TenantValidationException(
        field: 'name',
        message: 'Nama penyewa maksimal 100 karakter.',
      );
    }
    return trimmed;
  }

  /// Normalizes and validates Indonesian mobile phone numbers.
  ///
  /// - Strips spaces, dashes, dots, and parentheses.
  /// - Accepts prefixes: '08', '+62', or '62'.
  /// - Normalizes output to '+628...'.
  /// - Requires 9 to 13 digits after '+62' (all digits, first digit after +62 must not be 0 and must be 8).
  /// - Foreign numbers are rejected for now.
  ///
  /// Throws [TenantValidationException] with field 'phone' if invalid.
  static String normalizePhone(String rawPhone) {
    final cleaned = rawPhone.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (cleaned.isEmpty) {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Nomor WhatsApp / HP wajib diisi.',
      );
    }

    String digitsAfterCountryCode;

    if (cleaned.startsWith('+62')) {
      digitsAfterCountryCode = cleaned.substring(3);
    } else if (cleaned.startsWith('62')) {
      digitsAfterCountryCode = cleaned.substring(2);
    } else if (cleaned.startsWith('08')) {
      digitsAfterCountryCode = cleaned.substring(1); // '08...' -> '8...'
    } else {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Nomor HP harus berawalan 08, 62, atau +62.',
      );
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(digitsAfterCountryCode)) {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Nomor HP hanya boleh berisi angka.',
      );
    }

    if (digitsAfterCountryCode.startsWith('0')) {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Digit setelah kode negara tidak boleh 0.',
      );
    }

    if (!digitsAfterCountryCode.startsWith('8')) {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Nomor HP Indonesia harus berawalan 8.',
      );
    }

    if (digitsAfterCountryCode.length < 9 ||
        digitsAfterCountryCode.length > 13) {
      throw const TenantValidationException(
        field: 'phone',
        message: 'Panjang nomor HP harus antara 9 hingga 13 digit setelah kode negara.',
      );
    }

    return '+62$digitsAfterCountryCode';
  }
}
