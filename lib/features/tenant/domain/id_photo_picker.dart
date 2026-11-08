/// Interface for picking identity photos via device camera or gallery.
/// Reference: docs/ARCHITECTURE.md section 3 & docs/prd.md section 6.1.
abstract class IdPhotoPicker {
  /// Takes a photo using the device camera.
  ///
  /// Returns the temporary file path of the captured image,
  /// or `null` if the user cancelled the action.
  /// Throws [AppException] subclasses on platform or permission failure.
  Future<String?> takePhoto();

  /// Picks an image from the device gallery / photo picker.
  ///
  /// Returns the temporary file path of the chosen image,
  /// or `null` if the user cancelled the action.
  /// Throws [AppException] subclasses on platform or permission failure.
  Future<String?> pickFromGallery();
}
