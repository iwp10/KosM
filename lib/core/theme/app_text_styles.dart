import 'package:flutter/material.dart';

/// Typography design tokens for KosM using Plus Jakarta Sans.
/// Reference: docs/DESIGN.md
abstract class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  /// Display: 28 / 700 - Angka besar di ringkasan
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Title: 20 / 600 - Judul layar
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Heading: 16 / 600 - Judul kartu, nama penyewa
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Body: 14 / 400 - Isi teks
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// BodyStrong: 14 / 600 - Nilai penting
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Label: 12 / 500 - Chip, caption, label input
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Tabular figures helper for currency and number values
  static TextStyle withTabularFigures(TextStyle style) {
    return style.copyWith(
      fontFeatures: [
        ...?style.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }
}
