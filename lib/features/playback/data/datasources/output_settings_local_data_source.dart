import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/output_options.dart';

abstract class OutputSettingsLocalDataSource {
  OutputOptions read();

  Future<void> write(OutputOptions options);
}

class OutputSettingsLocalDataSourceImpl implements OutputSettingsLocalDataSource {
  OutputSettingsLocalDataSourceImpl(this._prefs);

  static const String soundKey = 'output_sound';
  static const String lightKey = 'output_light';
  static const String vibrationKey = 'output_vibration';
  static const String flashlightKey = 'output_flashlight';
  static const String wpmKey = 'output_wpm';

  final SharedPreferences _prefs;

  @override
  OutputOptions read() {
    const defaults = OutputOptions();
    return OutputOptions(
      sound: _prefs.getBool(soundKey) ?? defaults.sound,
      light: _prefs.getBool(lightKey) ?? defaults.light,
      vibration: _prefs.getBool(vibrationKey) ?? defaults.vibration,
      flashlight: _prefs.getBool(flashlightKey) ?? defaults.flashlight,
      wpm: (_prefs.getInt(wpmKey) ?? defaults.wpm).clamp(OutputOptions.minWpm, OutputOptions.maxWpm),
    );
  }

  @override
  Future<void> write(OutputOptions options) async {
    final results = await Future.wait([
      _prefs.setBool(soundKey, options.sound),
      _prefs.setBool(lightKey, options.light),
      _prefs.setBool(vibrationKey, options.vibration),
      _prefs.setBool(flashlightKey, options.flashlight),
      _prefs.setInt(wpmKey, options.wpm),
    ]);
    if (results.contains(false)) throw const CacheException();
  }
}
