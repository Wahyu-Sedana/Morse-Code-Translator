import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/playback/data/datasources/output_settings_local_data_source.dart';
import 'package:morse_translator/features/playback/domain/entities/output_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns defaults when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final source = OutputSettingsLocalDataSourceImpl(await SharedPreferences.getInstance());

    expect(source.read(), const OutputOptions());
  });

  test('writes and reads back the options', () async {
    SharedPreferences.setMockInitialValues({});
    final source = OutputSettingsLocalDataSourceImpl(await SharedPreferences.getInstance());
    const options = OutputOptions(sound: false, light: true, vibration: true, wpm: 22);

    await source.write(options);

    expect(source.read(), options);
  });

  test('clamps an out of range stored speed', () async {
    SharedPreferences.setMockInitialValues({OutputSettingsLocalDataSourceImpl.wpmKey: 99});
    final source = OutputSettingsLocalDataSourceImpl(await SharedPreferences.getInstance());

    expect(source.read().wpm, OutputOptions.maxWpm);
  });
}
