import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';
import 'album_art.dart';

/// A song list tile with album art, title, artist, duration, and actions.
class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final int index;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
    this.onFavoriteToggle,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppTheme.primaryColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isPlaying
            ? Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Album Art
                Hero(
                  tag: 'album_art_${song.id}',
                  child: AlbumArtWidget(
                    songId: song.id,
                    size: 48,
                    borderRadius: AppTheme.radiusSm,
                  ),
                ),

                const SizedBox(width: 14),

                // Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              color: isPlaying
                                  ? AppTheme.primaryColor
                                  : AppTheme.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isPlaying) ...[
                            Icon(
                              Icons.equalizer_rounded,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              song.artist,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: isPlaying
                                        ? AppTheme.primaryLight
                                        : AppTheme.textMuted,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Duration
                Text(
                  song.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                ),

                // Favorite Button
                if (onFavoriteToggle != null)
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        song.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(song.isFavorite),
                        size: 20,
                        color: song.isFavorite
                            ? AppTheme.accentWarm
                            : AppTheme.textMuted,
                      ),
                    ),
                    onPressed: onFavoriteToggle,
                    splashRadius: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
