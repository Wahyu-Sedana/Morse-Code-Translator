import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Rewarded ads plus the consent flow they depend on.
abstract class AdService extends ChangeNotifier {
  bool get isRewardedReady;

  bool get isLoading;

  /// True when the user must be able to reopen the consent form (EEA, UK, CH).
  bool get privacyOptionsRequired;

  /// Gathers consent, starts the SDK and preloads a rewarded ad.
  Future<void> initialize();

  /// Shows the loaded rewarded ad. Completes with true only when the user
  /// watched long enough to earn the reward.
  Future<bool> showRewarded();

  /// Asks for a new ad, e.g. after "no video available".
  void reload();

  Future<void> showPrivacyOptions();
}

class AdMobAdService extends AdService {
  AdMobAdService({String? rewardedUnitId}) : _unitId = rewardedUnitId;

  final String? _unitId;
  RewardedAd? _ad;
  bool _loading = false;
  bool _canRequestAds = false;
  bool _sdkStarted = false;
  bool _privacyOptionsRequired = false;
  Future<void>? _initializing;
  Timer? _retry;

  String get _adUnitId => _unitId ?? AdIds.rewarded;

  @override
  bool get isRewardedReady => _ad != null;

  @override
  bool get isLoading => _loading;

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    await _gatherConsent();
    await _refreshConsentState();
    await _startSdkIfAllowed();
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) {
        if (!done.isCompleted) done.complete();
      }),
      (_) {
        // Offline or misconfigured: fall back to any consent given earlier.
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  Future<void> _refreshConsentState() async {
    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      _canRequestAds = false;
    }
    notifyListeners();
  }

  Future<void> _startSdkIfAllowed() async {
    if (!_canRequestAds || _sdkStarted) return;
    _sdkStarted = true;
    await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(maxAdContentRating: MaxAdContentRating.g));
    await MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (!_sdkStarted || _loading || _ad != null) return;
    _retry?.cancel();
    _loading = true;
    notifyListeners();
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          _loading = false;
          notifyListeners();
          _retry = Timer(const Duration(seconds: 30), _load);
        },
      ),
    );
  }

  @override
  void reload() {
    if (_initializing == null) {
      initialize();
      return;
    }
    _load();
  }

  @override
  Future<bool> showRewarded() {
    final ad = _ad;
    if (ad == null) {
      _load();
      return Future.value(false);
    }
    _ad = null;
    notifyListeners();

    final result = Completer<bool>();
    var earned = false;
    void finish() {
      ad.dispose();
      if (!result.isCompleted) result.complete(earned);
      _load();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, _) => finish(),
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }

  @override
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) {
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    await _refreshConsentState();
    await _startSdkIfAllowed();
  }

  @override
  void dispose() {
    _retry?.cancel();
    _ad?.dispose();
    super.dispose();
  }
}
