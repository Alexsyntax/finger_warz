import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  static const String _winTargetKey = 'win_target';
  static const String _aiDifficultyKey = 'ai_difficulty';
  static const String _musicEnabledKey = 'music_enabled';

  static const int defaultWinTarget = 5;
  static const bool defaultMusicEnabled = true;
  static const AIDifficulty defaultAIDifficulty = AIDifficulty.medium;

  final SharedPreferences _prefs;

  GameSettings(this._prefs);

  // Win target (first to X wins)
  int get winTarget => _prefs.getInt(_winTargetKey) ?? defaultWinTarget;
  set winTarget(int value) => _prefs.setInt(_winTargetKey, value);

  // AI difficulty
  AIDifficulty get aiDifficulty {
    final value = _prefs.getString(_aiDifficultyKey);
    return value != null
        ? AIDifficulty.values.firstWhere(
            (e) => e.name == value,
            orElse: () => defaultAIDifficulty,
          )
        : defaultAIDifficulty;
  }

  set aiDifficulty(AIDifficulty value) =>
      _prefs.setString(_aiDifficultyKey, value.name);

  // Background music
  bool get musicEnabled =>
      _prefs.getBool(_musicEnabledKey) ?? defaultMusicEnabled;
  set musicEnabled(bool value) => _prefs.setBool(_musicEnabledKey, value);

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await _prefs.setInt(_winTargetKey, defaultWinTarget);
    await _prefs.setBool(_musicEnabledKey, defaultMusicEnabled);
    await _prefs.setString(_aiDifficultyKey, defaultAIDifficulty.name);
  }
}

enum AIDifficulty {
  easy('Easy', 'AI makes more random moves'),
  medium('Medium', 'Balanced AI strategy'),
  hard('Hard', 'AI plays optimally');

  const AIDifficulty(this.displayName, this.description);
  final String displayName;
  final String description;
}
