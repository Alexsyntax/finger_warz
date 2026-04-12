import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';
import '../widgets/hand_widget.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'game_screen.dart';
import 'opponent_selection_screen.dart';

class RulesScreen extends StatefulWidget {
  final String playerName;
  final GameMode gameMode;
  final String? opponentName;
  final GameSettings settings;

  const RulesScreen({
    super.key,
    this.playerName = 'Player',
    this.gameMode = GameMode.ai,
    this.opponentName,
    required this.settings,
  });

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
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
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
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
                    AppTheme.primary.withOpacity(0.10),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = 450.0;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
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

                          const SizedBox(height: 40),

                          // Title
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded,
                                  color: AppTheme.primary, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'HOW TO PLAY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'THE RULES',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Rules card
                          _buildRulesCard(),

                          const SizedBox(height: 20),

                          // Wins chart
                          _buildBeatsCard(),

                          const SizedBox(height: 32),

                          FWButton(
                            label: "LET'S FIGHT",
                            icon: Icons.sports_mma_rounded,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    playerName: widget.playerName,
                                    gameMode: widget.gameMode,
                                    opponentName: widget.opponentName,
                                    settings: widget.settings,
                                  ),
                                ),
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

  Widget _buildRulesCard() {
    final rules = [
      (
        Icons.back_hand_rounded,
        'Choose your move',
        'Pick Rock, Paper, or Scissors each round.'
      ),
      widget.gameMode == GameMode.ai
          ? (
              Icons.smart_toy_rounded,
              'AI picks too',
              'The AI randomly selects its move simultaneously.'
            )
          : (
              Icons.people_rounded,
              'Player 2 picks too',
              'Both players choose their moves simultaneously.'
            ),
      (
        Icons.emoji_events_rounded,
        'Best of rounds',
        'First to win 5 rounds takes the match.'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        children: rules.asMap().entries.map((entry) {
          final i = entry.key;
          final rule = entry.value;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppTheme.primary.withOpacity(0.25)),
                    ),
                    child: Icon(rule.$1, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rule.$3,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.40),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < rules.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(
                      color: Colors.white.withOpacity(0.06), thickness: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBeatsCard() {
    final matchups = [
      (HandGesture.rock, 'Rock', 'beats', HandGesture.scissors, 'Scissors'),
      (HandGesture.paper, 'Paper', 'beats', HandGesture.rock, 'Rock'),
      (HandGesture.scissors, 'Scissors', 'beats', HandGesture.paper, 'Paper'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT BEATS WHAT',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 16),
          ...matchups.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    HandWidget(gesture: m.$1, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      m.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.30),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    HandWidget(gesture: m.$4, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      m.$5,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
