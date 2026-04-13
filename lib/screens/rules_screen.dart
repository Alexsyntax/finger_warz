import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/fade_page_route.dart';
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

class _RulesScreenState extends State<RulesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final AnimationController _floatController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _shimmer;
  late final Animation<double> _float;

  final List<_Spark> _sparks = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _resumeMusic();

    for (int i = 0; i < 10; i++) {
      _sparks.add(_Spark(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 2.5 + 1.0,
        speed: _rng.nextDouble() * 0.4 + 0.2,
        phase: _rng.nextDouble() * 2 * pi,
        opacity: _rng.nextDouble() * 0.25 + 0.07,
        color:
            _rng.nextBool() ? const Color(0xFF00C8FF) : const Color(0xFFFFD700),
      ));
    }

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _entranceFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmer = Tween(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _float = Tween(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _resumeMusic() async {
    try {
      await MusicManager().resume();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF08083A),
      body: Stack(
        children: [
          // ── Top glow
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
                    const Color(0xFF00C8FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF08083A).withOpacity(0.35),
                    const Color(0xFF08083A).withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          // ── Sparks
          ...List.generate(_sparks.length, (i) {
            final sp = _sparks[i];
            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                final yOff = sin(_floatController.value * 2 * pi + sp.phase) *
                    18 *
                    sp.speed;
                return Positioned(
                  left: sp.x * size.width,
                  top: sp.y * size.height + yOff,
                  child: Opacity(
                    opacity: sp.opacity,
                    child: Container(
                      width: sp.size,
                      height: sp.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sp.color,
                        boxShadow: [
                          BoxShadow(
                            color: sp.color.withOpacity(0.6),
                            blurRadius: sp.size * 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // ── Content
          SafeArea(
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 450),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white.withOpacity(0.55),
                                    size: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Badge
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00C8FF),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x5500C8FF),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'HOW TO PLAY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 3,
                                      color: Color(0xFF00C8FF),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Title
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'THE',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (_, __) => ShaderMask(
                                      shaderCallback: (b) => LinearGradient(
                                        stops: [
                                          (_shimmer.value - 0.35)
                                              .clamp(0.0, 1.0),
                                          _shimmer.value.clamp(0.0, 1.0),
                                          (_shimmer.value + 0.35)
                                              .clamp(0.0, 1.0),
                                        ],
                                        colors: const [
                                          Color(0xFF00C8FF),
                                          Colors.white,
                                          Color(0xFF00C8FF),
                                        ],
                                      ).createShader(b),
                                      child: const Text(
                                        'RULES',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3,
                                          color: Colors.white,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Divider row
                              Row(
                                children: [
                                  _divLine(),
                                  const SizedBox(width: 8),
                                  Text(
                                    'KNOW BEFORE YOU FIGHT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.5,
                                      color: Colors.white.withOpacity(0.22),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _divLine(),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Rules card
                              _buildRulesCard(),

                              const SizedBox(height: 14),

                              // Beats card
                              _buildBeatsCard(),

                              const SizedBox(height: 24),

                              // CTA button
                              FWButton(
                                label: "LET'S FIGHT",
                                icon: Icons.sports_mma_rounded,
                                onPressed: () => Navigator.push(
                                  context,
                                  FadePageRoute(
                                    page: GameScreen(
                                      playerName: widget.playerName,
                                      gameMode: widget.gameMode,
                                      opponentName: widget.opponentName,
                                      settings: widget.settings,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Footer
                              Center(
                                child: AnimatedBuilder(
                                  animation: _shimmerController,
                                  builder: (_, __) => ShaderMask(
                                    shaderCallback: (b) => LinearGradient(
                                      stops: [
                                        (_shimmer.value - 0.3).clamp(0.0, 1.0),
                                        _shimmer.value.clamp(0.0, 1.0),
                                        (_shimmer.value + 0.3).clamp(0.0, 1.0),
                                      ],
                                      colors: const [
                                        Color(0xFFFFD700),
                                        Colors.white,
                                        Color(0xFFFFD700),
                                      ],
                                    ).createShader(b),
                                    child: Text(
                                      'FINGER WARZ',
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 3.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withOpacity(0.20),
                                      ),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  // ── Rules card ────────────────────────────────────────────────────
  Widget _buildRulesCard() {
    final rules = [
      (
        Icons.back_hand_rounded,
        'Choose your move',
        'Pick Rock, Paper, or Scissors each round.',
        const Color(0xFF00C8FF),
      ),
      widget.gameMode == GameMode.ai
          ? (
              Icons.smart_toy_rounded,
              'AI picks too',
              'The AI randomly selects its move simultaneously.',
              const Color(0xFFB066FF),
            )
          : (
              Icons.people_rounded,
              'Player 2 picks too',
              'Both players choose their moves simultaneously.',
              const Color(0xFFB066FF),
            ),
      (
        Icons.emoji_events_rounded,
        'Best of rounds',
        'First to win 5 rounds takes the match.',
        const Color(0xFFFFD700),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top shimmer edge
          Positioned(
            top: -20,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, __) => ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  stops: [
                    (_shimmer.value - 0.4).clamp(0.0, 1.0),
                    _shimmer.value.clamp(0.0, 1.0),
                    (_shimmer.value + 0.4).clamp(0.0, 1.0),
                  ],
                  colors: const [
                    Colors.transparent,
                    Color(0xFF00C8FF),
                    Colors.transparent,
                  ],
                ).createShader(b),
                child: Container(height: 1.5, color: Colors.white),
              ),
            ),
          ),

          Column(
            children: rules.asMap().entries.map((entry) {
              final i = entry.key;
              final rule = entry.value;
              final accent = rule.$4;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withOpacity(0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(rule.$1, color: accent, size: 18),
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
                                color: Colors.white.withOpacity(0.38),
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
                        color: Colors.white.withOpacity(0.06),
                        thickness: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Beats card ────────────────────────────────────────────────────
  Widget _buildBeatsCard() {
    final matchups = [
      (
        HandGesture.rock,
        'Rock',
        HandGesture.scissors,
        'Scissors',
        const Color(0xFF00C8FF)
      ),
      (
        HandGesture.paper,
        'Paper',
        HandGesture.rock,
        'Rock',
        const Color(0xFFB066FF)
      ),
      (
        HandGesture.scissors,
        'Scissors',
        HandGesture.paper,
        'Paper',
        const Color(0xFFFFD700)
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _divLine(),
              const SizedBox(width: 8),
              Text(
                'WHAT BEATS WHAT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
              const SizedBox(width: 8),
              _divLine(),
            ],
          ),
          const SizedBox(height: 16),
          ...matchups.map((m) {
            final accent = m.$5;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  HandWidget(gesture: m.$1, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    m.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: accent.withOpacity(0.20),
                      ),
                    ),
                    child: Text(
                      'beats',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: accent.withOpacity(0.70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  HandWidget(gesture: m.$3, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    m.$4,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.40),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _divLine() {
    return Container(
      width: 20,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF00C8FF).withOpacity(0.40),
          ],
        ),
      ),
    );
  }
}

// ── Spark data class ──────────────────────────────────────────────
class _Spark {
  final double x, y, size, speed, phase, opacity;
  final Color color;
  const _Spark({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.color,
  });
}
