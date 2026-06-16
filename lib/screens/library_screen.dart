import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/song_model.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/album_art.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_tile.dart';
import '../widgets/add_to_playlist_sheet.dart';

/// Music library screen with tabs for Songs, Albums, Artists, Favorites, and Recent.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Selector<LibraryProvider, int>(
                    selector: (_, library) => library.totalSongs,
                    builder: (context, total, _) {
                      return Text(
                        '$total songs',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              _GlassIconButton(
                icon: Icons.sort_rounded,
                onPressed: () => _showSortOptions(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Tab Bar ──────────────────────────────────────
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(AppTheme.radiusSm),
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            tabs: const [
              Tab(text: 'Songs'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Favorites'),
              Tab(text: 'Recent'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Tab Content ─────────────────────────────────
        Expanded(
          child: Consumer<LibraryProvider>(
            builder: (context, library, _) {
              if (library.isLoading) return _buildLoadingState();
              if (!library.hasPermission) return _buildPermissionState(context);
              if (library.allSongs.isEmpty) return _buildEmptyState();

              return TabBarView(
                controller: _tabController,
                children: [
                  _SongsList(songs: library.allSongs),
                  _AlbumGrid(albums: library.albums),
                  _ArtistList(artists: library.artists),
                  _SongsList(
                    songs: library.favoriteSongs,
                    emptyIcon: Icons.favorite_border_rounded,
                    emptyTitle: 'No favorites yet',
                    emptySubtitle: 'Tap ♥ on any song to add it here',
                  ),
                  _SongsList(
                    songs: library.recentlyPlayed,
                    emptyIcon: Icons.history_rounded,
                    emptyTitle: 'No history yet',
                    emptySubtitle: 'Songs you play will appear here',
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded),
                  title: const Text('Title'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Artist'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.album_rounded),
                  title: const Text('Album'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded),
                  title: const Text('Date Added'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning your music library...',
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_open_rounded, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text('Permission Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Violet needs access to your storage to find and play your music files.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.read<LibraryProvider>().initialize(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text('Grant Permission', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_rounded, size: 64, color: AppTheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No music found', style: TextStyle(color: AppTheme.outline, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Add music files to your device to get started',
            style: TextStyle(color: AppTheme.outline, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Songs List ────────────────────────────────────────────────
class _SongsList extends StatelessWidget {
  final List<Song> songs;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;

  const _SongsList({
    required this.songs,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty && emptyTitle != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon ?? Icons.music_off_rounded, size: 56,
              color: AppTheme.outline.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(emptyTitle!, style: const TextStyle(color: AppTheme.outline, fontSize: 15)),
            if (emptySubtitle != null) ...[
              const SizedBox(height: 6),
              Text(emptySubtitle!, style: TextStyle(color: AppTheme.outline.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ],
        ),
      );
    }

    final player = Provider.of<PlayerProvider>(context);
    final library = Provider.of<LibraryProvider>(context, listen: false);

    return Selector<PlayerProvider, int?>(
      selector: (_, player) => player.currentSong?.id,
      builder: (context, currentSongId, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 160),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final isPlaying = currentSongId == song.id;
            return SongTile(
              song: song,
              index: index,
              isPlaying: isPlaying,
              onTap: () {
                player.playSong(song, playlist: songs, index: index);
                library.addToRecentlyPlayed(song);
              },
              onFavoriteToggle: () => library.toggleFavorite(song),
              onLongPress: () => _showSongOptions(context, song, songs),
            );
          },
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song, List<Song> playlist) {
    final library = context.read<LibraryProvider>();
    final player = context.read<PlayerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      AlbumArtWidget(songId: song.id, size: 48, borderRadius: AppTheme.radiusSm),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(song.artist, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.play_arrow_rounded),
                  title: const Text('Play Now'),
                  onTap: () {
                    player.playSong(song, playlist: playlist, index: playlist.indexOf(song));
                    library.addToRecentlyPlayed(song);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: Icon(
                    song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: song.isFavorite ? AppTheme.accentWarm : null,
                  ),
                  title: Text(song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                  onTap: () {
                    library.toggleFavorite(song);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded),
                  title: const Text('Add to Playlist'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                      ),
                      builder: (context) => AddToPlaylistSheet(song: song),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: const Text('Add to Queue'),
                  onTap: () {
                    player.addToQueue(song);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added "${song.title}" to queue')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Album Grid ────────────────────────────────────────────────
class _AlbumGrid extends StatelessWidget {
  final List<AlbumModel> albums;
  const _AlbumGrid({required this.albums});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 160),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) => AlbumCard(album: albums[index]),
    );
  }
}

// ── Artist List ───────────────────────────────────────────────
class _ArtistList extends StatelessWidget {
  final List<ArtistModel> artists;
  const _ArtistList({required this.artists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 160),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ArtistTile(artist: artist);
      },
    );
  }
}

// ── Glass Icon Button ─────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 20, color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}
