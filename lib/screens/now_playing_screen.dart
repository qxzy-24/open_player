import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/album_art.dart';

/// Full-screen Now Playing view with album art, controls, and seek bar.
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        if (!player.hasSong) {
          return const Scaffold(
            body: Center(child: Text('No song playing')),
          );
        }

        final song = player.currentSong!;
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.nowPlayingGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // ── Album Art ───────────────────────────────
                    Hero(
                      tag: 'now_playing_art',
                      child: AnimatedBuilder(
                        listenable: _rotationController,
                        builder: (context, child) {
                          final isPlaying = player.isPlaying;
                          if (!isPlaying) {
                            _rotationController.stop();
                          } else if (!_rotationController.isAnimating) {
                            _rotationController.repeat();
                          }
                          return child!;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXl),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
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
                            size: screenHeight * 0.35,
                            borderRadius: AppTheme.radiusXl,
                            showShadow: false,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Song Info ────────────────────────────────
                    Column(
                      children: [
                        Text(
                          song.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${song.artist}  •  ${song.album}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Progress Bar ────────────────────────────
                    ProgressBar(
                      progress: player.position,
                      total: player.duration,
                      buffered: player.buffered,
                      onSeek: player.seek,
                      barHeight: 4,
                      thumbRadius: 7,
                      thumbGlowRadius: 18,
                      progressBarColor: AppTheme.primaryColor,
                      bufferedBarColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                      baseBarColor: AppTheme.dividerColor,
                      thumbColor: AppTheme.primaryColor,
                      thumbGlowColor:
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                      timeLabelTextStyle: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Main Controls ───────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        _buildControlButton(
                          icon: Icons.shuffle_rounded,
                          isActive: player.shuffleEnabled,
                          onPressed: player.toggleShuffle,
                          size: 24,
                        ),

                        // Previous
                        _buildControlButton(
                          icon: Icons.skip_previous_rounded,
                          onPressed: player.previous,
                          size: 32,
                        ),

                        // Play/Pause
                        _buildPlayButton(player),

                        // Next
                        _buildControlButton(
                          icon: Icons.skip_next_rounded,
                          onPressed: player.next,
                          size: 32,
                        ),

                        // Repeat
                        _buildControlButton(
                          icon: _getRepeatIcon(player.loopMode),
                          isActive: player.loopMode != LoopMode.off,
                          onPressed: player.cycleLoopMode,
                          size: 24,
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(PlayerProvider player) {
    return GestureDetector(
      onTap: player.togglePlayPause,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(player.isPlaying),
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 24,
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: size,
        color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      onPressed: onPressed,
      splashRadius: 24,
    );
  }

  IconData _getRepeatIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.one:
        return Icons.repeat_one_rounded;
      default:
        return Icons.repeat_rounded;
    }
  }
}

/// AnimatedBuilder that works like AnimatedWidget but takes a builder.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
