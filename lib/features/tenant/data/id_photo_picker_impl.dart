import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/id_photo_picker.dart';

/// Implementation of [IdPhotoPicker] using Flutter's `image_picker` plugin.
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.1.
class IdPhotoPickerImpl implements IdPhotoPicker {
  final ImagePicker _picker;

  IdPhotoPickerImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<String?> takePhoto() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      return xFile?.path;
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        throw const CameraPermissionDeniedException();
      }
      if (e.code == 'no_available_camera') {
        throw const NoCameraAvailableException();
      }
      throw IdPhotoPickerException(
        e.message ?? 'Gagal mengambil foto dari kamera.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw IdPhotoPickerException('Gagal mengambil foto dari kamera.');
    }
  }

  @override
  Future<String?> pickFromGallery() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      return xFile?.path;
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        throw const CameraPermissionDeniedException(
          'Izin galeri tidak diberikan. Izinkan akses foto di pengaturan perangkat.',
        );
      }
      throw IdPhotoPickerException(
        e.message ?? 'Gagal memilih foto dari galeri.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw IdPhotoPickerException('Gagal memilih foto dari galeri.');
    }
  }
}
