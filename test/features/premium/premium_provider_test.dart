import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/premium/data/datasources/premium_local_data_source.dart';
import 'package:morse_translator/features/premium/presentation/providers/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fake_ad_service.dart';

class MemoryPremiumStore implements PremiumLocalDataSource {
  MemoryPremiumStore([this.until]);

  DateTime? until;

  @override
  DateTime? readUnlockedUntil() => until;

  @override
  Future<void> writeUnlockedUntil(DateTime value) async => until = value;
}

void main() {
  final start = DateTime(2026, 11, 12, 9);

  test('starts locked and unlocks for 24 hours after a watched ad', () async {
    final store = MemoryPremiumStore();
    final ads = FakeAdService();
    final premium = PremiumProvider(store: store, ads: ads, clock: () => start);

    expect(premium.isUnlocked, isFalse);

    expect(await premium.watchAdToUnlock(), isTrue);

    expect(premium.isUnlocked, isTrue);
    expect(premium.remaining, const Duration(hours: 24));
    expect(store.until, start.add(const Duration(hours: 24)));
    premium.dispose();
  });

  test('stays locked when the video is skipped before the reward', () async {
    final premium = PremiumProvider(
      store: MemoryPremiumStore(),
      ads: FakeAdService(earnReward: false),
      clock: () => start,
    );

    expect(await premium.watchAdToUnlock(), isFalse);
    expect(premium.isUnlocked, isFalse);
    premium.dispose();
  });

  test('stays locked when no video is available', () async {
    final ads = FakeAdService(ready: false);
    final premium = PremiumProvider(store: MemoryPremiumStore(), ads: ads, clock: () => start);

    expect(premium.isAdReady, isFalse);
    expect(await premium.watchAdToUnlock(), isFalse);
    expect(ads.shows, 0);
    premium.dispose();
  });

  test('restores an unlock saved earlier and expires it on time', () {
    fakeAsync((async) {
      var now = start;
      final premium = PremiumProvider(
        store: MemoryPremiumStore(start.add(const Duration(hours: 2))),
        ads: FakeAdService(),
        clock: () => now,
      );
      var notified = 0;
      premium.addListener(() => notified++);

      expect(premium.isUnlocked, isTrue);

      now = start.add(const Duration(hours: 2));
      async.elapse(const Duration(hours: 2));

      expect(premium.isUnlocked, isFalse);
      expect(notified, greaterThan(0));
      premium.dispose();
    });
  });

  test('persists the unlock in shared preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = PremiumLocalDataSourceImpl(prefs);
    final until = DateTime.fromMillisecondsSinceEpoch(start.millisecondsSinceEpoch);

    await store.writeUnlockedUntil(until);

    expect(PremiumLocalDataSourceImpl(prefs).readUnlockedUntil(), until);
  });

  test('formats the remaining time', () {
    expect(formatRemaining(const Duration(hours: 23, minutes: 41)), '23h 41m left');
    expect(formatRemaining(const Duration(minutes: 41)), '41m left');
    expect(formatRemaining(const Duration(seconds: 20)), 'less than a minute left');
  });
}
