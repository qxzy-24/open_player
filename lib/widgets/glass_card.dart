import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'glass_panel.dart';

/// An interactive glassmorphism card widget.
///
/// Wraps GlassPanel in an InkWell to handle user taps while maintaining
/// premium visual aesthetics (ink splash is masked by the card's round corners).
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double blur;
  final double borderOpacity;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppTheme.radiusMd,
    this.padding = const EdgeInsets.all(AppTheme.spacingMd),
    this.margin,
    this.color,
    this.blur = 10,
    this.borderOpacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return GlassPanel(
        borderRadius: borderRadius,
        padding: padding,
        margin: margin,
        color: color ?? AppTheme.surfaceContainerHigh.withValues(alpha: 0.3),
        blur: blur,
        borderOpacity: borderOpacity,
        hasShadow: false,
        child: child,
      );
    }

    return GlassPanel(
      borderRadius: borderRadius,
      padding: EdgeInsets.zero,
      margin: margin,
      color: color ?? AppTheme.surfaceContainerHigh.withValues(alpha: 0.3),
      blur: blur,
      borderOpacity: borderOpacity,
      hasShadow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        highlightColor: AppTheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
