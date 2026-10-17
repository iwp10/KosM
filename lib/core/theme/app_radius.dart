import 'package:flutter/material.dart';

/// Border radius design tokens for KosM.
/// Reference: docs/DESIGN.md
abstract class AppRadius {
  static const double card = 16.0;
  static const double button = 12.0;
  static const double input = 12.0;
  static const double chip = 999.0;
  static const double bottomSheetTop = 24.0;
  static const double snackbar = 12.0;

  // BorderRadius convenience helpers
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius buttonRadius = BorderRadius.circular(button);
  static final BorderRadius inputRadius = BorderRadius.circular(input);
  static final BorderRadius chipRadius = BorderRadius.circular(chip);
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(bottomSheetTop),
  );
  static final BorderRadius snackbarRadius = BorderRadius.circular(snackbar);
}
