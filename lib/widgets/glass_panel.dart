import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A reusable glassmorphism panel widget.
///
/// Provides a frosted glass surface with customizable blur, opacity,
/// border, and corner radius. Used throughout the VIOLET design system
/// for elevated surfaces like cards, nav bars, and status panels.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double blur;
  final double borderOpacity;
  final bool hasShadow;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusLg,
    this.padding,
    this.margin,
    this.color,
    this.blur = 24,
    this.borderOpacity = 0.05,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppTheme.surfaceContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
