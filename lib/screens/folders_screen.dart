import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../models/song_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_header.dart';
import '../widgets/song_tile.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  String? _selectedFolder;

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    final player = Provider.of<PlayerProvider>(context);

    if (_selectedFolder != null) {
      final songs = library.getSongsForFolder(_selectedFolder!);
      return _buildFolderSongsView(context, _selectedFolder!, songs, player, library);
    }

    final folderPaths = library.folders;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Folder Browser'),

              // Storage Status Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                child: _buildStorageStatusCard(),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Folder List
              Expanded(
                child: folderPaths.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        itemCount: folderPaths.length,
                        itemBuilder: (context, index) {
                          final path = folderPaths[index];
                          final songsInFolder = library.getSongsForFolder(path);
                          final folderName = path.split('/').last;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              onTap: () {
                                setState(() {
                                  _selectedFolder = path;
                                });
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    ),
                                    child: const Icon(
                                      Icons.folder_rounded,
                                      color: AppTheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          folderName.isEmpty ? 'Root' : folderName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          path,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    ),
                                    child: Text(
                                      '${songsInFolder.length} tracks',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageStatusCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTERNAL STORAGE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const Text(
                '35% Used',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: const LinearProgressIndicator(
              value: 0.35,
              backgroundColor: Color(0x11FFFFFF),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '/storage/emulated/0',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '44.8 GB / 128 GB',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No folders found with audio files',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSongsView(
    BuildContext context,
    String folderPath,
    List<Song> songs,
    PlayerProvider player,
    LibraryProvider library,
  ) {
    final folderName = folderPath.split('/').last;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.onSurface),
                      onPressed: () {
                        setState(() {
                          _selectedFolder = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folderName.isEmpty ? 'Root' : folderName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            folderPath,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Songs List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isCurrent = player.currentSong?.id == song.id;

                    return SongTile(
                      song: song,
                      isPlaying: isCurrent,
                      onTap: () {
                        player.playSong(song, playlist: songs, index: index);
                      },
                      onFavoriteToggle: () {
                        library.toggleFavorite(song);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
