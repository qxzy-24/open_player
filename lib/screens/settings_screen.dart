import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_header.dart';

/// Bento-grid styled settings and audio engine screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 10-band EQ mock state
  final List<double> _eqBands = List.filled(10, 0.0);
  String _selectedPreset = 'Flat';
  String _replayGain = 'Off';

  final Map<String, List<double>> _presets = {
    'Flat': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    'Rock': [0.4, 0.3, 0.2, -0.1, -0.2, -0.1, 0.1, 0.3, 0.4, 0.5],
    'Pop': [-0.2, -0.1, 0.1, 0.3, 0.4, 0.3, 0.0, -0.1, -0.2, -0.2],
    'Jazz': [0.3, 0.2, 0.1, 0.2, -0.1, -0.1, 0.0, 0.1, 0.2, 0.3],
    'Bass Boost': [0.7, 0.6, 0.4, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  };

  final List<String> _bandLabels = [
    '31Hz',
    '62Hz',
    '125Hz',
    '250Hz',
    '500Hz',
    '1kHz',
    '2kHz',
    '4kHz',
    '8kHz',
    '16kHz'
  ];

  @override
  void initState() {
    super.initState();
    _applyPreset('Flat');
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      final values = _presets[preset]!;
      for (int i = 0; i < 10; i++) {
        _eqBands[i] = values[i];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final player = Provider.of<PlayerProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Audio Settings'),

                // ── BENTO GRID ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                  child: Column(
                    children: [
                      // Grid Row 1: EQ Panel (Span 2)
                      _buildEQPanel(),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Grid Row 2: Playback Flow
                      _buildPlaybackFlowPanel(settings),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Grid Row 3: ReplayGain & Sleep Timer (Bento Cards Side by Side or stacked)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildReplayGainCard()),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(child: _buildSleepTimerCard(settings, player)),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Grid Row 4: Audio Engine Status & About
                      _buildStatusPanel(),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildAboutCard(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bento Card widgets ──────────────────────────────────────────

  Widget _buildEQPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10-BAND GRAPHIC EQUALIZER',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              DropdownButton<String>(
                value: _selectedPreset,
                dropdownColor: AppTheme.surfaceContainerHigh,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                underline: const SizedBox.shrink(),
                iconEnabledColor: AppTheme.primary,
                items: _presets.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _applyPreset(val);
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(10, (index) {
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppTheme.primary,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
                              thumbColor: AppTheme.tertiary,
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: _eqBands[index],
                              min: -1.0,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() {
                                  _eqBands[index] = val;
                                  _selectedPreset = 'Custom';
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _bandLabels[index],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackFlowPanel(SettingsProvider settings) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYBACK FLOW',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SwitchListTile(
            title: const Text('Gapless Playback'),
            subtitle: const Text('Eliminate silent gap between tracks'),
            value: settings.gaplessPlayback,
            contentPadding: EdgeInsets.zero,
            onChanged: settings.setGaplessPlayback,
          ),
          const Divider(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Crossfade Duration'),
                  Text(
                    '${settings.crossfadeDuration.toInt()}s',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Slider(
                value: settings.crossfadeDuration,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: settings.setCrossfadeDuration,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplayGainCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPLAY GAIN',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ...['Off', 'Track', 'Album'].map((mode) {
            return InkWell(
              onTap: () {
                setState(() {
                  _replayGain = mode;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _replayGain == mode
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _replayGain == mode ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mode,
                      style: TextStyle(
                        fontWeight: _replayGain == mode ? FontWeight.w600 : FontWeight.normal,
                        color: _replayGain == mode ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSleepTimerCard(SettingsProvider settings, PlayerProvider player) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SLEEP TIMER',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          if (settings.isSleepTimerActive) ...[
            Text(
              settings.sleepTimerDisplay,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentWarm,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: settings.cancelSleepTimer,
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
              ),
              child: const Text('Cancel Timer'),
            ),
          ] else ...[
            DropdownButton<int>(
              value: settings.sleepTimerMinutes,
              dropdownColor: AppTheme.surfaceContainerHigh,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface,
                  ),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [0, 15, 30, 45, 60].map((int mins) {
                return DropdownMenuItem<int>(
                  value: mins,
                  child: Text(mins == 0 ? 'Off' : '$mins mins'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null && val > 0) {
                  settings.startSleepTimer(val, onTimerComplete: () {
                    player.pause();
                  });
                } else if (val == 0) {
                  settings.cancelSleepTimer();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO ENGINE STATUS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatusRow('Direct Audio Routing', 'Active', Colors.green),
          const SizedBox(height: 8),
          _buildStatusRow('Resampler', '32-bit Float / 48kHz', AppTheme.secondary),
          const SizedBox(height: 8),
          _buildStatusRow('Decoder', 'FFmpeg Native / Lossless', AppTheme.tertiary),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Violet',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0 — Premium VIOLET Glass Edition',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Made with ♥ using Flutter',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
