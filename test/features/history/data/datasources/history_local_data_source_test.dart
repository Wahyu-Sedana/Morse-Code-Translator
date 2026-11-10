import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/error/exceptions.dart';
import 'package:morse_translator/features/history/data/datasources/history_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/history_fixtures.dart';

void main() {
  Future<HistoryLocalDataSourceImpl> sourceWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return HistoryLocalDataSourceImpl(await SharedPreferences.getInstance());
  }

  test('returns an empty list when nothing is stored', () async {
    final source = await sourceWith({});

    expect(source.readAll(), isEmpty);
  });

  test('persists and restores entries in order', () async {
    final source = await sourceWith({});
    final entries = [entry('2'), entry('1', favorite: true)];

    await source.writeAll(entries);

    expect(source.readAll(), entries);
  });

  test('throws a cache exception for corrupted data', () async {
    final source = await sourceWith({HistoryLocalDataSourceImpl.storageKey: 'not json'});

    expect(source.readAll, throwsA(isA<CacheException>()));
  });
}
