import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob identifiers. The Android App ID itself lives in AndroidManifest.xml.
abstract final class AdIds {
  static const String rewardedAndroid = 'ca-app-pub-7665287068272825/9809859562';

  // Google's official test units. Debug and profile builds always use these
  // so real ads are never requested while developing (AdMob can suspend an
  // account for clicks on its own ads).
  static const String rewardedAndroidTest = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedIosTest = 'ca-app-pub-3940256099942544/1712485313';

  static String get rewarded {
    // The app ships on Android only; iOS has no real ad unit yet.
    if (Platform.isIOS) return rewardedIosTest;
    return kReleaseMode ? rewardedAndroid : rewardedAndroidTest;
  }
}
