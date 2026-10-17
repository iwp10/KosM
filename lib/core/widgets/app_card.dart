import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// KosM standard card component.
/// Specification: surface, radius 16, border outline 1dp, padding 16.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? borderSide;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.color,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kosM = context.kosMColors;

    final cardBorder =
        borderSide ?? BorderSide(color: kosM.outline, width: 1.0);
    final cardColor =
        color ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null) {
      return Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: cardBorder,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.cardRadius,
        border: Border.fromBorderSide(cardBorder),
      ),
      child: content,
    );
  }
}
