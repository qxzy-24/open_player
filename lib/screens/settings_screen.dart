import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Application settings screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 24),

          // ── About Section ──────────────────────────────────
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppTheme.dividerColor),
              _buildSettingItem(
                icon: Icons.music_note_rounded,
                title: 'Open Player',
                subtitle: 'Premium Music Experience',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Playback Section ───────────────────────────────
          _buildSectionHeader('Playback'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildSettingsSwitch(
                icon: Icons.graphic_eq_rounded,
                title: 'Gapless Playback',
                subtitle: 'Smooth transitions between tracks',
                value: true,
                onChanged: (v) {},
              ),
              const Divider(height: 1, color: AppTheme.dividerColor),
              _buildSettingsSwitch(
                icon: Icons.speed_rounded,
                title: 'Crossfade',
                subtitle: 'Fade between songs',
                value: false,
                onChanged: (v) {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Display Section ────────────────────────────────
          _buildSectionHeader('Display'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildSettingsSwitch(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Theme',
                subtitle: 'Always on (more themes coming soon)',
                value: true,
                onChanged: (v) {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Credits ────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
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
                    'Open Player',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Made with ♥ using Flutter',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
