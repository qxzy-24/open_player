import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import 'glass_card.dart';

class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final player = Provider.of<PlayerProvider>(context, listen: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sleep Timer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            if (settings.isSleepTimerActive) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primary.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timer is active',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Remaining: ${settings.sleepTimerDisplay}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        settings.cancelSleepTimer();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...[15, 30, 45, 60].map((mins) {
              final isCurrent = settings.sleepTimerMinutes == mins && settings.isSleepTimerActive;
              return ListTile(
                leading: Icon(
                  Icons.timer_outlined,
                  color: isCurrent ? AppTheme.primary : AppTheme.onSurfaceVariant,
                ),
                title: Text(
                  '$mins minutes',
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? AppTheme.primary : AppTheme.onSurface,
                  ),
                ),
                trailing: isCurrent ? const Icon(Icons.check_rounded, color: AppTheme.primary) : null,
                onTap: () {
                  settings.startSleepTimer(mins, onTimerComplete: () {
                    player.pause();
                  });
                  Navigator.pop(context);
                },
              );
            }),
            ListTile(
              leading: const Icon(Icons.timer_off_outlined, color: Colors.redAccent),
              title: const Text('Turn Off', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                settings.cancelSleepTimer();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
