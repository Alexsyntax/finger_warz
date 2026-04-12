import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'rules_screen.dart';
import 'opponent_selection_screen.dart';

class Player2NameEntryScreen extends StatefulWidget {
  final String player1Name;
  final GameSettings settings;

  const Player2NameEntryScreen({
    super.key,
    required this.player1Name,
    required this.settings,
  });

  @override
  State<Player2NameEntryScreen> createState() => _Player2NameEntryScreenState();
}

class _Player2NameEntryScreenState extends State<Player2NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _hasText = _nameController.text.trim().isNotEmpty);
    });
    _resumeMusic();
  }

  Future<void> _resumeMusic() async {
    final musicManager = MusicManager();
    await musicManager.resume();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RulesScreen(
          playerName: widget.player1Name,
          gameMode: GameMode.local,
          opponentName: name,
          settings: widget.settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
          // ✅ FIX 1: top: 0 (was -60), height: 120 (was 260)
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    // ✅ FIX 2: Column + Padding replaces SingleChildScrollView
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16), // was 32
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20),
                            ),
                          ),

                          // ✅ FIX 3: was 40
                          const SizedBox(height: 20),

                          // Player two badge
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  color: AppTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'PLAYER TWO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10), // was 12

                          const Text(
                            'WHAT\'S YOUR\nNAME?',
                            style: TextStyle(
                              fontSize: 32, // was 34
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),

                          // ✅ FIX 4: was 32
                          const SizedBox(height: 16),

                          // Name input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: TextField(
                              controller: _nameController,
                              focusNode: _focusNode,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.25),
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              maxLength: 15,
                              onSubmitted: (_) {
                                if (_hasText) _continue();
                              },
                            ),
                          ),

                          // ✅ FIX 5: Spacer pushes CTA to bottom
                          const Spacer(),

                          // Continue button
                          AnimatedOpacity(
                            opacity: _hasText ? 1.0 : 0.35,
                            duration: const Duration(milliseconds: 200),
                            child: FWButton(
                              label: 'CONTINUE',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: _hasText ? _continue : () {},
                            ),
                          ),

                          // Decorative footer
                          const SizedBox(height: 20), // was 32
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
