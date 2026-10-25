import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/theme/theme.dart';

void main() {
  group('AppColors', () {
    test('verifies primary light and dark tokens match docs/DESIGN.md', () {
      expect(AppColors.primary, const Color(0xFF0F766E));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.background, const Color(0xFFF8FAFC));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceMuted, const Color(0xFFF1F5F9));

      expect(AppColors.primaryDark, const Color(0xFF2DD4BF));
      expect(AppColors.onPrimaryDark, const Color(0xFF042F2E));
      expect(AppColors.backgroundDark, const Color(0xFF0B1220));
      expect(AppColors.surfaceDark, const Color(0xFF111A2C));
      expect(AppColors.surfaceMutedDark, const Color(0xFF18233A));
    });

    test('verifies semantic status colors match docs/DESIGN.md', () {
      expect(AppColors.statusVacantText, const Color(0xFF16A34A));
      expect(AppColors.statusVacantBg, const Color(0xFFDCFCE7));

      expect(AppColors.statusPartialText, const Color(0xFF0891B2));
      expect(AppColors.statusPartialBg, const Color(0xFFCFFAFE));

      expect(AppColors.statusFullText, const Color(0xFF2563EB));
      expect(AppColors.statusFullBg, const Color(0xFFDBEAFE));

      expect(AppColors.statusMaintenanceText, const Color(0xFF64748B));
      expect(AppColors.statusMaintenanceBg, const Color(0xFFE2E8F0));

      expect(AppColors.statusPaidText, const Color(0xFF16A34A));
      expect(AppColors.statusPaidBg, const Color(0xFFDCFCE7));

      expect(AppColors.statusUnpaidText, const Color(0xFFD97706));
      expect(AppColors.statusUnpaidBg, const Color(0xFFFEF3C7));

      expect(AppColors.statusOverdueText, const Color(0xFFDC2626));
      expect(AppColors.statusOverdueBg, const Color(0xFFFEE2E2));
    });
  });

  group('AppTextStyles', () {
    test('verifies font family and weights', () {
      expect(AppTextStyles.fontFamily, 'PlusJakartaSans');
      expect(AppTextStyles.display.fontSize, 28);
      expect(AppTextStyles.display.fontWeight, FontWeight.w700);

      expect(AppTextStyles.title.fontSize, 20);
      expect(AppTextStyles.title.fontWeight, FontWeight.w600);

      expect(AppTextStyles.heading.fontSize, 16);
      expect(AppTextStyles.heading.fontWeight, FontWeight.w600);

      expect(AppTextStyles.body.fontSize, 14);
      expect(AppTextStyles.body.fontWeight, FontWeight.w400);

      expect(AppTextStyles.bodyStrong.fontSize, 14);
      expect(AppTextStyles.bodyStrong.fontWeight, FontWeight.w600);

      expect(AppTextStyles.label.fontSize, 12);
      expect(AppTextStyles.label.fontWeight, FontWeight.w500);
    });
  });

  group('AppSpacing and AppRadius', () {
    test('verifies spacing scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
      expect(AppSpacing.minTouchTarget, 48.0);
    });

    test('verifies radius tokens', () {
      expect(AppRadius.card, 16.0);
      expect(AppRadius.button, 12.0);
      expect(AppRadius.input, 12.0);
      expect(AppRadius.chip, 999.0);
      expect(AppRadius.bottomSheetTop, 24.0);
    });
  });

  group('AppTheme', () {
    test('verifies light and dark theme configurations', () {
      final light = AppTheme.lightTheme;
      expect(light.useMaterial3, true);
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(light.scaffoldBackgroundColor, AppColors.background);

      final dark = AppTheme.darkTheme;
      expect(dark.useMaterial3, true);
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, AppColors.primaryDark);
      expect(dark.scaffoldBackgroundColor, AppColors.backgroundDark);
    });
  });
}
