import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/fw_button.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'opponent_selection_screen.dart';
import 'rules_screen.dart';

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

class _Player2NameEntryScreenState extends State<Player2NameEntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final AnimationController _floatController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _shimmer;

  final List<_Spark> _sparks = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(
      () => setState(() => _hasText = _nameController.text.trim().isNotEmpty),
    );
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
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

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
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
    final size = MediaQuery.of(context).size;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.white,
              secondary: Colors.white,
              surface: const Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00C8FF),
          selectionColor: Color(0x3300C8FF),
          selectionHandleColor: Color(0xFF00C8FF),
        ),
      ),
      child: Scaffold(
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
                      // P2 gets a purple tint instead of cyan
                      const Color(0xFFB066FF).withOpacity(0.08),
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

            // ── Subtle sparks
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

            // ── Main content
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
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 16,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                              maxWidth: 450,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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

                                // P2 badge — purple accent to distinguish from P1
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFB066FF),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x66B066FF),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'PLAYER TWO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 3,
                                        color: Color(0xFFB066FF),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Title — "NAME?" shimmers purple
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "WHAT'S YOUR",
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
                                            Color(0xFFB066FF),
                                            Colors.white,
                                            Color(0xFFB066FF),
                                          ],
                                        ).createShader(b),
                                        child: const Text(
                                          'NAME?',
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
                                      'CHALLENGER INCOMING',
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

                                const SizedBox(height: 28),

                                // Input card — purple accent for P2
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _hasText
                                          ? const Color(0xFFB066FF)
                                              .withOpacity(0.30)
                                          : Colors.white.withOpacity(0.08),
                                      width: 1.5,
                                    ),
                                    boxShadow: _hasText
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFB066FF)
                                                  .withOpacity(0.08),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Top shimmer edge
                                      Positioned(
                                        top: -1,
                                        left: 24,
                                        right: 24,
                                        child: AnimatedBuilder(
                                          animation: _shimmerController,
                                          builder: (_, __) => ShaderMask(
                                            shaderCallback: (b) =>
                                                LinearGradient(
                                              stops: [
                                                (_shimmer.value - 0.4)
                                                    .clamp(0.0, 1.0),
                                                _shimmer.value.clamp(0.0, 1.0),
                                                (_shimmer.value + 0.4)
                                                    .clamp(0.0, 1.0),
                                              ],
                                              colors: const [
                                                Colors.transparent,
                                                Color(0xFFB066FF),
                                                Colors.transparent,
                                              ],
                                            ).createShader(b),
                                            child: Container(
                                              height: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 16, 20, 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PLAYER NAME',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 2.5,
                                                color: const Color(0xFFB066FF)
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: _nameController,
                                              focusNode: _focusNode,
                                              autofocus: false,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              maxLength: 15,
                                              keyboardAppearance:
                                                  Brightness.dark,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.5,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                counterText: '',
                                                hintText: 'your handle...',
                                                hintStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 1,
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                suffixIcon: _hasText
                                                    ? GestureDetector(
                                                        onTap: () =>
                                                            _nameController
                                                                .clear(),
                                                        child: Icon(
                                                          Icons.cancel_rounded,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.20),
                                                          size: 18,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              onSubmitted: (_) => _continue(),
                                            ),
                                            const SizedBox(height: 4),
                                            // Bottom line animates purple when active
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              height: 1.5,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: _hasText
                                                      ? [
                                                          Colors.transparent,
                                                          const Color(
                                                              0xFFB066FF),
                                                          Colors.transparent,
                                                        ]
                                                      : [
                                                          Colors.transparent,
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.10),
                                                          Colors.transparent,
                                                        ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                AnimatedOpacity(
                                  opacity: _hasText ? 1.0 : 0.30,
                                  duration: const Duration(milliseconds: 250),
                                  child: FWButton(
                                    label: 'CONTINUE',
                                    icon: Icons.arrow_forward_rounded,
                                    onPressed: _hasText ? _continue : () {},
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
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
            const Color(0xFFB066FF).withOpacity(0.40),
          ],
        ),
      ),
    );
  }
}

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
