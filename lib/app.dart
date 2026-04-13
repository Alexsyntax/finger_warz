import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/music_manager.dart';

class FingerWarzApp extends StatefulWidget {
  const FingerWarzApp({super.key});

  @override
  State<FingerWarzApp> createState() => _FingerWarzAppState();
}

class _FingerWarzAppState extends State<FingerWarzApp>
    with WidgetsBindingObserver {
  final MusicManager _musicManager = MusicManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // App is minimized or in background
      _musicManager.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App is back to foreground
      _musicManager.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger Warz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
