import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/theme/app_theme.dart';

/// Displays album artwork with a gradient fallback.
class AlbumArtWidget extends StatelessWidget {
  final int songId;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AlbumArtWidget({
    super.key,
    required this.songId,
    this.size = 56,
    this.borderRadius = AppTheme.radiusMd,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow ? AppTheme.glowShadow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: QueryArtworkWidget(
          id: songId,
          type: ArtworkType.AUDIO,
          artworkWidth: size,
          artworkHeight: size,
          artworkFit: BoxFit.cover,
          artworkQuality: FilterQuality.high,
          quality: 100,
          format: ArtworkFormat.PNG,
          size: (size * 3).toInt().clamp(200, 1000),
          artworkBorder: BorderRadius.zero,
          nullArtworkWidget: _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.6),
            AppTheme.inversePrimary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.7),
        size: size * 0.4,
      ),
    );
  }
}
