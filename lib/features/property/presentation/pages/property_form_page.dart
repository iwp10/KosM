import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/property.dart';
import '../providers/property_providers.dart';

/// Form screen to create a new property or edit an existing one.
/// Accessible via `/more/properties/new` or `/more/properties/:id/edit`.
/// Reference: docs/DESIGN.md & docs/design/profil-kos.png.
class PropertyFormPage extends ConsumerStatefulWidget {
  final String? propertyId;

  const PropertyFormPage({super.key, this.propertyId});

  @override
  ConsumerState<PropertyFormPage> createState() => _PropertyFormPageState();
}

class _PropertyFormPageState extends ConsumerState<PropertyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;

  bool _isLoading = false;
  bool _isFetchingExisting = false;
  Property? _existingProperty;
  String? _nameError;

  bool get _isEditMode => widget.propertyId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();

    if (_isEditMode) {
      _loadExistingProperty();
    }
  }

  Future<void> _loadExistingProperty() async {
    setState(() => _isFetchingExisting = true);
    final repo = ref.read(propertyRepositoryProvider);
    final prop = await repo.getById(widget.propertyId!);
    if (mounted) {
      if (prop != null) {
        _existingProperty = prop;
        _nameController.text = prop.name;
        _addressController.text = prop.address;
        _contactController.text = prop.contact;
      }
      setState(() => _isFetchingExisting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
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
      final repo = ref.read(propertyRepositoryProvider);
      final now = DateTime.now().toUtc();

      if (_isEditMode && _existingProperty != null) {
        final updated = _existingProperty!.copyWith(
          name: name,
          address: _addressController.text.trim(),
          contact: _contactController.text.trim(),
          updatedAt: now,
        );
        await repo.update(updated);
        if (mounted) {
          AppSnackbar.show(
            context,
            message: AppStrings.propertyUpdatedSuccess,
            type: SnackbarType.success,
          );
          context.pop();
        }
      } else {
        final newId = generateUuid();
        final newProperty = Property(
          id: newId,
          name: name,
          address: _addressController.text.trim(),
          contact: _contactController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.create(newProperty);
        if (mounted) {
          AppSnackbar.show(
            context,
            message: AppStrings.propertyCreatedSuccess,
            type: SnackbarType.success,
          );
          context.pop();
        }
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Gagal menyimpan data kos. Coba lagi.',
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
    if (_isFetchingExisting) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? AppStrings.editProperty : AppStrings.addProperty,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.editProperty : AppStrings.addProperty,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                label: AppStrings.save,
                isLoading: _isLoading,
                onPressed: _saveProperty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
