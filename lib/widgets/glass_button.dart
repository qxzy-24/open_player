import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'glass_panel.dart';

/// A premium glassmorphism button.
///
/// Supports icon-only, label-only, or icon-and-label layouts.
/// Provides a frosted backdrop and subtle white border.
class GlassButton extends StatelessWidget {
  final Widget? icon;
  final Widget? label;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final double borderOpacity;
  final bool isGlow;

  const GlassButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.borderRadius = AppTheme.radiusFull,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.borderOpacity = 0.1,
    this.isGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (icon != null && label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppTheme.spacingSm),
          label!,
        ],
      );
    } else if (icon != null) {
      content = icon!;
    } else if (label != null) {
      content = label!;
    } else {
      content = const SizedBox.shrink();
    }

    final double resolvedWidth = width ?? (icon != null && label == null ? 48.0 : double.nan);
    final double resolvedHeight = height ?? 48.0;

    return Container(
      width: resolvedWidth.isNaN ? null : resolvedWidth,
      height: resolvedHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isGlow ? AppTheme.glowShadow : null,
      ),
      child: GlassPanel(
        borderRadius: borderRadius,
        padding: EdgeInsets.zero,
        color: color ?? Colors.white.withValues(alpha: 0.05),
        borderOpacity: borderOpacity,
        hasShadow: false,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppTheme.primary.withValues(alpha: 0.15),
          highlightColor: AppTheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Center(
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
