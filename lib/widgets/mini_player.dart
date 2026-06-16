import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../screens/now_playing_screen.dart';
import '../core/theme/app_theme.dart';
import 'album_art.dart';
import 'glass_panel.dart';

/// Persistent mini player bar shown at bottom of main scaffold.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerProvider, _MiniPlayerState>(
      selector: (_, player) => _MiniPlayerState(
        song: player.currentSong,
        isPlaying: player.isPlaying,
      ),
      builder: (context, state, child) {
        if (state.song == null) return const SizedBox.shrink();

        final song = state.song!;
        final player = context.read<PlayerProvider>();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const NowPlayingScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassPanel(
              borderRadius: AppTheme.radiusMd,
              padding: EdgeInsets.zero,
              color: AppTheme.surfaceContainer.withValues(alpha: 0.65),
              borderOpacity: 0.08,
              hasShadow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _MiniPlayerProgressBar(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'now_playing_art',
                          child: AlbumArtWidget(
                            songId: song.id,
                            size: 40,
                            borderRadius: AppTheme.radiusSm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurface,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 24),
                          color: AppTheme.onSurfaceVariant,
                          onPressed: player.previous,
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.inversePrimary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                key: ValueKey(state.isPlaying),
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: player.togglePlayPause,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 24),
                          color: AppTheme.onSurfaceVariant,
                          onPressed: player.next,
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniPlayerProgressBar extends StatelessWidget {
  const _MiniPlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    return Selector<ProgressProvider, double>(
      selector: (_, progress) {
        final durationMs = progress.duration.inMilliseconds;
        if (durationMs <= 0) return 0;
        final ratio = progress.position.inMilliseconds / durationMs;
        return ratio.clamp(0.0, 1.0).toDouble();
      },
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusMd),
          ),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primary,
            ),
            minHeight: 2,
          ),
        );
      },
    );
  }
}

class _MiniPlayerState {
  final Song? song;
  final bool isPlaying;

  const _MiniPlayerState({required this.song, required this.isPlaying});

  @override
  bool operator ==(Object other) {
    return other is _MiniPlayerState &&
        other.song?.id == song?.id &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => Object.hash(song?.id, isPlaying);
}
