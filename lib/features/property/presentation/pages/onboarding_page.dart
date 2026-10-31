import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/property.dart';
import '../providers/property_providers.dart';

/// Onboarding screen presented when no properties exist in the database.
/// Prompts the user to register their first property before proceeding.
/// Reference: docs/prd.md section 6.9 & docs/DESIGN.md.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;

  bool _isLoading = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitFirstProperty() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = AppStrings.propertyNameRequired);
      return;
    }
    setState(() {
      _nameError = null;
      _isLoading = true;
    });

    try {
      final now = DateTime.now().toUtc();
      final newId = generateUuid();
      final newProperty = Property(
        id: newId,
        name: name,
        address: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final repo = ref.read(propertyRepositoryProvider);
      await repo.create(newProperty);

      // Set as active property
      await ref.read(activePropertyProvider.notifier).setActiveProperty(newId);

      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Kos pertama berhasil didaftarkan! Selamat datang di KosM.',
          type: SnackbarType.success,
        );
        context.go('/home');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Terjadi kesalahan saat menyimpan. Coba lagi.',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadius.cardRadius,
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppStrings.onboardingTitle,
                  style: AppTextStyles.display.copyWith(
                    color: kosM.textPrimary,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.onboardingSubtitle,
                  style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Properti Pertama Anda',
                        style: AppTextStyles.heading.copyWith(
                          color: kosM.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: AppStrings.propertyNameLabel,
                        hintText: AppStrings.propertyNameHint,
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.apartment_rounded),
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: AppStrings.propertyAddressLabel,
                        hintText: AppStrings.propertyAddressHint,
                        controller: _addressController,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: AppStrings.propertyContactLabel,
                        hintText: AppStrings.propertyContactHint,
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: AppStrings.onboardingSaveButton,
                  isLoading: _isLoading,
                  onPressed: _submitFirstProperty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
