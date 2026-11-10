import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/error/exceptions.dart';
import 'package:morse_translator/core/error/failures.dart';
import 'package:morse_translator/features/playback/data/datasources/output_settings_local_data_source.dart';
import 'package:morse_translator/features/playback/data/repositories/output_settings_repository_impl.dart';
import 'package:morse_translator/features/playback/domain/entities/output_options.dart';

class MockLocal extends Mock implements OutputSettingsLocalDataSource {}

void main() {
  late MockLocal local;
  late OutputSettingsRepositoryImpl repository;
  const options = OutputOptions(wpm: 20);

  setUpAll(() => registerFallbackValue(const OutputOptions()));

  setUp(() {
    local = MockLocal();
    repository = OutputSettingsRepositoryImpl(local);
  });

  test('getOptions returns stored options', () async {
    when(() => local.read()).thenReturn(options);

    expect(await repository.getOptions(), const Right(options));
  });

  test('getOptions maps a cache exception to a failure', () async {
    when(() => local.read()).thenThrow(const CacheException('rusak'));

    expect(await repository.getOptions(), const Left(CacheFailure('rusak')));
  });

  test('saveOptions writes through the data source', () async {
    when(() => local.write(any())).thenAnswer((_) async {});

    expect(await repository.saveOptions(options), const Right(unit));
    verify(() => local.write(options)).called(1);
  });

  test('saveOptions maps a cache exception to a failure', () async {
    when(() => local.write(any())).thenThrow(const CacheException());

    expect(await repository.saveOptions(options), isA<Left<Failure, Unit>>());
  });
}
