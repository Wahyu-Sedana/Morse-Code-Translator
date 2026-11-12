import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/datasources/premium_local_data_source.dart';
import '../../data/services/ad_service.dart';

/// Premium features (flashlight, audio export) unlock for a limited time
/// after the user watches a rewarded ad.
class PremiumProvider extends ChangeNotifier {
  PremiumProvider({
    required PremiumLocalDataSource store,
    required AdService ads,
    DateTime Function()? clock,
    this.unlockDuration = const Duration(hours: 24),
  }) : _store = store,
       _ads = ads,
       _clock = clock ?? DateTime.now {
    _until = _store.readUnlockedUntil();
    _ads.addListener(notifyListeners);
    _scheduleExpiry();
  }

  final PremiumLocalDataSource _store;
  final AdService _ads;
  final DateTime Function() _clock;
  final Duration unlockDuration;

  DateTime? _until;
  bool _isShowingAd = false;
  Timer? _expiry;

  bool get isUnlocked {
    final until = _until;
    return until != null && _clock().isBefore(until);
  }

  Duration get remaining => isUnlocked ? _until!.difference(_clock()) : Duration.zero;

  bool get isAdReady => _ads.isRewardedReady;

  bool get isAdLoading => _ads.isLoading;

  bool get isShowingAd => _isShowingAd;

  bool get privacyOptionsRequired => _ads.privacyOptionsRequired;

  /// Shows a rewarded ad and unlocks premium when the reward is earned.
  Future<bool> watchAdToUnlock() async {
    if (_isShowingAd) return false;
    _isShowingAd = true;
    notifyListeners();
    var earned = false;
    try {
      earned = await _ads.showRewarded();
      if (earned) {
        _until = _clock().add(unlockDuration);
        await _store.writeUnlockedUntil(_until!);
        _scheduleExpiry();
      }
    } finally {
      _isShowingAd = false;
      notifyListeners();
    }
    return earned;
  }

  void reloadAd() => _ads.reload();

  Future<void> showPrivacyOptions() => _ads.showPrivacyOptions();

  void _scheduleExpiry() {
    _expiry?.cancel();
    if (isUnlocked) _expiry = Timer(remaining, notifyListeners);
  }

  @override
  void dispose() {
    _expiry?.cancel();
    _ads.removeListener(notifyListeners);
    super.dispose();
  }
}

/// "23h 41m left", "41m left", "less than a minute left".
String formatRemaining(Duration remaining) {
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m left';
  if (minutes > 0) return '${minutes}m left';
  return 'less than a minute left';
}
