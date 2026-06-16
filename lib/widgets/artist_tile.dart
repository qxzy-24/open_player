import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import 'song_tile.dart';
import 'glass_button.dart';

class ArtistTile extends StatelessWidget {
  final ArtistModel artist;

  const ArtistTile({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.surfaceContainerHigh,
        child: Text(
          artist.artist.isNotEmpty ? artist.artist[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        artist.artist,
        style: const TextStyle(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${artist.numberOfTracks} songs',
        style: const TextStyle(
          color: AppTheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.outlineVariant,
      ),
      onTap: () => _showArtistSongs(context),
    );
  }

  void _showArtistSongs(BuildContext context) {
    final library = context.read<LibraryProvider>();
    final artistSongs = library.getSongsForArtist(artist.artist);
    final player = context.read<PlayerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.surfaceContainerHigh,
                        child: Text(
                          artist.artist.isNotEmpty ? artist.artist[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist.artist,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${artist.numberOfTracks} songs',
                              style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      GlassButton(
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        width: 40,
                        height: 40,
                        borderRadius: AppTheme.radiusFull,
                        onPressed: () {
                          if (artistSongs.isNotEmpty) {
                            player.playSong(artistSongs.first, playlist: artistSongs, index: 0);
                            library.addToRecentlyPlayed(artistSongs.first);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: artistSongs.length,
                    itemBuilder: (context, index) {
                      final song = artistSongs[index];
                      return SongTile(
                        song: song,
                        index: index,
                        isPlaying: player.currentSong?.id == song.id,
                        onTap: () {
                          player.playSong(song, playlist: artistSongs, index: index);
                          library.addToRecentlyPlayed(song);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
