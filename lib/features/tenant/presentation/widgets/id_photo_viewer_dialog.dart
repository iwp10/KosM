import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/theme.dart';

/// Full-screen dialog with pan and zoom capabilities for viewing identity photos.
/// Reference: docs/DESIGN.md & docs/prd.md section 6.1.
class IdPhotoViewerDialog extends StatelessWidget {
  final String imagePath;
  final String title;

  const IdPhotoViewerDialog({
    super.key,
    required this.imagePath,
    this.title = AppStrings.idPhotoDetailTitle,
  });

  /// Convenient helper to display the dialog.
  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    String title = AppStrings.idPhotoDetailTitle,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => IdPhotoViewerDialog(imagePath: imagePath, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            // Interactive viewer for pinch-to-zoom and pan
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppStrings.idPhotoNotFound,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Header bar with close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm,
                ),
                color: Colors.black45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: AppStrings.close,
                      onPressed: () => Navigator.of(context).pop(),
                      constraints: const BoxConstraints(
                        minWidth: AppSpacing.minTouchTarget,
                        minHeight: AppSpacing.minTouchTarget,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
