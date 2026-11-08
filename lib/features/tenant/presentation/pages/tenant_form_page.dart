import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/id_photo_storage.dart';
import '../../domain/tenant.dart';
import '../../domain/tenant_validators.dart';
import '../providers/tenant_providers.dart';

/// Form page for creating a new tenant or editing an existing tenant.
/// Reference: docs/DESIGN.md & docs/design/tenant-form.png.
class TenantFormPage extends ConsumerStatefulWidget {
  final String? tenantId;

  const TenantFormPage({super.key, this.tenantId});

  @override
  ConsumerState<TenantFormPage> createState() => _TenantFormPageState();
}

class _TenantFormPageState extends ConsumerState<TenantFormPage> {
  late final String _tenantId;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _noteError;

  bool _isLoadingInitial = false;
  bool _isSaving = false;
  bool _hasSaved = false;

  DateTime? _existingCreatedAt;
  String? _existingPhotoPath;
  String? _existingPhotoAbsPath;
  String? _newPhotoTempPath;
  bool _removePhoto = false;
  late final IdPhotoStorage _photoStorage;

  bool get _isEditMode => widget.tenantId != null;

  @override
  void initState() {
    super.initState();
    _tenantId = widget.tenantId ?? generateUuid();
    _photoStorage = ref.read(idPhotoStorageProvider);
    if (_isEditMode) {
      _loadExistingTenant();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    if (!_hasSaved && _newPhotoTempPath != null) {
      _photoStorage.discardTemp(_newPhotoTempPath!);
    }
    super.dispose();
  }

  Future<void> _loadExistingTenant() async {
    setState(() => _isLoadingInitial = true);
    final repo = ref.read(tenantRepositoryProvider);
    final tenant = await repo.getById(widget.tenantId!);

    if (!mounted) return;

    if (tenant != null) {
      _nameController.text = tenant.name;
      _existingCreatedAt = tenant.createdAt;
      // In edit mode: strip '+62' prefix so user edits remaining digits
      final rawPhone = tenant.phone;
      if (rawPhone.startsWith('+62')) {
        _phoneController.text = rawPhone.substring(3);
      } else if (rawPhone.startsWith('62')) {
        _phoneController.text = rawPhone.substring(2);
      } else if (rawPhone.startsWith('08')) {
        _phoneController.text = rawPhone.substring(1);
      } else {
        _phoneController.text = rawPhone;
      }

      _noteController.text = tenant.note ?? '';

      if (tenant.idPhotoPath != null) {
        _existingPhotoPath = tenant.idPhotoPath;
        final absPath = await _photoStorage.resolveAbsolutePath(
          tenant.idPhotoPath!,
        );
        _existingPhotoAbsPath = absPath;
      }

      setState(() => _isLoadingInitial = false);
    } else {
      setState(() => _isLoadingInitial = false);
      AppSnackbar.show(
        context,
        message: AppStrings.tenantNotFoundTitle,
        type: SnackbarType.error,
      );
      context.pop();
    }
  }

  Future<void> _pickPhoto(bool fromCamera) async {
    final picker = ref.read(idPhotoPickerProvider);
    try {
      final path = fromCamera
          ? await picker.takePhoto()
          : await picker.pickFromGallery();
      if (path != null && mounted) {
        if (_newPhotoTempPath != null && _newPhotoTempPath != path) {
          _photoStorage.discardTemp(_newPhotoTempPath!);
        }
        setState(() {
          _newPhotoTempPath = path;
          _removePhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: e is AppException ? e.message : 'Gagal memilih foto.',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _deletePhoto() {
    if (_newPhotoTempPath != null) {
      _photoStorage.discardTemp(_newPhotoTempPath!);
    }
    setState(() {
      _newPhotoTempPath = null;
      _removePhoto = true;
    });
  }

  void _showPickSourceModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(AppStrings.takePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(AppStrings.chooseFromGallery),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _nameError = null;
      _phoneError = null;
      _noteError = null;
    });

    final rawName = _nameController.text;
    final rawPhone = _phoneController.text.trim();
    final rawNote = _noteController.text.trim();

    // 1. Inline name validation
    String? validatedName;
    try {
      validatedName = TenantValidators.validateName(rawName);
    } on TenantValidationException catch (e) {
      _nameError = e.message;
    }

    // 2. Inline phone validation & normalization
    String? normalizedPhone;
    try {
      final phoneToValidate =
          (rawPhone.startsWith('+62') ||
              rawPhone.startsWith('62') ||
              rawPhone.startsWith('08'))
          ? rawPhone
          : '+62$rawPhone';
      normalizedPhone = TenantValidators.normalizePhone(phoneToValidate);
    } on TenantValidationException catch (e) {
      _phoneError = e.message;
    }

    // 3. Inline note length validation
    if (rawNote.length > 300) {
      _noteError = AppStrings.noteMaxLengthExceeded;
    }

    if (_nameError != null || _phoneError != null || _noteError != null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      final repo = ref.read(tenantRepositoryProvider);
      final now = DateTime.now().toUtc();

      final tenant = Tenant(
        id: _tenantId,
        name: validatedName!,
        phone: normalizedPhone!,
        note: rawNote.isEmpty ? null : rawNote,
        idPhotoPath: _existingPhotoPath,
        createdAt: _existingCreatedAt ?? now,
        updatedAt: now,
      );

      await repo.saveTenant(
        tenant,
        newPhotoTempPath: _newPhotoTempPath,
        removePhoto: _removePhoto,
      );

      _hasSaved = true;

      if (mounted) {
        AppSnackbar.show(
          context,
          message: AppStrings.tenantSavedSuccess,
          type: SnackbarType.success,
        );
        context.pop();
      }
    } on TenantValidationException catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          if (e.field == 'name') {
            _nameError = e.message;
          } else if (e.field == 'phone') {
            _phoneError = e.message;
          } else {
            AppSnackbar.show(
              context,
              message: e.message,
              type: SnackbarType.error,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          AppSnackbar.show(
            context,
            message: e.toString(),
            type: SnackbarType.error,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kosM = context.kosMColors;

    if (_isLoadingInitial) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode
                ? AppStrings.editTenantTitle
                : AppStrings.addTenantTitle,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String? previewPath =
        _newPhotoTempPath ??
        (!_removePhoto && _existingPhotoAbsPath != null
            ? _existingPhotoAbsPath
            : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.editTenantTitle : AppStrings.addTenantTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: AppStrings.tenantNameLabel,
                hintText: AppStrings.tenantNameHint,
                controller: _nameController,
                errorText: _nameError,
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.tenantPhoneLabel,
                hintText: AppStrings.tenantPhoneHint,
                prefixText: '+62 ',
                controller: _phoneController,
                errorText: _phoneError,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.tenantNoteLabel,
                hintText: AppStrings.tenantNoteHint,
                controller: _noteController,
                errorText: _noteError,
                maxLines: 3,
                maxLength: 300,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                onChanged: (_) {
                  if (_noteError != null) setState(() => _noteError = null);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ID Photo Section (KTP / Identitas)
              AppCard(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.idPhotoSectionTitle,
                      style: AppTextStyles.label.copyWith(
                        color: kosM.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.idPhotoHint,
                      style: AppTextStyles.label.copyWith(
                        color: kosM.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (previewPath != null) ...[
                      ClipRRect(
                        borderRadius: AppRadius.buttonRadius,
                        child: Image.file(
                          File(previewPath),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          errorBuilder: (_, _, _) => Container(
                            height: 140,
                            color: kosM.surfaceMuted,
                            alignment: Alignment.center,
                            child: Text(
                              AppStrings.idPhotoNotFound,
                              style: AppTextStyles.label.copyWith(
                                color: kosM.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPhotoButton(
                            label: AppStrings.changePhoto,
                            icon: Icons.edit_outlined,
                            onPressed: _isSaving ? null : _showPickSourceModal,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPhotoButton(
                            label: AppStrings.deletePhoto,
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.statusOverdueText,
                            textColor: AppColors.statusOverdueText,
                            onPressed: _isSaving ? null : _deletePhoto,
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPhotoButton(
                            label: AppStrings.takePhoto,
                            icon: Icons.camera_alt_outlined,
                            onPressed: _isSaving
                                ? null
                                : () => _pickPhoto(true),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPhotoButton(
                            label: AppStrings.chooseFromGallery,
                            icon: Icons.photo_library_outlined,
                            onPressed: _isSaving
                                ? null
                                : () => _pickPhoto(false),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: AppStrings.saveTenant,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final borderColor = color ?? theme.colorScheme.primary;
    final fgColor = textColor ?? theme.colorScheme.primary;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodyStrong.copyWith(color: fgColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
