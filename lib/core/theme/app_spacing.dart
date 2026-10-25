import 'package:flutter/material.dart';

/// Spacing design tokens for KosM using 4pt grid system.
/// Reference: docs/DESIGN.md
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Screen layout tokens
  static const double screenHorizontal = 16.0;
  static const double cardGap = 12.0;
  static const double minTouchTarget = 48.0;

  // Edge insets convenience helpers
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);
  static const EdgeInsets sheetPadding = EdgeInsets.all(xl);
}
