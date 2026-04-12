import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'player2_name_entry_screen.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';

enum GameMode { local, ai }

class OpponentSelectionScreen extends StatefulWidget {
  final String playerName;
  final GameSettings settings;

  const OpponentSelectionScreen({
    super.key,
    required this.playerName,
    required this.settings,
  });

  @override
  State<OpponentSelectionScreen> createState() =>
      _OpponentSelectionScreenState();
}

class _OpponentSelectionScreenState extends State<OpponentSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _resumeMusic();
  }

  Future<void> _resumeMusic() async {
    final musicManager = MusicManager();
    await musicManager.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    AppTheme.primary.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const maxWidth = 450.0;
                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth:
                            maxWidth, // ✅ removed maxHeight — conflicts with scroll
                      ),
                      child: IntrinsicHeight(
                        // ✅ added so Column fills min height properly
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Icon(Icons.arrow_back_rounded,
                                        color: Colors.white.withOpacity(0.85),
                                        size: 20),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'CHOOSE OPPONENT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pick a battle mode and jump in.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.50),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.settings_rounded,
                                      color: Colors.white.withOpacity(0.85),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'WHO DO YOU\nWANT TO FIGHT?',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                                height: 1.05,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _buildOpponentCard(
                              context,
                              icon: Icons.people_rounded,
                              title: '1V1 LOCAL',
                              description:
                                  'Challenge your friend on the same device',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Player2NameEntryScreen(
                                      player1Name: widget.playerName,
                                      settings: widget.settings,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            _buildOpponentCard(
                              context,
                              icon: Icons.smart_toy_rounded,
                              title: 'VS AI',
                              description:
                                  'Test your skills against the computer',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RulesScreen(
                                      playerName: widget.playerName,
                                      gameMode: GameMode.ai,
                                      settings: widget.settings,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const Spacer(), // ✅ pushes footer to bottom

                            const SizedBox(height: 20),

                            Center(
                              child: Text(
                                '⚡ FINGER WARZ',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  color: Colors.white.withOpacity(0.10),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
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

  Widget _buildOpponentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.14),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 26, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.60),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: AppTheme.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
