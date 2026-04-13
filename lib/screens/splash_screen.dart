import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _lightningController;
  late final AnimationController _shimmerController;
  late final AnimationController _loaderController;

  late final Animation<double> _bgScale;
  late final Animation<double> _bgFade;
  late final Animation<double> _overlayFade;
  late final Animation<double> _loaderFade;
  late final Animation<double> _loaderProgress;
  late final Animation<double> _pulse;
  late final Animation<double> _float;
  late final Animation<double> _lightning;
  late final Animation<double> _shimmer;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  final List<_Spark> _sparks = [];
  final Random _rng = Random();

  // Lightning bolt data — pre-generated for performance
  final List<_LightningBolt> _bolts = [];

  @override
  void initState() {
    super.initState();
    _startMusic();

    // Generate floating sparks
    for (int i = 0; i < 18; i++) {
      _sparks.add(_Spark(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 4 + 1.5,
        speed: _rng.nextDouble() * 0.5 + 0.2,
        phase: _rng.nextDouble() * 2 * pi,
        opacity: _rng.nextDouble() * 0.55 + 0.15,
        color: _rng.nextBool()
            ? const Color(0xFFFFD700) // gold sparks
            : const Color(0xFF00C8FF), // cyan sparks
      ));
    }

    // Pre-generate lightning bolt paths
    for (int i = 0; i < 5; i++) {
      _bolts.add(_LightningBolt.random(_rng));
    }

    // ── Master entrance (2.5 s) ────────────────────────────────────
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // BG zooms in gently from slightly over-scale
    _bgScale = Tween(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _bgFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _overlayFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _taglineFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _loaderFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.78, 0.95, curve: Curves.easeOut),
      ),
    );

    // ── Pulse (logo glow ring) ──────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Float (subtle vertical bob) ────────────────────────────────
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _float = Tween(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // ── Lightning flicker ──────────────────────────────────────────
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    _lightning = Tween(begin: 0.0, end: 1.0).animate(_lightningController);

    // ── Shimmer sweep ──────────────────────────────────────────────
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _shimmer = Tween(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..forward();

    _loaderProgress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );

    _loaderController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _lightningController.dispose();
    _shimmerController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  Future<void> _startMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = GameSettings(prefs);
      await MusicManager().playBackgroundMusic(settings);
    } catch (e) {
      debugPrint('[SplashScreen] Error starting music: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF08083A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background image (zooms in on entrance) ─────────────
          AnimatedBuilder(
            animation: _masterController,
            builder: (_, __) => Opacity(
              opacity: _bgFade.value,
              child: Transform.scale(
                scale: _bgScale.value,
                child: Image.asset(
                  'lib/images/background.png',
                  fit: BoxFit.cover,
                  width: size.width,
                  height: size.height,
                ),
              ),
            ),
          ),

          // ── 2. Dark gradient overlay (bottom vignette) ─────────────
          AnimatedBuilder(
            animation: _overlayFade,
            builder: (_, __) => Opacity(
              opacity: _overlayFade.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF08083A).withOpacity(0.45),
                      const Color(0xFF08083A).withOpacity(0.82),
                    ],
                    stops: const [0.0, 0.60, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Animated lightning bolts ────────────────────────────
          AnimatedBuilder(
            animation: _lightning,
            builder: (_, __) {
              final t = _lightningController.value;
              return CustomPaint(
                painter: _LightningPainter(
                  bolts: _bolts,
                  progress: t,
                ),
                size: size,
              );
            },
          ),

          // ── 4. Floating sparks ─────────────────────────────────────
          ...List.generate(_sparks.length, (i) {
            final sp = _sparks[i];
            return AnimatedBuilder(
              animation: Listenable.merge([_floatController, _overlayFade]),
              builder: (_, __) {
                final yOff = sin(_floatController.value * 2 * pi + sp.phase) *
                    22 *
                    sp.speed;
                return Positioned(
                  left: sp.x * size.width,
                  top: sp.y * size.height + yOff,
                  child: Opacity(
                    opacity: sp.opacity * _overlayFade.value,
                    child: Container(
                      width: sp.size,
                      height: sp.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sp.color,
                        boxShadow: [
                          BoxShadow(
                            color: sp.color.withOpacity(0.7),
                            blurRadius: sp.size * 2.5,
                            spreadRadius: sp.size * 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // ── 5. Bottom content (tagline + loader) ───────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 52),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tagline
                    AnimatedBuilder(
                      animation: _masterController,
                      builder: (_, __) => FadeTransition(
                        opacity: _taglineFade,
                        child: SlideTransition(
                          position: _taglineSlide,
                          child: Column(
                            children: [
                              // Decorative divider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDividerLine(),
                                  const SizedBox(width: 12),
                                  AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (_, __) => ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
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
                                      ).createShader(bounds),
                                      child: Text(
                                        'ROCK · PAPER · SCISSORS',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 4,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildDividerLine(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Loader
                    AnimatedBuilder(
                      animation: _loaderFade,
                      builder: (_, __) => Opacity(
                        opacity: _loaderFade.value,
                        child: Column(
                          children: [
                            // Custom animated loader bar
                            _AnimatedLoaderBar(
                              progress: _loaderProgress,
                              shimmerController: _shimmerController,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'LOADING ARENA...',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 3.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerLine() {
    return Container(
      width: 28,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFD700).withOpacity(0.7),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated loading bar
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedLoaderBar extends StatelessWidget {
  const _AnimatedLoaderBar({
    required this.progress,
    required this.shimmerController,
  });

  final Animation<double> progress;
  final AnimationController shimmerController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([progress, shimmerController]),
      builder: (_, __) {
        return Container(
          width: 160,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Base fill
                FractionallySizedBox(
                  widthFactor: progress.value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF6A00)],
                      ),
                    ),
                  ),
                ),
                // Shimmer overlay
                FractionallySizedBox(
                  widthFactor:
                      (shimmerController.value * 0.4 + 0.1).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.35),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
