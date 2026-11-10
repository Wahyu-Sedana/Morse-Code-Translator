import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/error/exceptions.dart';
import 'package:morse_translator/core/error/failures.dart';
import 'package:morse_translator/core/usecase/usecase.dart';
import 'package:morse_translator/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:morse_translator/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:morse_translator/features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'package:morse_translator/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:morse_translator/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocal extends Mock implements OnboardingLocalDataSource {}

class MockCheck extends Mock implements CheckOnboardingStatus {}

class MockComplete extends Mock implements CompleteOnboarding {}

void main() {
  group('local data source', () {
    test('is not completed by default and remembers completion', () async {
      SharedPreferences.setMockInitialValues({});
      final source = OnboardingLocalDataSourceImpl(await SharedPreferences.getInstance());

      expect(source.readCompleted(), isFalse);
      await source.writeCompleted();
      expect(source.readCompleted(), isTrue);
    });
  });

  group('repository', () {
    late MockLocal local;
    late OnboardingRepositoryImpl repository;

    setUp(() {
      local = MockLocal();
      repository = OnboardingRepositoryImpl(local);
    });

    test('isCompleted reads the flag', () async {
      when(() => local.readCompleted()).thenReturn(true);

      expect(await repository.isCompleted(), const Right(true));
    });

    test('markCompleted maps failures', () async {
      when(() => local.writeCompleted()).thenThrow(const CacheException('x'));

      expect(await repository.markCompleted(), const Left<Failure, Unit>(CacheFailure('x')));
    });
  });

  group('provider', () {
    late MockCheck check;
    late MockComplete complete;
    late OnboardingProvider provider;

    setUpAll(() => registerFallbackValue(const NoParams()));

    setUp(() {
      check = MockCheck();
      complete = MockComplete();
      provider = OnboardingProvider(checkOnboardingStatus: check, completeOnboarding: complete);
    });

    test('routes to home when onboarding was completed', () async {
      when(() => check(any())).thenAnswer((_) async => const Right(true));

      expect(await provider.resolveLaunch(), LaunchDestination.home);
    });

    test('routes to onboarding when not completed or on failure', () async {
      when(() => check(any())).thenAnswer((_) async => const Left(CacheFailure()));

      expect(await provider.resolveLaunch(), LaunchDestination.onboarding);
    });

    test('page index is clamped and tracks the last page', () {
      provider.setPage(5);

      expect(provider.page, 2);
      expect(provider.isLastPage, isTrue);
    });

    test('complete persists through the use case', () async {
      when(() => complete(any())).thenAnswer((_) async => const Right(unit));

      await provider.complete();

      verify(() => complete(const NoParams())).called(1);
    });
  });
}
