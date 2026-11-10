import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/check_onboarding_status.dart';
import '../../domain/usecases/complete_onboarding.dart';

enum LaunchDestination { onboarding, home }

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    required CheckOnboardingStatus checkOnboardingStatus,
    required CompleteOnboarding completeOnboarding,
    this.pageCount = 3,
  }) : _checkOnboardingStatus = checkOnboardingStatus,
       _completeOnboarding = completeOnboarding;

  final CheckOnboardingStatus _checkOnboardingStatus;
  final CompleteOnboarding _completeOnboarding;
  final int pageCount;

  int _page = 0;

  int get page => _page;
  bool get isLastPage => _page == pageCount - 1;

  Future<LaunchDestination> resolveLaunch() async {
    final result = await _checkOnboardingStatus(const NoParams());
    final completed = result.getOrElse(() => false);
    return completed ? LaunchDestination.home : LaunchDestination.onboarding;
  }

  void setPage(int page) {
    final clamped = page.clamp(0, pageCount - 1);
    if (clamped == _page) return;
    _page = clamped;
    notifyListeners();
  }

  Future<void> complete() async {
    await _completeOnboarding(const NoParams());
  }
}
