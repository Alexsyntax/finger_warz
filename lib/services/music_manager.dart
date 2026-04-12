import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'game_settings.dart';

class MusicManager {
  static final MusicManager _instance = MusicManager._internal();

  static AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;

  factory MusicManager() {
    return _instance;
  }

  MusicManager._internal() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
      print('[MusicManager] AudioPlayer initialized');
    }
  }

  Future<void> playBackgroundMusic(GameSettings settings) async {
    if (!settings.musicEnabled) {
      print('[MusicManager] Music disabled in settings');
      return;
    }

    // Skip music on web - AudioPlayer AssetSource has issues on web platform
    if (kIsWeb) {
      print('[MusicManager] Skipping music on web platform');
      return;
    }

    if (_isPlaying) {
      print('[MusicManager] Music already playing');
      return;
    }

    try {
      _initAudioPlayer();
      print('[MusicManager] Starting background music...');
      print('[MusicManager] Platform: ${kIsWeb ? 'WEB' : 'NATIVE'}');

      if (_audioPlayer == null) {
        print('[MusicManager] ERROR: AudioPlayer is null!');
        return;
      }

      // Set volume to full
      await _audioPlayer!.setVolume(1.0);
      print('[MusicManager] Volume set to 1.0');

      // Set loop mode before playing
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      print('[MusicManager] Release mode set to loop');

      // Play the music
      print('[MusicManager] Attempting to play: music/background.mp3');

      try {
        await _audioPlayer!.play(AssetSource('music/background.mp3'));
        _isPlaying = true;
        _isPaused = false;
        print('[MusicManager] ✓ Background music playing');
      } catch (playError) {
        print('[MusicManager] play() error: $playError');

        // On web, autoplay might be blocked - just set flag and try again on interaction
        if (kIsWeb && playError.toString().contains('NotAllowedError')) {
          print(
              '[MusicManager] Web autoplay blocked - will retry on user interaction');
          _isPlaying = false;
        } else {
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      print('[MusicManager] Error: $e');
      print('[MusicManager] Stack: $stackTrace');
      _isPlaying = false;
    }
  }

  Future<void> pause() async {
    if (!_isPlaying) {
      print('[MusicManager] Music not playing, cannot pause');
      return;
    }

    try {
      _initAudioPlayer();
      print('[MusicManager] Pausing music...');
      await _audioPlayer?.pause();
      _isPaused = true;
      print('[MusicManager] ✓ Music paused');
    } catch (e) {
      print('[MusicManager] Error pausing: $e');
    }
  }

  Future<void> resume() async {
    if (!_isPlaying) {
      print('[MusicManager] Music not playing, cannot resume');
      return;
    }

    if (!_isPaused) {
      print('[MusicManager] Music already playing');
      return;
    }

    try {
      _initAudioPlayer();
      print('[MusicManager] Resuming music...');
      await _audioPlayer?.resume();
      _isPaused = false;
      print('[MusicManager] ✓ Music resumed');
    } catch (e) {
      print('[MusicManager] Error resuming: $e');
    }
  }

  Future<void> stop() async {
    try {
      _initAudioPlayer();
      print('[MusicManager] Stopping music...');
      await _audioPlayer?.stop();
      _isPlaying = false;
      _isPaused = false;
      print('[MusicManager] ✓ Music stopped');
    } catch (e) {
      print('[MusicManager] Error stopping: $e');
    }
  }

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
}
