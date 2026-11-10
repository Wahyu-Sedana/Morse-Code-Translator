import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/error/exceptions.dart';
import 'package:morse_translator/core/error/failures.dart';
import 'package:morse_translator/features/history/data/datasources/history_local_data_source.dart';
import 'package:morse_translator/features/history/data/models/history_entry_model.dart';
import 'package:morse_translator/features/history/data/repositories/history_repository_impl.dart';
import 'package:morse_translator/features/history/domain/entities/history_entry.dart';

import '../../../../fixtures/history_fixtures.dart';

class MockLocal extends Mock implements HistoryLocalDataSource {}

void main() {
  late MockLocal local;
  late HistoryRepositoryImpl repository;

  setUp(() {
    local = MockLocal();
    repository = HistoryRepositoryImpl(local, maxEntries: 3);
    when(() => local.writeAll(any())).thenAnswer((_) async {});
  });

  List<HistoryEntry> rightOf(Either<Failure, List<HistoryEntry>> result) =>
      result.getOrElse(() => throw StateError('expected Right'));

  List<HistoryEntryModel> written() =>
      verify(() => local.writeAll(captureAny())).captured.last as List<HistoryEntryModel>;

  test('getHistory returns stored entries', () async {
    when(() => local.readAll()).thenReturn([entry('1')]);

    expect(rightOf(await repository.getHistory()), [entry('1')]);
  });

  test('getHistory maps corruption to a cache failure', () async {
    when(() => local.readAll()).thenThrow(const CacheException('rusak'));

    expect(await repository.getHistory(), const Left<Failure, List<HistoryEntry>>(CacheFailure('rusak')));
  });

  test('addEntry puts the newest entry first', () async {
    when(() => local.readAll()).thenReturn([entry('1')]);

    final result = rightOf(await repository.addEntry(entry('2')));

    expect(result.map((e) => e.id), ['2', '1']);
    expect(written().map((e) => e.id), ['2', '1']);
  });

  test('addEntry trims old entries but keeps favorites', () async {
    when(() => local.readAll()).thenReturn([entry('3'), entry('2'), entry('1', favorite: true)]);

    final result = rightOf(await repository.addEntry(entry('4')));

    expect(result.map((e) => e.id), ['4', '3', '1']);
  });

  test('deleteEntry removes the matching entry', () async {
    when(() => local.readAll()).thenReturn([entry('2'), entry('1')]);

    final result = rightOf(await repository.deleteEntry('2'));

    expect(result.map((e) => e.id), ['1']);
  });

  test('toggleFavorite flips only the matching entry', () async {
    when(() => local.readAll()).thenReturn([entry('2'), entry('1')]);

    final result = rightOf(await repository.toggleFavorite('1'));

    expect(result.map((e) => e.isFavorite), [false, true]);
  });

  test('clearHistory writes an empty list', () async {
    expect(await repository.clearHistory(), const Right(unit));
    expect(written(), isEmpty);
  });

  test('write failures surface as cache failures', () async {
    when(() => local.readAll()).thenReturn([]);
    when(() => local.writeAll(any())).thenThrow(const CacheException('penuh'));

    expect(await repository.addEntry(entry('1')), const Left<Failure, List<HistoryEntry>>(CacheFailure('penuh')));
  });
}
