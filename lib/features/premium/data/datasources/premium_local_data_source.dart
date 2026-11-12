import 'package:shared_preferences/shared_preferences.dart';

abstract class PremiumLocalDataSource {
  DateTime? readUnlockedUntil();

  Future<void> writeUnlockedUntil(DateTime until);
}

class PremiumLocalDataSourceImpl implements PremiumLocalDataSource {
  PremiumLocalDataSourceImpl(this._prefs);

  static const String unlockedUntilKey = 'premium_unlocked_until';

  final SharedPreferences _prefs;

  @override
  DateTime? readUnlockedUntil() {
    final millis = _prefs.getInt(unlockedUntilKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<void> writeUnlockedUntil(DateTime until) async {
    await _prefs.setInt(unlockedUntilKey, until.millisecondsSinceEpoch);
  }
}
