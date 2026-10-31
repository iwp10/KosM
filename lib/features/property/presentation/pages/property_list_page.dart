import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/strings/strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/property_providers.dart';
import '../widgets/property_item_card.dart';

/// Screen displaying the list of all registered boarding house properties.
/// Accessible via `/more/properties`.
/// Reference: docs/DESIGN.md & docs/design/kelola-kos.png.
class PropertyListPage extends ConsumerWidget {
  const PropertyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final activePropertyAsync = ref.watch(activePropertyProvider);
    final activePropertyId = activePropertyAsync.value ?? 'all';
    final kosM = context.kosMColors;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.manageProperties)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/more/properties/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addProperty),
      ),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.statusOverdueText,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Terjadi kesalahan memuat data kos.',
                  style: AppTextStyles.heading.copyWith(
                    color: kosM.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: AppStrings.retry,
                  onPressed: () => ref.invalidate(propertiesStreamProvider),
                ),
              ],
            ),
          ),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: EmptyState(
                  icon: Icons.apartment_rounded,
                  title: AppStrings.emptyPropertiesTitle,
                  description: AppStrings.emptyPropertiesDesc,
                  actionLabel: AppStrings.addProperty,
                  onAction: () => context.push('/more/properties/new'),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              top: AppSpacing.md,
              bottom: AppSpacing.xxl * 2, // Space for FAB
            ),
            itemCount: properties.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final property = properties[index];
              final isActive = property.id == activePropertyId;

              return PropertyItemCard(
                property: property,
                isActive: isActive,
                onEdit: () =>
                    context.push('/more/properties/${property.id}/edit'),
                onDelete: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: AppStrings.deletePropertyTitle,
                    message: AppStrings.deletePropertyConfirmMessage,
                    confirmLabel: AppStrings.delete,
                    isDestructive: true,
                  );

                  if (confirmed == true && context.mounted) {
                    try {
                      await ref
                          .read(activePropertyProvider.notifier)
                          .deleteProperty(property.id);

                      if (context.mounted) {
                        AppSnackbar.show(
                          context,
                          message: AppStrings.propertyDeletedSuccess,
                          type: SnackbarType.success,
                        );
                      }
                    } on AppException catch (e) {
                      if (context.mounted) {
                        AppSnackbar.show(
                          context,
                          message: e.message,
                          type: SnackbarType.error,
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        AppSnackbar.show(
                          context,
                          message: 'Gagal menghapus kos. Coba lagi.',
                          type: SnackbarType.error,
                        );
                      }
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
