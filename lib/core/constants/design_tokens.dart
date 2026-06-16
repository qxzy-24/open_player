import 'package:flutter/material.dart';

/// Global design tokens for the VIOLET theme that are not directly represented in ThemeData.
class DesignTokens {
  DesignTokens._();

  // Spacing & Layout
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double pagePadding = 16.0;

  // Animations & Transitions
  static const Duration transitionFast = Duration(milliseconds: 150);
  static const Duration transitionNormal = Duration(milliseconds: 300);
  static const Duration transitionSlow = Duration(milliseconds: 500);

  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOutCubic;

  // Elevation Blurs
  static const double blurGlassLow = 10.0;
  static const double blurGlassHigh = 24.0;

  // Layout Constraints
  static const double maxMobileWidth = 480.0;
  static const double maxTabletWidth = 768.0;
}
