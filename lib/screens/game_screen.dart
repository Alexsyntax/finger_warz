import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';
import '../widgets/hand_widget.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'opponent_selection_screen.dart';

enum Move { rock, paper, scissors }

enum RoundResult { win, lose, draw }

class GameScreen extends StatefulWidget {
  final String playerName;
  final GameMode gameMode;
  final String? opponentName;
  final GameSettings settings;

  const GameScreen({
    super.key,
    required this.playerName,
    required this.gameMode,
    this.opponentName,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Gold accent — matches splash screen shimmer/loader/spark color
  static const Color _gold = Color(0xFFFFD700);

  late int _winTarget;
  int _player1Score = 0;
  int _player2Score = 0;
  int _draws = 0;
  int _round = 0;

  Move? _player1Move;
  Move? _player2Move;
  RoundResult? _lastResult;
  bool _gameOver = false;
  String _resultMessage = '';
  String _resultEmoji = '';
  bool _isPlayer1Turn = true;
  bool _bothPlayersSelected = false;

  late AnimationController _resultAnimController;
  late Animation<double> _resultScaleAnim;
  late AnimationController _gameOverAnimController;
  late Animation<double> _gameOverFadeAnim;
  late Animation<double> _gameOverSlideAnim;

  late AnimationController _progressAnimController;
  late Animation<double> _p1ProgressAnim;
  late Animation<double> _p2ProgressAnim;

  // Lightning
  late AnimationController _lightningController;
  late Animation<double> _lightningAnim;
  final List<_LightningBolt> _bolts = [];

  @override
  void initState() {
    super.initState();
    _winTarget = widget.settings.winTarget;

    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _resultScaleAnim = CurvedAnimation(
        parent: _resultAnimController, curve: Curves.easeOutBack);

    _gameOverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _gameOverFadeAnim =
        CurvedAnimation(parent: _gameOverAnimController, curve: Curves.easeOut);
    _gameOverSlideAnim = Tween<double>(begin: 80, end: 0).animate(
        CurvedAnimation(
            parent: _gameOverAnimController, curve: Curves.easeOutCubic));

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _p1ProgressAnim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
        parent: _progressAnimController, curve: Curves.easeOutCubic));
    _p2ProgressAnim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
        parent: _progressAnimController, curve: Curves.easeOutCubic));

    // Lightning
    final rng = Random();
    for (int i = 0; i < 5; i++) {
      _bolts.add(_LightningBolt.random(rng));
    }
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _lightningAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_lightningController);

    _pauseMusic();
  }

  void _animateProgress() {
    final p1 = _player1Score / _winTarget;
    final p2 = _player2Score / _winTarget;
    _p1ProgressAnim =
        Tween<double>(begin: _p1ProgressAnim.value, end: p1.clamp(0.0, 1.0))
            .animate(CurvedAnimation(
                parent: _progressAnimController, curve: Curves.easeOutCubic));
    _p2ProgressAnim =
        Tween<double>(begin: _p2ProgressAnim.value, end: p2.clamp(0.0, 1.0))
            .animate(CurvedAnimation(
                parent: _progressAnimController, curve: Curves.easeOutCubic));
    _progressAnimController.forward(from: 0);
  }

  Future<void> _pauseMusic() async {
    final musicManager = MusicManager();
    await musicManager.pause();
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    _gameOverAnimController.dispose();
    _progressAnimController.dispose();
    _lightningController.dispose();
    _resumeMusic();
    super.dispose();
  }

  Future<void> _resumeMusic() async {
    final musicManager = MusicManager();
    await musicManager.resume();
  }

  // ── EXIT CONFIRMATION DIALOG ────────────────────────────────────────────
  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D2B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header band ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(27)),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFBBF24).withOpacity(0.28)),
                      ),
                      child: const Center(
                        child: Text('⚠️', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUIT MATCH?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.90),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _round == 0
                                ? 'The match hasn\'t started yet.'
                                : 'Round $_round in progress.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Text(
                  _round == 0
                      ? 'Your progress will be lost if you leave now.'
                      : 'All progress will be lost. Are you sure you want to surrender and exit?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.45),
                    height: 1.5,
                  ),
                ),
              ),

              // ── Score snapshot (only show if game started) ──
              if (_round > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _dialogStatCell(
                          widget.playerName,
                          '$_player1Score',
                          _gold,
                        ),
                        Text(
                          '—',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.15),
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                        _dialogStatCell(
                          _getOpponentName(),
                          '$_player2Score',
                          _isAIMode() ? Colors.white.withOpacity(0.45) : _gold,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Buttons ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FWButton(
                        label: 'KEEP PLAYING',
                        icon: Icons.sports_esports_rounded,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC8181).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFC8181).withOpacity(0.30),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.exit_to_app_rounded,
                                  size: 18,
                                  color: const Color(0xFFFC8181)
                                      .withOpacity(0.80)),
                              const SizedBox(width: 8),
                              Text(
                                'SURRENDER & EXIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color:
                                      const Color(0xFFFC8181).withOpacity(0.80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Widget _dialogStatCell(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.length > 8 ? '${label.substring(0, 8)}…' : label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white.withOpacity(0.28),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _triggerGameOver() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _gameOverAnimController.forward(from: 0);
    });
  }

  void _playAI(Move playerMove) {
    if (_gameOver) return;
    final aiMove = Move.values[Random().nextInt(3)];
    final result = _evaluate(playerMove, aiMove);

    setState(() {
      _player1Move = playerMove;
      _player2Move = aiMove;
      _lastResult = result;
      _round++;
      switch (result) {
        case RoundResult.win:
          _player1Score++;
          _resultMessage = 'YOU WIN THIS ROUND!';
          _resultEmoji = '🏆';
          break;
        case RoundResult.lose:
          _player2Score++;
          _resultMessage = '${_getOpponentName()} WINS!';
          _resultEmoji = '🤖';
          break;
        case RoundResult.draw:
          _draws++;
          _resultMessage = "IT'S A DRAW";
          _resultEmoji = '🤝';
          break;
      }
      if (_player1Score >= _winTarget || _player2Score >= _winTarget) {
        _gameOver = true;
      }
    });

    _resultAnimController.forward(from: 0);
    _animateProgress();
    if (_gameOver) _triggerGameOver();
  }

  void _playLocal(Move playerMove) {
    if (_gameOver) return;

    if (_isPlayer1Turn) {
      setState(() {
        _player1Move = playerMove;
        _isPlayer1Turn = false;
        _bothPlayersSelected = false;
        _lastResult = null;
      });
    } else {
      _player2Move = playerMove;
      final result = _evaluate(_player1Move!, _player2Move!);

      setState(() {
        _lastResult = result;
        _bothPlayersSelected = true;
        _round++;
        switch (result) {
          case RoundResult.win:
            _player1Score++;
            _resultMessage = '${widget.playerName.toUpperCase()} WINS!';
            _resultEmoji = '🏆';
            break;
          case RoundResult.lose:
            _player2Score++;
            _resultMessage = '${_getOpponentName().toUpperCase()} WINS!';
            _resultEmoji = '🏆';
            break;
          case RoundResult.draw:
            _draws++;
            _resultMessage = "IT'S A DRAW";
            _resultEmoji = '🤝';
            break;
        }
        if (_player1Score >= _winTarget || _player2Score >= _winTarget) {
          _gameOver = true;
        }
      });

      _resultAnimController.forward(from: 0);
      _animateProgress();
      if (_gameOver) _triggerGameOver();
    }
  }

  RoundResult _evaluate(Move p1, Move p2) {
    if (p1 == p2) return RoundResult.draw;
    if ((p1 == Move.rock && p2 == Move.scissors) ||
        (p1 == Move.paper && p2 == Move.rock) ||
        (p1 == Move.scissors && p2 == Move.paper)) return RoundResult.win;
    return RoundResult.lose;
  }

  void _resetGame() {
    _gameOverAnimController.reset();
    _progressAnimController.reset();
    _p1ProgressAnim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
        parent: _progressAnimController, curve: Curves.easeOutCubic));
    _p2ProgressAnim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
        parent: _progressAnimController, curve: Curves.easeOutCubic));
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _draws = 0;
      _round = 0;
      _player1Move = null;
      _player2Move = null;
      _lastResult = null;
      _gameOver = false;
      _resultMessage = '';
      _resultEmoji = '';
      _isPlayer1Turn = true;
      _bothPlayersSelected = false;
    });
  }

  void _resetRound() {
    setState(() {
      _player1Move = null;
      _player2Move = null;
      _lastResult = null;
      _isPlayer1Turn = true;
      _bothPlayersSelected = false;
    });
  }

  String _getOpponentName() => widget.gameMode == GameMode.local
      ? (widget.opponentName ?? 'Player 2')
      : 'A.I.';

  bool _isAIMode() => widget.gameMode == GameMode.ai;
  bool _isLocalMode() => widget.gameMode == GameMode.local;

  HandGesture? _moveToHandGesture(Move? m) {
    if (m == null) return null;
    switch (m) {
      case Move.rock:
        return HandGesture.rock;
      case Move.paper:
        return HandGesture.paper;
      case Move.scissors:
        return HandGesture.scissors;
    }
  }

  String _moveName(Move m) {
    switch (m) {
      case Move.rock:
        return 'ROCK';
      case Move.paper:
        return 'PAPER';
      case Move.scissors:
        return 'SCISSORS';
    }
  }

  Color _resultColor() {
    switch (_lastResult) {
      case RoundResult.win:
        return const Color(0xFF34D399);
      case RoundResult.lose:
        return const Color(0xFFFC8181);
      case RoundResult.draw:
        return const Color(0xFFFBBF24);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer1Winner = _player1Score >= _winTarget;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // ── Deep navy — matches splash screen background ──
        backgroundColor: const Color(0xFF08083A),
        body: Stack(
          children: [
            // Top glow — gold tint like splash sparks
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
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

            // Lightning bolts — same as splash screen
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _lightningAnim,
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
                  final maxWidth = min(constraints.maxWidth, 480.0);
                  final screenHeight = constraints.maxHeight;
                  final isCompact = screenHeight < 680;
                  final handSize =
                      (maxWidth * 0.18).clamp(60.0, 88.0).toDouble();
                  final moveHandSize =
                      (maxWidth * 0.175).clamp(66.0, 86.0).toDouble();

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _buildNavBar(),
                          ),
                          SizedBox(height: isCompact ? 12 : 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildArena(handSize, isCompact),
                          ),
                          SizedBox(height: isCompact ? 10 : 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildProgressBars(),
                          ),
                          SizedBox(height: isCompact ? 10 : 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildStatusArea(),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: _buildMoveSection(maxWidth, moveHandSize),
                          ),
                          SizedBox(height: isCompact ? 12 : 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_gameOver) _buildGameOverOverlay(isPlayer1Winner),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NAV BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNavBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final shouldExit = await _showExitConfirmation();
            if (shouldExit && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.white.withOpacity(0.6), size: 20),
          ),
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              '⚡ FINGER WARZ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: _gold.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isLocalMode()
                  ? (_isPlayer1Turn ? "P1's turn" : "P2's turn")
                  : 'Round $_round',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.28),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Win target badge — gold accent
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withOpacity(0.30)),
          ),
          child: Center(
            child: Text(
              '$_winTarget',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _gold,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ARENA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildArena(double handSize, bool isCompact) {
    final showBattle =
        _bothPlayersSelected || (_isAIMode() && _lastResult != null);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Row(
          children: [
            // ── Player 1 side — gold accent top border ──
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: isCompact ? 16 : 22, horizontal: 16),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.04),
                  border: Border(
                    top: BorderSide(
                      color: _gold.withOpacity(0.30),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withOpacity(0.35)),
                      ),
                      child: Text(
                        widget.playerName.length > 9
                            ? '${widget.playerName.substring(0, 9)}…'
                            : widget.playerName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _gold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    Text(
                      '$_player1Score',
                      style: TextStyle(
                        fontSize: isCompact ? 52 : 64,
                        fontWeight: FontWeight.w900,
                        color: _gold,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showBattle && _player1Move != null
                          ? Column(
                              key: ValueKey(_player1Move),
                              children: [
                                HandWidget(
                                    gesture: _moveToHandGesture(_player1Move),
                                    size: handSize),
                                const SizedBox(height: 4),
                                Text(
                                  _moveName(_player1Move!),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: _gold.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              key: const ValueKey('idle1'),
                              height: handSize + 20,
                              child: Center(
                                child: Icon(Icons.back_hand_rounded,
                                    size: handSize * 0.55,
                                    color: _gold.withOpacity(0.18)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // ── VS divider ──
            Container(
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border.symmetric(
                  vertical: BorderSide(
                      color: Colors.white.withOpacity(0.07), width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isCompact ? 16 : 22),
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.15),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_draws',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DRW',
                    style: TextStyle(
                      fontSize: 7,
                      letterSpacing: 1,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  SizedBox(height: isCompact ? 16 : 22),
                ],
              ),
            ),
            // ── Player 2 / AI side — unchanged muted style ──
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: isCompact ? 16 : 22, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Text(
                        _getOpponentName().length > 9
                            ? '${_getOpponentName().substring(0, 9)}…'
                            : _getOpponentName().toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white.withOpacity(0.55),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    Text(
                      '$_player2Score',
                      style: TextStyle(
                        fontSize: isCompact ? 52 : 64,
                        fontWeight: FontWeight.w900,
                        color: _isAIMode()
                            ? Colors.white.withOpacity(0.45)
                            : _gold,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showBattle && _player2Move != null
                          ? Column(
                              key: ValueKey(_player2Move),
                              children: [
                                HandWidget(
                                    gesture: _moveToHandGesture(_player2Move),
                                    size: handSize),
                                const SizedBox(height: 4),
                                Text(
                                  _moveName(_player2Move!),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white.withOpacity(0.40),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              key: const ValueKey('idle2'),
                              height: handSize + 20,
                              child: Center(
                                child: Icon(Icons.back_hand_rounded,
                                    size: handSize * 0.55,
                                    color: Colors.white.withOpacity(0.10)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROGRESS BARS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressBars() {
    return AnimatedBuilder(
      animation: _progressAnimController,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_player1Score}/$_winTarget',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _gold.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(
                            height: 5, color: Colors.white.withOpacity(0.06)),
                        FractionallySizedBox(
                          widthFactor: _p1ProgressAnim.value,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              // Gold gradient — matches splash loader bar
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF6A00)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_player2Score}/$_winTarget',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color:
                          (_isAIMode() ? Colors.white : _gold).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                            height: 5, color: Colors.white.withOpacity(0.06)),
                        FractionallySizedBox(
                          widthFactor: _p2ProgressAnim.value,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: _isAIMode()
                                  ? Colors.white.withOpacity(0.35)
                                  : _gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS AREA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatusArea() {
    if (_lastResult != null) {
      return ScaleTransition(
        scale: _resultScaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          decoration: BoxDecoration(
            color: _resultColor().withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _resultColor().withOpacity(0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_resultEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                _resultMessage,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: _resultColor(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLocalMode() && !_isPlayer1Turn && !_bothPlayersSelected) {
      return _buildPhonePassBanner();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Center(
        child: Text(
          _isLocalMode()
              ? "${widget.playerName.toUpperCase()}, MAKE YOUR MOVE"
              : 'TAP A MOVE TO PLAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white.withOpacity(0.18),
          ),
        ),
      ),
    );
  }

  Widget _buildPhonePassBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.22), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.phone_iphone_rounded, size: 20, color: _gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PASS THE PHONE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: _gold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getOpponentName()}, it\'s your turn. Keep it secret!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOVE SECTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMoveSection(double maxWidth, double handSize) {
    if (!_gameOver && _isLocalMode() && _bothPlayersSelected) {
      return FWButton(
        label: 'NEXT ROUND',
        icon: Icons.arrow_forward_rounded,
        onPressed: _resetRound,
      );
    }

    if (_gameOver) return const SizedBox.shrink();

    return _buildMoveButtons(maxWidth, handSize);
  }

  Widget _buildMoveButtons(double availableWidth, double handSize) {
    final moves = [
      (Move.rock, 'ROCK'),
      (Move.paper, 'PAPER'),
      (Move.scissors, 'SCISSORS'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            _isLocalMode() && !_isPlayer1Turn
                ? '${_getOpponentName().toUpperCase()} — PICK YOUR MOVE'
                : 'YOUR MOVE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: Colors.white.withOpacity(0.22),
            ),
          ),
        ),
        Row(
          children: moves.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                child: _buildMoveCard(m.$1, m.$2, handSize),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoveCard(Move move, String label, double handSize) {
    final isSelected = _isLocalMode()
        ? (_isPlayer1Turn ? _player1Move == move : _player2Move == move)
        : _player1Move == move;

    return GestureDetector(
      onTap: () => _isAIMode() ? _playAI(move) : _playLocal(move),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: isSelected
              ? _gold.withOpacity(0.10)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _gold.withOpacity(0.50)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HandWidget(gesture: _moveToHandGesture(move), size: handSize),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: isSelected ? _gold : Colors.white.withOpacity(0.30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GAME OVER OVERLAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGameOverOverlay(bool isPlayer1Winner) {
    final accentColor =
        isPlayer1Winner ? const Color(0xFF34D399) : const Color(0xFFFC8181);
    final winner = isPlayer1Winner ? widget.playerName : _getOpponentName();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _gameOverAnimController,
        builder: (context, child) => Opacity(
          opacity: _gameOverFadeAnim.value,
          child: child,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _gameOverAnimController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _gameOverSlideAnim.value),
                child: child,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D2B),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                        color: accentColor.withOpacity(0.28), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 48,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.07),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(31)),
                          border: Border(
                            bottom: BorderSide(
                                color: accentColor.withOpacity(0.12)),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: accentColor.withOpacity(0.25)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isPlayer1Winner ? '🏆' : '💀',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPlayer1Winner
                                            ? 'VICTORY!'
                                            : 'DEFEATED',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3,
                                          color: accentColor,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isPlayer1Winner
                                            ? '$winner takes the arena!'
                                            : '$winner dominated.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.40),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                        child: Row(
                          children: [
                            _buildStatCell(
                                widget.playerName, '$_player1Score', _gold),
                            _buildStatCell('DRAWS', '$_draws',
                                Colors.white.withOpacity(0.30)),
                            _buildStatCell(
                                _getOpponentName(),
                                '$_player2Score',
                                _isAIMode()
                                    ? Colors.white.withOpacity(0.40)
                                    : _gold),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$_round rounds played  ·  first to $_winTarget wins',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.22),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Column(
                          children: [
                            FWButton(
                              label: 'PLAY AGAIN',
                              icon: Icons.replay_rounded,
                              onPressed: _resetGame,
                            ),
                            const SizedBox(height: 10),
                            FWButton(
                              label: 'MAIN MENU',
                              icon: Icons.home_rounded,
                              filled: false,
                              onPressed: () =>
                                  Navigator.popUntil(context, (r) => r.isFirst),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.length > 8
                ? '${label.substring(0, 8)}…'
                : label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.28),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightning — ported directly from SplashScreen
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
