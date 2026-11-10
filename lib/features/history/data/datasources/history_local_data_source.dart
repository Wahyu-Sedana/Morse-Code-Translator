import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/history_entry_model.dart';

abstract class HistoryLocalDataSource {
  List<HistoryEntryModel> readAll();

  Future<void> writeAll(List<HistoryEntryModel> entries);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  HistoryLocalDataSourceImpl(this._prefs);

  static const String storageKey = 'history_entries';

  final SharedPreferences _prefs;

  @override
  List<HistoryEntryModel> readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => HistoryEntryModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      throw const CacheException('History data is corrupted');
    }
  }

  @override
  Future<void> writeAll(List<HistoryEntryModel> entries) async {
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    final ok = await _prefs.setString(storageKey, encoded);
    if (!ok) throw const CacheException('Could not save history');
  }
}
