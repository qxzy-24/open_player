import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_art.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  Timer? _debounce;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = query.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    final player = Provider.of<PlayerProvider>(context);

    // Perform local filtering on already loaded data
    final filteredSongs = _query.isEmpty
        ? <dynamic>[]
        : library.allSongs.where((s) {
            return s.title.toLowerCase().contains(_query) ||
                s.artist.toLowerCase().contains(_query);
          }).toList();

    final filteredAlbums = _query.isEmpty
        ? <dynamic>[]
        : library.albums.where((a) {
            return a.album.toLowerCase().contains(_query);
          }).toList();

    final filteredArtists = _query.isEmpty
        ? <dynamic>[]
        : library.artists.where((a) {
            return a.artist.toLowerCase().contains(_query);
          }).toList();

    final bool hasResults = filteredSongs.isNotEmpty ||
        filteredAlbums.isNotEmpty ||
        filteredArtists.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Underlined Search Input with Animated Focus Indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Library',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Songs, albums, artists...',
                        hintStyle: TextStyle(
                          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppTheme.primary),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : const Icon(Icons.search_rounded, color: AppTheme.primary),
                      ),
                    ),
                    // Animated Focus Indicator (under line)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _isFocused
                            ? AppTheme.primaryGradient
                            : LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.1)
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Results
              Expanded(
                child: _query.isEmpty
                    ? _buildEmptyState(context)
                    : !hasResults
                        ? _buildNoResultsState(context)
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 120),
                            children: [
                              // Songs Section
                              if (filteredSongs.isNotEmpty) ...[
                                _buildSectionTitle('Songs'),
                                ...List.generate(filteredSongs.length, (index) {
                                  final song = filteredSongs[index];
                                  final isCurrent = player.currentSong?.id == song.id;
                                  return SongTile(
                                    song: song,
                                    isPlaying: isCurrent,
                                    onTap: () => player.playSong(song, playlist: filteredSongs.cast()),
                                    onFavoriteToggle: () => library.toggleFavorite(song),
                                  );
                                }),
                              ],

                              // Albums Section
                              if (filteredAlbums.isNotEmpty) ...[
                                _buildSectionTitle('Albums'),
                                SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: filteredAlbums.length,
                                    itemBuilder: (context, index) {
                                      final album = filteredAlbums[index];
                                      return _buildAlbumResultCard(context, album, library, player);
                                    },
                                  ),
                                ),
                              ],

                              // Artists Section
                              if (filteredArtists.isNotEmpty) ...[
                                _buildSectionTitle('Artists'),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: filteredArtists.length,
                                    itemBuilder: (context, index) {
                                      final artist = filteredArtists[index];
                                      return _buildArtistResultTile(context, artist, library, player);
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Type to search your local library',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found for "$_query"',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumResultCard(BuildContext context, dynamic album, LibraryProvider library, PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        onTap: () {
          // Drill down into album songs
          final songs = library.getSongsForAlbum(album.id);
          if (songs.isNotEmpty) {
            player.playSong(songs.first, playlist: songs);
          }
        },
        child: SizedBox(
          width: 200,
          child: Row(
            children: [
              AlbumArtWidget(
                songId: album.id,
                size: 64,
                borderRadius: AppTheme.radiusSm,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.album,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      album.artist ?? 'Unknown Artist',
                      style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${album.numOfSongs} songs',
                      style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtistResultTile(BuildContext context, dynamic artist, LibraryProvider library, PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          final songs = library.getSongsForArtist(artist.artist ?? '');
          if (songs.isNotEmpty) {
            player.playSong(songs.first, playlist: songs);
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.artist ?? 'Unknown Artist',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${artist.numberOfTracks} tracks',
                  style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
