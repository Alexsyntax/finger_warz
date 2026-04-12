import 'dart:async';
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

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _loaderFade;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  Timer? _timer;

  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    // Start background music immediately when splash screen appears
    _startMusic();

    for (int i = 0; i < 14; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 5 + 2,
        speed: _rng.nextDouble() * 0.4 + 0.2,
        phase: _rng.nextDouble() * 2 * pi,
        opacity: _rng.nextDouble() * 0.2 + 0.04,
      ));
    }

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.45),
      ),
    );

    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.28, 0.55, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
      ),
    );

    _loaderFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.70, 0.90, curve: Curves.easeOut),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = Tween(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _float = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _timer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = GameSettings(prefs);
      final musicManager = MusicManager();
      print('[SplashScreen] Starting background music...');
      await musicManager.playBackgroundMusic(settings);
    } catch (e) {
      print('[SplashScreen] Error starting music: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final circleSize = (size.width * 0.28).clamp(100.0, 140.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0F),
      body: Stack(
        children: [
          // Radial glow
          AnimatedBuilder(
            animation: _logoFade,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.1,
                  colors: [
                    AppTheme.primary.withOpacity(0.16 * _logoFade.value),
                    const Color(0xFF0C0C0F),
                  ],
                ),
              ),
            ),
          ),

          // Particles
          ...List.generate(_particles.length, (i) {
            final p = _particles[i];
            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, __) {
                final yOffset = sin(_floatController.value * 2 * pi + p.phase) *
                    18 *
                    p.speed;
                return Positioned(
                  left: p.x * size.width,
                  top: p.y * size.height + yOffset,
                  child: AnimatedBuilder(
                    animation: _subtitleFade,
                    builder: (_, __) => Opacity(
                      opacity: p.opacity * _subtitleFade.value,
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating logo
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _masterController,
                      _pulseController,
                      _floatController,
                    ]),
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _float.value),
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring
                                Transform.scale(
                                  scale: _pulse.value,
                                  child: Container(
                                    width: circleSize,
                                    height: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            AppTheme.primary.withOpacity(0.20),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Icon circle
                                Container(
                                  width: circleSize * 0.78,
                                  height: circleSize * 0.78,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary.withOpacity(0.10),
                                    border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.45),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.back_hand_rounded,
                                    size: circleSize * 0.36,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Title: "FINGER" / "WARZ"
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            Text(
                              'FINGER',
                              style: TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primary.withOpacity(0.55),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'WARZ',
                                style: TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 10,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle with decorative lines
                  AnimatedBuilder(
                    animation: _subtitleFade,
                    builder: (_, __) => Opacity(
                      opacity: _subtitleFade.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 1,
                            color: AppTheme.primary.withOpacity(0.35),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rock · Paper · Scissors',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                              color: Colors.white.withOpacity(0.38),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 24,
                            height: 1,
                            color: AppTheme.primary.withOpacity(0.35),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 72),

                  // Loader
                  AnimatedBuilder(
                    animation: _loaderFade,
                    builder: (_, __) => Opacity(
                      opacity: _loaderFade.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primary.withOpacity(0.65),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'LOADING ARENA',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.25),
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
        ],
      ),
    );
  }
}

class _Particle {
  final double x, y, size, speed, phase, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}
