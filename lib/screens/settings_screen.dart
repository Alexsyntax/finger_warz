import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _gold = Color(0xFFFFD700);

  late GameSettings _settings;
  bool _isLoading = true;

  late AnimationController _lightningController;
  final List<_LightningBolt> _bolts = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    final rng = Random();
    for (int i = 0; i < 5; i++) {
      _bolts.add(_LightningBolt.random(rng));
    }
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _lightningController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings = GameSettings(prefs);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF08083A),
        body: Center(
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08083A),
      body: Stack(
        children: [
          // Top glow
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
                    _gold.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Lightning bolts
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lightningController,
              builder: (_, __) => CustomPaint(
                painter: _LightningPainter(
                  bolts: _bolts,
                  progress: _lightningController.value,
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          // Header
                          Row(
                            children: [
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
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                '⚡ GAME SETTINGS',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: _gold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          _buildGameplaySection(),
                          const SizedBox(height: 24),
                          _buildAudioSection(),
                          const SizedBox(height: 24),
                          _buildActionsSection(),
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

  Widget _buildGameplaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_esports_rounded, color: _gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'GAMEPLAY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWinTargetSelector(),
          const SizedBox(height: 16),
          _buildAIDifficultySelector(),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volume_up_rounded, color: _gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AUDIO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingToggle(
            'Background Music',
            'Enable menu background music',
            Icons.audiotrack_rounded,
            _settings.musicEnabled,
            (value) async {
              setState(() => _settings.musicEnabled = value);
              final musicManager = MusicManager();
              if (value) {
                await musicManager.playBackgroundMusic(_settings);
              } else {
                await musicManager.stop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_rounded, color: _gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'ACTIONS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FWButton(
              label: 'RESET TO DEFAULTS',
              icon: Icons.restore_rounded,
              filled: false,
              onPressed: () async {
                await _settings.resetToDefaults();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: _gold,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinTargetSelector() {
    final targets = [3, 5, 7, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WIN TARGET',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'First player to reach this score wins',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.40),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: targets.map((target) {
            final isSelected = _settings.winTarget == target;
            return GestureDetector(
              onTap: () => setState(() => _settings.winTarget = target),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _gold.withOpacity(0.12)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _gold.withOpacity(0.50)
                        : Colors.white.withOpacity(0.10),
                  ),
                ),
                child: Text(
                  '$target',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _gold : Colors.white.withOpacity(0.60),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAIDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI DIFFICULTY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How smart the AI opponent plays',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.40),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: AIDifficulty.values.map((difficulty) {
            final isSelected = _settings.aiDifficulty == difficulty;
            return GestureDetector(
              onTap: () => setState(() => _settings.aiDifficulty = difficulty),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _gold.withOpacity(0.08)
                      : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _gold.withOpacity(0.35)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? _gold
                                  : Colors.white.withOpacity(0.80),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            difficulty.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.50),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _gold,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.50),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _gold,
              activeTrackColor: _gold.withOpacity(0.30),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightning — same as SplashScreen & GameScreen
// ─────────────────────────────────────────────────────────────────────────────

class _LightningBolt {
  final List<Offset> points;
  final double triggerPhase;
  final Color color;
  final double opacity;

  const _LightningBolt({
    required this.points,
    required this.triggerPhase,
    required this.color,
    required this.opacity,
  });

  factory _LightningBolt.random(Random rng) {
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
  final double progress;

  const _LightningPainter({required this.bolts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final bolt in bolts) {
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

      // Bright white core
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
