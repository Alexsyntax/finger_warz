import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import '../utils/fade_page_route.dart';
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

class _OpponentSelectionScreenState extends State<OpponentSelectionScreen>
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
        opacity: _rng.nextDouble() * 0.28 + 0.08,
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
      resizeToAvoidBottomInset: true,
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
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                            maxWidth: 450,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Top bar
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _iconBtn(
                                      Icons.arrow_back_rounded,
                                      () => Navigator.pop(context),
                                    ),

                                    // Centre label
                                    Column(
                                      children: [
                                        AnimatedBuilder(
                                          animation: _shimmerController,
                                          builder: (_, __) => ShaderMask(
                                            shaderCallback: (b) =>
                                                LinearGradient(
                                              stops: [
                                                (_shimmer.value - 0.35)
                                                    .clamp(0.0, 1.0),
                                                _shimmer.value.clamp(0.0, 1.0),
                                                (_shimmer.value + 0.35)
                                                    .clamp(0.0, 1.0),
                                              ],
                                              colors: const [
                                                Color(0xFFFFD700),
                                                Colors.white,
                                                Color(0xFFFFD700),
                                              ],
                                            ).createShader(b),
                                            child: const Text(
                                              'CHOOSE OPPONENT',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 2.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Pick a battle mode and jump in.',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                Colors.white.withOpacity(0.30),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),

                                    _iconBtn(
                                      Icons.settings_rounded,
                                      () => Navigator.push(
                                        context,
                                        FadePageRoute(
                                            page: const SettingsScreen()),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                // ── Title
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'WHO DO YOU',
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
                                          'WANT TO FIGHT?',
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
                                    _divLine(const Color(0xFF00C8FF)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SELECT YOUR BATTLE MODE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.5,
                                        color: Colors.white.withOpacity(0.22),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _divLine(const Color(0xFF00C8FF)),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                // ── Mode cards
                                _buildModeCard(
                                  context,
                                  icon: Icons.people_rounded,
                                  title: '1V1 LOCAL',
                                  description:
                                      'Challenge your friend on the same device',
                                  accent: const Color(0xFF00C8FF),
                                  onTap: () => Navigator.push(
                                    context,
                                    FadePageRoute(
                                      page: Player2NameEntryScreen(
                                        player1Name: widget.playerName,
                                        settings: widget.settings,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                _buildModeCard(
                                  context,
                                  icon: Icons.smart_toy_rounded,
                                  title: 'VS AI',
                                  description:
                                      'Test your skills against the computer',
                                  accent: const Color(0xFFB066FF),
                                  onTap: () => Navigator.push(
                                    context,
                                    FadePageRoute(
                                      page: RulesScreen(
                                        playerName: widget.playerName,
                                        gameMode: GameMode.ai,
                                        settings: widget.settings,
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),
                                const SizedBox(height: 20),

                                // ── Footer
                                Center(
                                  child: AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (_, __) => ShaderMask(
                                      shaderCallback: (b) => LinearGradient(
                                        stops: [
                                          (_shimmer.value - 0.3)
                                              .clamp(0.0, 1.0),
                                          _shimmer.value.clamp(0.0, 1.0),
                                          (_shimmer.value + 0.3)
                                              .clamp(0.0, 1.0),
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

  // ── Mode card ─────────────────────────────────────────────────────
  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.04),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withOpacity(0.22),
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Top shimmer edge
              Positioned(
                top: -18,
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
                      colors: [
                        Colors.transparent,
                        accent,
                        Colors.transparent,
                      ],
                    ).createShader(b),
                    child: Container(height: 1.5, color: Colors.white),
                  ),
                ),
              ),

              Row(
                children: [
                  // Icon ring
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.10),
                      border: Border.all(
                        color: accent.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 24, color: accent),
                  ),
                  const SizedBox(width: 16),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.45),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Arrow badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: accent,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.55), size: 20),
      ),
    );
  }

  Widget _divLine(Color accent) {
    return Container(
      width: 20,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, accent.withOpacity(0.40)],
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
