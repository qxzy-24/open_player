import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/floating_nav_bar.dart';
import 'library_screen.dart';
import 'folders_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Main app shell with floating bottom navigation and persistent mini player.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    FoldersScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          // Atmospheric radial gradient from Stitch design
          gradient: RadialGradient(
            center: const Alignment(0.7, -0.5),
            radius: 1.5,
            colors: [
              AppTheme.primaryContainer.withValues(alpha: 0.05),
              AppTheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background noise texture (subtle)
            Positioned.fill(
              child: CustomPaint(
                painter: _NoisePainter(),
              ),
            ),

            // Main Content
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),

            // Mini Player — above the nav bar
            const Positioned(
              left: 0,
              right: 0,
              bottom: 76,
              child: MiniPlayer(),
            ),

            // Floating Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle noise texture overlay for atmospheric depth.
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally empty — the noise is decorative and would need
    // a shader for proper implementation. We rely on the gradient
    // and glass effects for depth instead.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
