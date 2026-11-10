import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract class OnboardingLocalDataSource {
  bool readCompleted();

  Future<void> writeCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._prefs);

  static const String completedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  @override
  bool readCompleted() => _prefs.getBool(completedKey) ?? false;

  @override
  Future<void> writeCompleted() async {
    final ok = await _prefs.setBool(completedKey, true);
    if (!ok) throw const CacheException();
  }
}
