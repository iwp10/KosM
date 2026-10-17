import 'package:flutter/material.dart';

/// Design tokens for KosM application colors.
/// Reference: docs/DESIGN.md
abstract class AppColors {
  // Light Mode Colors
  static const Color primary = Color(0xFF0F766E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF134E4A);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF2DD4BF);
  static const Color onPrimaryDark = Color(0xFF042F2E);
  static const Color primaryContainerDark = Color(0xFF134E4A);
  static const Color onPrimaryContainerDark = Color(0xFFCCFBF1);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF111A2C);
  static const Color surfaceMutedDark = Color(0xFF18233A);
  static const Color outlineDark = Color(0xFF1F2A44);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Semantic Status Colors (Consistent across themes)
  // Full (Penuh)
  static const Color statusFullText = Color(0xFF2563EB);
  static const Color statusFullBg = Color(0xFFDBEAFE);

  // Partial (Terisi Sebagian)
  static const Color statusPartialText = Color(0xFF0891B2);
  static const Color statusPartialBg = Color(0xFFCFFAFE);

  // Vacant (Kosong)
  static const Color statusVacantText = Color(0xFF16A34A);
  static const Color statusVacantBg = Color(0xFFDCFCE7);

  // Maintenance (Perbaikan)
  static const Color statusMaintenanceText = Color(0xFF64748B);
  static const Color statusMaintenanceBg = Color(0xFFE2E8F0);

  // Paid (Lunas)
  static const Color statusPaidText = Color(0xFF16A34A);
  static const Color statusPaidBg = Color(0xFFDCFCE7);

  // Unpaid (Belum bayar)
  static const Color statusUnpaidText = Color(0xFFD97706);
  static const Color statusUnpaidBg = Color(0xFFFEF3C7);

  // Overdue (Menunggak)
  static const Color statusOverdueText = Color(0xFFDC2626);
  static const Color statusOverdueBg = Color(0xFFFEE2E2);

  // Error / Delete
  static const Color statusErrorText = Color(0xFFDC2626);
  static const Color statusErrorBg = Color(0xFFFEE2E2);

  // Synchronization Status Colors
  static const Color syncSynced = Color(0xFF16A34A);
  static const Color syncWaiting = Color(0xFFD97706);
  static const Color syncOffline = Color(0xFF64748B);
  static const Color syncFailed = Color(0xFFDC2626);
}
