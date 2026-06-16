import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Standard section header for pages.
///
/// Features a title on the left and optional action/trailing widget on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.marginMobile,
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01 * 20,
                ),
          ),
          // ignore: use_null_aware_elements
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}
