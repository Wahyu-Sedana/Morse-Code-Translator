import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/error/failures.dart';
import 'package:morse_translator/core/usecase/usecase.dart';
import 'package:morse_translator/features/history/domain/entities/history_entry.dart';
import 'package:morse_translator/features/history/domain/usecases/add_history_entry.dart';
import 'package:morse_translator/features/history/domain/usecases/clear_history.dart';
import 'package:morse_translator/features/history/domain/usecases/delete_history_entry.dart';
import 'package:morse_translator/features/history/domain/usecases/get_history.dart';
import 'package:morse_translator/features/history/domain/usecases/toggle_favorite.dart';
import 'package:morse_translator/features/history/presentation/providers/history_provider.dart';

import '../../../../fixtures/history_fixtures.dart';

class MockGetHistory extends Mock implements GetHistory {}

class MockAddHistoryEntry extends Mock implements AddHistoryEntry {}

class MockDeleteHistoryEntry extends Mock implements DeleteHistoryEntry {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockClearHistory extends Mock implements ClearHistory {}

void main() {
  late MockGetHistory getHistory;
  late MockAddHistoryEntry addEntry;
  late MockDeleteHistoryEntry deleteEntry;
  late MockToggleFavorite toggleFavorite;
  late MockClearHistory clearHistory;
  late HistoryProvider provider;

  final sample = <HistoryEntry>[
    entry('3', text: 'TERIMA KASIH', source: HistorySource.morseToText),
    entry('2', text: 'SELAMAT PAGI', source: HistorySource.tap, favorite: true),
    entry('1', text: 'SOS'),
  ];

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(entry('fallback'));
  });

  setUp(() {
    getHistory = MockGetHistory();
    addEntry = MockAddHistoryEntry();
    deleteEntry = MockDeleteHistoryEntry();
    toggleFavorite = MockToggleFavorite();
    clearHistory = MockClearHistory();
    provider = HistoryProvider(
      getHistory: getHistory,
      addHistoryEntry: addEntry,
      deleteHistoryEntry: deleteEntry,
      toggleFavorite: toggleFavorite,
      clearHistory: clearHistory,
      clock: () => fixedNow,
      idGenerator: () => 'new-id',
    );
  });

  test('load fills entries and clears loading', () async {
    when(() => getHistory(any())).thenAnswer((_) async => Right(sample));

    final future = provider.load();
    expect(provider.isLoading, isTrue);
    await future;

    expect(provider.isLoading, isFalse);
    expect(provider.entries, sample);
    expect(provider.errorMessage, isNull);
  });

  test('load exposes the failure message', () async {
    when(() => getHistory(any())).thenAnswer((_) async => const Left(CacheFailure('rusak')));

    await provider.load();

    expect(provider.errorMessage, 'rusak');
    expect(provider.entries, isEmpty);
  });

  group('visible entries', () {
    setUp(() async {
      when(() => getHistory(any())).thenAnswer((_) async => Right(sample));
      await provider.load();
    });

    test('favorites filter keeps starred entries only', () {
      provider.setFilter(HistoryFilter.favorites);

      expect(provider.visibleEntries.map((e) => e.id), ['2']);
    });

    test('tap filter keeps entries created by tapping', () {
      provider.setFilter(HistoryFilter.tap);

      expect(provider.visibleEntries.map((e) => e.id), ['2']);
    });

    test('query matches text case insensitively', () {
      provider.setQuery('terima');

      expect(provider.visibleEntries.map((e) => e.id), ['3']);
    });
  });

  test('add builds an entry from the clock and id generator', () async {
    when(() => addEntry(any())).thenAnswer((_) async => Right(sample));

    final ok = await provider.add(text: ' sos ', morse: '... --- ...', source: HistorySource.textToMorse);

    expect(ok, isTrue);
    final saved = verify(() => addEntry(captureAny())).captured.single as HistoryEntry;
    expect(saved.id, 'new-id');
    expect(saved.text, 'SOS');
    expect(saved.createdAt, fixedNow);
    expect(saved.isFavorite, isFalse);
    expect(provider.entries, sample);
  });

  test('add rejects blank morse without touching storage', () async {
    final ok = await provider.add(text: '', morse: '  ', source: HistorySource.tap);

    expect(ok, isFalse);
    verifyNever(() => addEntry(any()));
  });

  test('add reports failure', () async {
    when(() => addEntry(any())).thenAnswer((_) async => const Left(CacheFailure('penuh')));

    final ok = await provider.add(text: 'A', morse: '.-', source: HistorySource.tap);

    expect(ok, isFalse);
    expect(provider.errorMessage, 'penuh');
  });

  test('delete, toggle and clear update entries', () async {
    when(() => deleteEntry('1')).thenAnswer((_) async => Right(sample.take(2).toList()));
    when(() => toggleFavorite('3')).thenAnswer((_) async => Right(sample.take(1).toList()));
    when(() => clearHistory(any())).thenAnswer((_) async => const Right(unit));

    await provider.delete('1');
    expect(provider.entries.length, 2);

    await provider.toggleFavorite('3');
    expect(provider.entries.length, 1);

    await provider.clear();
    expect(provider.entries, isEmpty);
  });
}
