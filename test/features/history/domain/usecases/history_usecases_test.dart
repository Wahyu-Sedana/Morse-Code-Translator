import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/usecase/usecase.dart';
import 'package:morse_translator/features/history/domain/entities/history_entry.dart';
import 'package:morse_translator/features/history/domain/repositories/history_repository.dart';
import 'package:morse_translator/features/history/domain/usecases/add_history_entry.dart';
import 'package:morse_translator/features/history/domain/usecases/clear_history.dart';
import 'package:morse_translator/features/history/domain/usecases/delete_history_entry.dart';
import 'package:morse_translator/features/history/domain/usecases/get_history.dart';
import 'package:morse_translator/features/history/domain/usecases/toggle_favorite.dart';

import '../../../../fixtures/history_fixtures.dart';

class MockRepository extends Mock implements HistoryRepository {}

void main() {
  late MockRepository repository;
  final List<HistoryEntry> list = [entry('1')];

  setUp(() => repository = MockRepository());

  test('GetHistory delegates to the repository', () async {
    when(() => repository.getHistory()).thenAnswer((_) async => Right(list));

    expect(await GetHistory(repository)(const NoParams()), Right<dynamic, List<HistoryEntry>>(list));
  });

  test('AddHistoryEntry delegates to the repository', () async {
    when(() => repository.addEntry(entry('1'))).thenAnswer((_) async => Right(list));

    await AddHistoryEntry(repository)(entry('1'));

    verify(() => repository.addEntry(entry('1'))).called(1);
  });

  test('DeleteHistoryEntry delegates to the repository', () async {
    when(() => repository.deleteEntry('1')).thenAnswer((_) async => const Right([]));

    await DeleteHistoryEntry(repository)('1');

    verify(() => repository.deleteEntry('1')).called(1);
  });

  test('ToggleFavorite delegates to the repository', () async {
    when(() => repository.toggleFavorite('1')).thenAnswer((_) async => Right(list));

    await ToggleFavorite(repository)('1');

    verify(() => repository.toggleFavorite('1')).called(1);
  });

  test('ClearHistory delegates to the repository', () async {
    when(() => repository.clearHistory()).thenAnswer((_) async => const Right(unit));

    expect(await ClearHistory(repository)(const NoParams()), const Right(unit));
  });
}
