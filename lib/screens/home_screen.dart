import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/fade_page_route.dart';
import '../widgets/fw_button.dart';
import '../services/music_manager.dart';
import 'name_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _shimmerController;
  late final AnimationController _lightningController;

  late final Animation<double> _pulse;
  late final Animation<double> _float;
  late final Animation<double> _shimmer;
  late final Animation<double> _lightning;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;
  late final AnimationController _entranceController;

  final List<_Spark> _sparks = [];
  final List<_LightningBolt> _bolts = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _ensureMusicPlaying();

    for (int i = 0; i < 20; i++) {
      _sparks.add(_Spark(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3.5 + 1.2,
        speed: _rng.nextDouble() * 0.5 + 0.2,
        phase: _rng.nextDouble() * 2 * pi,
        opacity: _rng.nextDouble() * 0.5 + 0.15,
        color:
            _rng.nextBool() ? const Color(0xFF00C8FF) : const Color(0xFFFFD700),
      ));
    }
    for (int i = 0; i < 5; i++) _bolts.add(_LightningBolt.random(_rng));

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _entranceFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceSlide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _shimmer = Tween(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _lightning = Tween(begin: 0.0, end: 1.0).animate(_lightningController);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  Future<void> _ensureMusicPlaying() async {
    try {
      final m = MusicManager();
      if (!m.isPlaying) await m.resume();
    } catch (e) {
      debugPrint('[HomeScreen] $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF08083A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    const Color(0xFF00C8FF).withOpacity(0.10),
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
                    const Color(0xFF08083A).withOpacity(0.45),
                    const Color(0xFF08083A).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // ── Lightning
          AnimatedBuilder(
            animation: _lightning,
            builder: (_, __) => CustomPaint(
              painter: _LightningPainter(
                  bolts: _bolts, progress: _lightningController.value),
              size: size,
            ),
          ),

          // ── Sparks
          ...List.generate(_sparks.length, (i) {
            final sp = _sparks[i];
            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                final yOff = sin(_floatController.value * 2 * pi + sp.phase) *
                    22 *
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
                              color: sp.color.withOpacity(0.7),
                              blurRadius: sp.size * 3)
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
                    final maxW = constraints.maxWidth > 500 ? 420.0 : 360.0;
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeroCard(),
                              const SizedBox(height: 20),
                              _buildStartButton(),
                              const SizedBox(height: 32),
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

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top edge shimmer line
          Positioned(
            top: -18,
            left: 24,
            right: 24,
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
                    Colors.transparent
                  ],
                ).createShader(b),
                child: Container(height: 1.5, color: Colors.white),
              ),
            ),
          ),

          Column(
            children: [
              // Logo ring with pulse
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00C8FF).withOpacity(0.10),
                      border: Border.all(
                          color: const Color(0xFF00C8FF).withOpacity(0.40),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C8FF).withOpacity(0.20),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.back_hand_rounded,
                        size: 34, color: Color(0xFF00C8FF)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Floating title
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _float.value * 0.4),
                  child: Column(
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
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Color(0xFF00C8FF), Color(0xFFB066FF)],
                        ).createShader(b),
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
                ),
              ),
              const SizedBox(height: 16),

              // ── FIX: centered subtitle row, text wrapped in Flexible
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _divLine(right: true),
                  const SizedBox(width: 8),
                  Flexible(
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
                            Color(0xFFFFD700)
                          ],
                        ).createShader(b),
                        child: const Text(
                          'ROCK · PAPER · SCISSORS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _divLine(right: false),
                ],
              ),
              const SizedBox(height: 24),

              // Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildPill(Icons.person_rounded, '1v1 LOCAL',
                      const Color(0xFF00C8FF)),
                  _buildPill(Icons.smart_toy_rounded, 'VS AI',
                      const Color(0xFFB066FF)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _float.value * 0.5),
        child: child,
      ),
      child: GestureDetector(
        onTap: () {
          _ensureMusicPlaying();
          Navigator.push(context, FadePageRoute(page: const NameEntryScreen()));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF00C8FF), Color(0xFFB066FF)],
            ),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF00C8FF).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
              BoxShadow(
                  color: const Color(0xFFB066FF).withOpacity(0.20),
                  blurRadius: 40,
                  spreadRadius: -4),
            ],
          ),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (_, __) => ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (b) => LinearGradient(
                stops: [
                  (_shimmer.value - 0.25).clamp(0.0, 1.0),
                  _shimmer.value.clamp(0.0, 1.0),
                  (_shimmer.value + 0.25).clamp(0.0, 1.0),
                ],
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.30),
                  Colors.white.withOpacity(0.0),
                ],
              ).createShader(b),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'START GAME',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.7), blurRadius: 5)
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent.withOpacity(0.80),
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }

  Widget _divLine({required bool right}) {
    return Container(
      width: 20,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: right
              ? [Colors.transparent, const Color(0xFFFFD700).withOpacity(0.6)]
              : [const Color(0xFFFFD700).withOpacity(0.6), Colors.transparent],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightning bolt painter
// ─────────────────────────────────────────────────────────────────────────────
class _LightningBolt {
  final List<Offset> points;
  final double triggerPhase; // 0..1 in the animation cycle when this fires
  final Color color;
  final double opacity;

  const _LightningBolt({
    required this.points,
    required this.triggerPhase,
    required this.color,
    required this.opacity,
  });

  factory _LightningBolt.random(Random rng) {
    // Zigzag from top to bottom edge, skewed to the sides
    final startX = rng.nextDouble();
    final points = <Offset>[];
    double x = startX;
    double y = 0;
    final steps = rng.nextInt(5) + 5;
    for (int i = 0; i <= steps; i++) {
      points.add(Offset(x, y));
      x += (rng.nextDouble() - 0.5) * 0.25;
      x = x.clamp(0.0, 1.0);
      y += 1 / steps;
    }
    return _LightningBolt(
      points: points,
      triggerPhase: rng.nextDouble(),
      color: rng.nextBool() ? const Color(0xFF00C8FF) : const Color(0xFFB066FF),
      opacity: rng.nextDouble() * 0.35 + 0.15,
    );
  }
}

class _LightningPainter extends CustomPainter {
  final List<_LightningBolt> bolts;
  final double progress; // 0..1 repeating

  const _LightningPainter({required this.bolts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final bolt in bolts) {
      // Only flash briefly near its trigger phase
      final dist = (progress - bolt.triggerPhase).abs();
      if (dist > 0.06 && dist < 0.94) continue;

      final flickerDist = dist < 0.5 ? dist : 1.0 - dist;
      final alpha = (1.0 - flickerDist / 0.06).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      final paint = Paint()
        ..color = bolt.color.withOpacity(bolt.opacity * alpha)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final path = Path();
      for (int i = 0; i < bolt.points.length; i++) {
        final p = Offset(
          bolt.points[i].dx * size.width,
          bolt.points[i].dy * size.height,
        );
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);

      // Bright core line
      paint
        ..color = Colors.white.withOpacity(0.6 * alpha)
        ..strokeWidth = 0.6
        ..maskFilter = null;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightningPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────
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
