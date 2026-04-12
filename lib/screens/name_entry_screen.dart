import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../widgets/fw_button.dart';
import '../services/game_settings.dart';
import '../services/music_manager.dart';
import 'opponent_selection_screen.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
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

  void _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final settings = GameSettings(prefs);

    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpponentSelectionScreen(
          playerName: name,
          settings: settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ✅ FIX: Override theme locally so the keyboard suggestion bar
      // does NOT inherit AppTheme.primary (yellow). Force it dark/neutral.
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.white, // cursor & selection handles → white
              secondary: Colors.white,
              surface: const Color(0xFF1A1A1F), // suggestion bar background
              onSurface: Colors.white,
            ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Color(0x44FFFFFF),
          selectionHandleColor: Colors.white,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0C0C0F),
        body: Stack(
          children: [
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          // ✅ removed maxHeight constraint — was clipping
                          // content and exposing decorated background behind
                          // the keyboard area
                          maxWidth: maxWidth,
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

                            const SizedBox(height: 20),

                            // Header
                            Text(
                              'WHO\nARE YOU?',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter your name to enter the arena.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.35),
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Name input card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                    width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PLAYER NAME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.5,
                                      color: AppTheme.primary.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _nameController,
                                    focusNode: _focusNode,
                                    autofocus: false,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    maxLength: 20,
                                    // ✅ FIX: dark keyboard avoids the yellow
                                    // system suggestion bar on Android
                                    keyboardAppearance: Brightness.dark,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.20),
                                        fontSize: 11,
                                      ),
                                      suffixIcon: _hasText
                                          ? GestureDetector(
                                              onTap: () =>
                                                  _nameController.clear(),
                                              child: Icon(
                                                Icons.cancel_rounded,
                                                color: Colors.white
                                                    .withOpacity(0.25),
                                                size: 18,
                                              ),
                                            )
                                          : null,
                                    ),
                                    onSubmitted: (_) => _continue(),
                                  ),
                                  Divider(
                                    color: _hasText
                                        ? AppTheme.primary.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.08),
                                    thickness: 1.5,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            AnimatedOpacity(
                              opacity: _hasText ? 1.0 : 0.35,
                              duration: const Duration(milliseconds: 200),
                              child: FWButton(
                                label: 'CONTINUE',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: _hasText ? _continue : () {},
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Decorative bottom label
                            Center(
                              child: Text(
                                '⚡ FINGER WARZ',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  color: Colors.white.withOpacity(0.12),
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
      ),
    );
  }
}
