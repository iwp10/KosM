import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _noteError;

  bool _isLoadingInitial = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.tenantId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingTenant();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingTenant() async {
    setState(() => _isLoadingInitial = true);
    final repo = ref.read(tenantRepositoryProvider);
    final tenant = await repo.getById(widget.tenantId!);

    if (!mounted) return;

    if (tenant != null) {
      _nameController.text = tenant.name;
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

      if (!_isEditMode) {
        // Create new tenant
        final newTenant = Tenant(
          id: const Uuid().v4(),
          name: validatedName!,
          phone: normalizedPhone!,
          note: rawNote.isEmpty ? null : rawNote,
          createdAt: now,
          updatedAt: now,
        );
        await repo.create(newTenant);
      } else {
        // Update existing tenant
        final existing = await repo.getById(widget.tenantId!);
        if (existing == null) {
          throw const TenantNotFoundException(AppStrings.tenantNotFoundTitle);
        }
        final updatedTenant = existing.copyWith(
          name: validatedName!,
          phone: normalizedPhone!,
          note: rawNote.isEmpty ? null : rawNote,
          updatedAt: now,
        );
        await repo.update(updatedTenant);
      }

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
}
