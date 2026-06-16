import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'glass_card.dart';

/// Reusable glassmorphism genre chip.
///
/// Used in Library and Search screens for filtering.
class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: GlassCard(
        onTap: onTap,
        borderRadius: AppTheme.radiusFull,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        color: isSelected
            ? AppTheme.primaryContainer.withValues(alpha: 0.3)
            : AppTheme.surfaceContainerHigh.withValues(alpha: 0.2),
        borderOpacity: isSelected ? 0.3 : 0.08,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
