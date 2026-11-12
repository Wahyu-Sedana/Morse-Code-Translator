import 'package:morse_translator/features/premium/data/services/ad_service.dart';

/// Rewarded ads without the AdMob SDK.
class FakeAdService extends AdService {
  FakeAdService({this.ready = true, this.earnReward = true, this.requiresPrivacyOptions = false});

  bool ready;
  bool earnReward;
  bool requiresPrivacyOptions;
  int shows = 0;
  int reloads = 0;
  int privacyFormShows = 0;

  @override
  bool get isRewardedReady => ready;

  @override
  bool get isLoading => false;

  @override
  bool get privacyOptionsRequired => requiresPrivacyOptions;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> showRewarded() async {
    if (!ready) return false;
    shows++;
    return earnReward;
  }

  @override
  void reload() => reloads++;

  @override
  Future<void> showPrivacyOptions() async => privacyFormShows++;
}
