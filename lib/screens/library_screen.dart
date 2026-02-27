import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

/// Music library screen with tabs for Songs, Albums, Artists, Favorites.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        return Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (!_isSearching) ...[
                    Text(
                      'Library',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                    ),
                    const Spacer(),
                    _buildStatChip(
                      Icons.music_note_rounded,
                      '${library.totalSongs}',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      color: AppTheme.textSecondary,
                      onPressed: () => setState(() => _isSearching = true),
                    ),
                  ] else ...[
                    Expanded(
                      child: _buildSearchBar(library),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.textSecondary,
                      onPressed: () {
                        setState(() => _isSearching = false);
                        _searchController.clear();
                        library.clearSearch();
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tab Bar ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                splashBorderRadius:
                    BorderRadius.circular(AppTheme.radiusMd),
                tabs: const [
                  Tab(text: 'Songs'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Favs'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Tab Content ─────────────────────────────────
            Expanded(
              child: library.isLoading
                  ? _buildLoadingState()
                  : !library.hasPermission
                      ? _buildPermissionState(library)
                      : library.songs.isEmpty
                          ? _buildEmptyState()
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSongsList(library),
                                _buildAlbumGrid(library),
                                _buildArtistList(library),
                                _buildFavoritesList(library),
                              ],
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(LibraryProvider library) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: library.search,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
          hintStyle: TextStyle(
            color: AppTheme.textMuted.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(LibraryProvider library) {
    final songs = library.songs;
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        return RefreshIndicator(
          onRefresh: library.loadLibrary,
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 100),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                index: index,
                isPlaying: player.currentSong?.id == song.id,
                onTap: () {
                  player.playSong(song, playlist: songs, index: index);
                },
                onFavoriteToggle: () => library.toggleFavorite(song),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAlbumGrid(LibraryProvider library) {
    final albums = library.albums;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildAlbumCard(album, library);
      },
    );
  }

  Widget _buildAlbumCard(dynamic album, LibraryProvider library) {
    return GestureDetector(
      onTap: () {
        _showAlbumSongs(context, album, library);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusMd),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.4),
                        AppTheme.primaryDark.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.album_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.album,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.numOfSongs} songs',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumSongs(
      BuildContext context, dynamic album, LibraryProvider library) {
    final albumSongs = library.getSongsForAlbum(album.id);
    final player = Provider.of<PlayerProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
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
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    album.album,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: albumSongs.length,
                    itemBuilder: (context, index) {
                      final song = albumSongs[index];
                      return SongTile(
                        song: song,
                        index: index,
                        isPlaying: player.currentSong?.id == song.id,
                        onTap: () {
                          player.playSong(song,
                              playlist: albumSongs, index: index);
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

  Widget _buildArtistList(LibraryProvider library) {
    final artists = library.artists;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.bgElevated,
            child: Text(
              artist.artist.isNotEmpty ? artist.artist[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            artist.artist,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${artist.numberOfTracks} songs',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
          ),
          onTap: () {
            _showArtistSongs(context, artist, library);
          },
        );
      },
    );
  }

  void _showArtistSongs(
      BuildContext context, dynamic artist, LibraryProvider library) {
    final artistSongs = library.getSongsForArtist(artist.artist);
    final player = Provider.of<PlayerProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
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
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    artist.artist,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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
                          player.playSong(song,
                              playlist: artistSongs, index: index);
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

  Widget _buildFavoritesList(LibraryProvider library) {
    final favorites = library.favoriteSongs;
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap ♥ on any song to add it here',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final song = favorites[index];
            return SongTile(
              song: song,
              index: index,
              isPlaying: player.currentSong?.id == song.id,
              onTap: () {
                player.playSong(song, playlist: favorites, index: index);
              },
              onFavoriteToggle: () => library.toggleFavorite(song),
            );
          },
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
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning your music library...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionState(LibraryProvider library) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Permission Required',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Open Player needs access to your storage to find and play your music files.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => library.initialize(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
          Icon(
            Icons.library_music_rounded,
            size: 64,
            color: AppTheme.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No music found',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add music files to your device to get started',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
