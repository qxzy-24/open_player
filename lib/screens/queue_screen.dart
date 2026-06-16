import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/album_art.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final queue = player.queue;
    final currentIndex = player.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Queue'),
        centerTitle: true,
        actions: [
          if (queue.isNotEmpty)
            TextButton(
              onPressed: () {
                player.clearQueue();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: queue.isEmpty
              ? _buildEmptyState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Currently Playing Section
                    if (currentIndex >= 0 && currentIndex < queue.length) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'NOW PLAYING',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderOpacity: 0.2,
                          child: Row(
                            children: [
                              AlbumArtWidget(
                                songId: queue[currentIndex].id,
                                size: 50,
                                borderRadius: AppTheme.radiusSm,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      queue[currentIndex].title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      queue[currentIndex].artist,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.equalizer_rounded,
                                color: AppTheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Upcoming Songs Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'UPCOMING TRACKS (${queue.length - (currentIndex + 1)})',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ),

                    Expanded(
                      child: Theme(
                        data: ThemeData(
                          canvasColor: Colors.transparent, // prevents card background artifact when dragging
                        ),
                        child: ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          itemCount: queue.length,
                          onReorder: player.reorderQueue,
                          itemBuilder: (context, index) {
                            // Don't show current song in the reorderable list of upcoming tracks, 
                            // or show it but disable dragging for it.
                            final song = queue[index];
                            final isCurrent = index == currentIndex;

                            if (isCurrent) return SizedBox(key: ValueKey(song.id)); // skip, handled above

                            return Dismissible(
                              key: ValueKey(song.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                player.removeFromQueue(index);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      AlbumArtWidget(
                                        songId: song.id,
                                        size: 40,
                                        borderRadius: AppTheme.radiusSm,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppTheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              song.artist,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.drag_handle_rounded,
                                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
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
            Icons.playlist_play_rounded,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your queue is currently empty',
            style: TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
