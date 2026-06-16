import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/library_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/album_art.dart';

/// Full-screen premium Now Playing view with atmospheric VIOLET design.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerProvider, _NowPlayingState>(
      selector: (_, player) => _NowPlayingState(
        song: player.currentSong,
        isPlaying: player.isPlaying,
        shuffleEnabled: player.shuffleEnabled,
        loopMode: player.loopMode,
      ),
      builder: (context, state, child) {
        final song = state.song;
        if (song == null) {
          return Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: Text('No song playing', style: TextStyle(color: AppTheme.outline)),
            ),
          );
        }

        final player = context.read<PlayerProvider>();
        final library = context.read<LibraryProvider>();
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1042),
                  AppTheme.surface,
                  AppTheme.surfaceContainerLowest,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Atmospheric glow behind album art
                Positioned(
                  top: screenHeight * 0.1,
                  left: screenWidth * 0.15,
                  right: screenWidth * 0.15,
                  child: Container(
                    height: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.inversePrimary.withValues(alpha: 0.15),
                          blurRadius: 100,
                          spreadRadius: 60,
                        ),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // ── Top Bar ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                              color: AppTheme.onSurfaceVariant,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            // Direct Mode badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: AppTheme.primary.withValues(alpha: 0.5), blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('PLAYING',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              color: AppTheme.onSurfaceVariant,
                              onPressed: () => _showMoreOptions(context, song, player, library),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Album Art ─────────────────────────
                      Hero(
                        tag: 'now_playing_art',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.inversePrimary.withValues(alpha: 0.3),
                                blurRadius: 50,
                                spreadRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 2,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: AlbumArtWidget(
                            songId: song.id,
                            size: screenWidth * 0.75,
                            borderRadius: AppTheme.radiusXl,
                            showShadow: false,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Song Info ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${song.artist}  •  ${song.album}',
                              style: TextStyle(
                                color: AppTheme.primary.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Progress Bar ──────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: _SeekBar(onSeek: player.seek),
                      ),

                      const SizedBox(height: 20),

                      // ── Main Controls ─────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle
                            _ControlButton(
                              icon: Icons.shuffle_rounded,
                              isActive: state.shuffleEnabled,
                              onPressed: player.toggleShuffle,
                              size: 22,
                            ),
                            // Previous
                            _GlassCircleButton(
                              icon: Icons.skip_previous_rounded,
                              onPressed: player.previous,
                              size: 52,
                              iconSize: 28,
                            ),
                            // Play/Pause
                            _PlayButton(
                              isPlaying: state.isPlaying,
                              onTap: player.togglePlayPause,
                            ),
                            // Next
                            _GlassCircleButton(
                              icon: Icons.skip_next_rounded,
                              onPressed: player.next,
                              size: 52,
                              iconSize: 28,
                            ),
                            // Repeat
                            _ControlButton(
                              icon: _getRepeatIcon(state.loopMode),
                              isActive: state.loopMode != LoopMode.off,
                              onPressed: player.cycleLoopMode,
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Action Row ────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              label: song.isFavorite ? 'Loved' : 'Love',
                              isActive: song.isFavorite,
                              activeColor: AppTheme.accentWarm,
                              onTap: () => library.toggleFavorite(song),
                            ),
                            _ActionButton(
                              icon: Icons.queue_music_rounded,
                              label: 'Queue',
                              onTap: () => _showQueue(context),
                            ),
                            _ActionButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Info',
                              onTap: () => _showSongInfo(context, song),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context, Song song, PlayerProvider player, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('Add to Playlist'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.speed_rounded),
                title: const Text('Playback Speed'),
                trailing: Text('${player.playbackSpeed}x', style: TextStyle(color: AppTheme.primary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSpeedPicker(context, player);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: const Text('Sleep Timer'),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedPicker(BuildContext context, PlayerProvider player) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text('Playback Speed', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...speeds.map((speed) => ListTile(
                  title: Text('${speed}x'),
                  trailing: player.playbackSpeed == speed
                      ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    player.setPlaybackSpeed(speed);
                    Navigator.pop(ctx);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQueue(BuildContext context) {
    final player = context.read<PlayerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            final queue = player.queue;
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text('Queue', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${queue.length} songs', style: TextStyle(color: AppTheme.outline, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: queue.isEmpty
                      ? Center(child: Text('Queue is empty', style: TextStyle(color: AppTheme.outline)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final song = queue[index];
                            final isCurrent = index == player.currentIndex;
                            return ListTile(
                              leading: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppTheme.primaryContainer.withValues(alpha: 0.2)
                                      : AppTheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: isCurrent
                                      ? const Icon(Icons.equalizer_rounded, color: AppTheme.primary, size: 20)
                                      : Text('${index + 1}', style: TextStyle(color: AppTheme.outline, fontSize: 12)),
                                ),
                              ),
                              title: Text(song.title,
                                style: TextStyle(
                                  color: isCurrent ? AppTheme.primary : AppTheme.onSurface,
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(song.artist,
                                style: TextStyle(color: AppTheme.outline, fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
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

  void _showSongInfo(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('Track Info', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _InfoRow('Title', song.title),
                _InfoRow('Artist', song.artist),
                _InfoRow('Album', song.album),
                _InfoRow('Duration', song.formattedDuration),
                if (song.genre != null) _InfoRow('Genre', song.genre!),
                _InfoRow('Play Count', '${song.playCount}'),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getRepeatIcon(LoopMode mode) {
    return mode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded;
  }
}

// ── Info Row ──────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: AppTheme.outline, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ── Seek Bar ──────────────────────────────────────────────────
class _SeekBar extends StatelessWidget {
  final ValueChanged<Duration> onSeek;
  const _SeekBar({required this.onSeek});

  @override
  Widget build(BuildContext context) {
    return Selector<ProgressProvider, _SeekBarState>(
      selector: (_, progress) => _SeekBarState(
        position: progress.position,
        duration: progress.duration,
        buffered: progress.buffered,
      ),
      builder: (context, state, child) {
        return ProgressBar(
          progress: state.position,
          total: state.duration,
          buffered: state.buffered,
          onSeek: onSeek,
          barHeight: 4,
          thumbRadius: 7,
          thumbGlowRadius: 18,
          progressBarColor: AppTheme.primary,
          bufferedBarColor: AppTheme.primary.withValues(alpha: 0.15),
          baseBarColor: AppTheme.surfaceBright.withValues(alpha: 0.3),
          thumbColor: AppTheme.primary,
          thumbGlowColor: AppTheme.primary.withValues(alpha: 0.3),
          timeLabelTextStyle: TextStyle(
            color: AppTheme.outline,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}

// ── Play Button ───────────────────────────────────────────────
class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.inversePrimary.withValues(alpha: 0.4),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Control Button ────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isActive;
  const _ControlButton({required this.icon, required this.onPressed, this.size = 24, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant),
      onPressed: onPressed,
    );
  }
}

// ── Glass Circle Button ───────────────────────────────────────
class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  const _GlassCircleButton({required this.icon, required this.onPressed, this.size = 48, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: iconSize, color: AppTheme.onSurface),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.isActive = false, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? AppTheme.primary) : AppTheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── State Classes ─────────────────────────────────────────────
class _NowPlayingState {
  final Song? song;
  final bool isPlaying;
  final bool shuffleEnabled;
  final LoopMode loopMode;
  const _NowPlayingState({required this.song, required this.isPlaying, required this.shuffleEnabled, required this.loopMode});

  @override
  bool operator ==(Object other) {
    return other is _NowPlayingState &&
        other.song?.id == song?.id && other.isPlaying == isPlaying &&
        other.shuffleEnabled == shuffleEnabled && other.loopMode == loopMode;
  }

  @override
  int get hashCode => Object.hash(song?.id, isPlaying, shuffleEnabled, loopMode);
}

class _SeekBarState {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  const _SeekBarState({required this.position, required this.duration, required this.buffered});

  @override
  bool operator ==(Object other) {
    return other is _SeekBarState && other.position == position && other.duration == duration && other.buffered == buffered;
  }

  @override
  int get hashCode => Object.hash(position, duration, buffered);
}
