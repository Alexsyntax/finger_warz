import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';
import '../services/music_manager.dart';
import 'name_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Music is already started from SplashScreen
    // Just ensure it continues playing on this screen
    _ensureMusicPlaying();
  }

  Future<void> _ensureMusicPlaying() async {
    try {
      final musicManager = MusicManager();
      // If music is paused, resume it
      if (!musicManager.isPlaying) {
        print('[HomeScreen] Music not playing, attempting to resume...');
        await musicManager.resume();
      }
    } catch (e) {
      print('[HomeScreen] Error ensuring music: $e');
    }
  }

  Future<void> _attemptMusicResume() async {
    try {
      final musicManager = MusicManager();
      await musicManager.resume();
    } catch (e) {
      print('[HomeScreen] Error resuming music: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
          // Subtle top glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    AppTheme.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 500 ? 420.0 : 360.0;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hero card
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 36, horizontal: 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary.withOpacity(0.10),
                                    border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.40),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(Icons.back_hand_rounded,
                                      size: 34, color: AppTheme.primary),
                                ),
                                const SizedBox(height: 24),
                                Column(
                                  children: [
                                    const Text(
                                      'FINGER',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 8,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        colors: [
                                          AppTheme.primary,
                                          AppTheme.primary.withOpacity(0.55),
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'WARZ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 8,
                                          color: Colors.white,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 20,
                                        height: 1,
                                        color: Colors.white.withOpacity(0.12)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rock · Paper · Scissors',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2.5,
                                        color: Colors.white.withOpacity(0.30),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                        width: 20,
                                        height: 1,
                                        color: Colors.white.withOpacity(0.12)),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildPill(
                                        Icons.person_rounded, '1v1 Local'),
                                    _buildPill(
                                        Icons.smart_toy_rounded, 'vs AI'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ✅ Updated: navigates to NameEntryScreen
                          FWButton(
                            label: 'START GAME',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () {
                              // Trigger music on user interaction for web
                              _attemptMusicResume();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NameEntryScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.55),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
