import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/morse/morse_codec.dart';
import 'features/history/data/datasources/history_local_data_source.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/add_history_entry.dart';
import 'features/history/domain/usecases/clear_history.dart';
import 'features/history/domain/usecases/delete_history_entry.dart';
import 'features/history/domain/usecases/get_history.dart';
import 'features/history/domain/usecases/toggle_favorite.dart';
import 'features/history/presentation/providers/history_provider.dart';
import 'features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/playback/data/datasources/haptic_device.dart';
import 'features/playback/data/datasources/output_settings_local_data_source.dart';
import 'features/playback/data/datasources/tone_player.dart';
import 'features/playback/data/repositories/output_settings_repository_impl.dart';
import 'features/playback/data/repositories/signal_output_repository_impl.dart';
import 'features/playback/domain/repositories/output_settings_repository.dart';
import 'features/playback/domain/repositories/signal_output_repository.dart';
import 'features/playback/domain/usecases/build_signal_timeline.dart';
import 'features/playback/domain/usecases/get_output_options.dart';
import 'features/playback/domain/usecases/save_output_options.dart';
import 'features/playback/presentation/providers/playback_provider.dart';
import 'features/reference/data/repositories/reference_repository_impl.dart';
import 'features/reference/domain/usecases/get_morse_entries.dart';
import 'features/reference/presentation/providers/reference_provider.dart';
import 'features/tap_keyer/domain/usecases/classify_press.dart';
import 'features/tap_keyer/presentation/providers/tap_provider.dart';
import 'features/translator/domain/usecases/translate.dart';
import 'features/translator/presentation/providers/translator_provider.dart';

class InjectionContainer {
  InjectionContainer({required SharedPreferences prefs, SignalOutputRepository? signalOutputRepository})
    : historyRepository = HistoryRepositoryImpl(HistoryLocalDataSourceImpl(prefs)),
      onboardingRepository = OnboardingRepositoryImpl(OnboardingLocalDataSourceImpl(prefs)),
      outputSettingsRepository = OutputSettingsRepositoryImpl(OutputSettingsLocalDataSourceImpl(prefs)),
      signalOutputRepository =
          signalOutputRepository ??
          SignalOutputRepositoryImpl(tonePlayer: AudioplayersTonePlayer(), hapticDevice: const VibrationHapticDevice());

  final MorseCodec codec = const MorseCodec();
  final HistoryRepository historyRepository;
  final OnboardingRepository onboardingRepository;
  final OutputSettingsRepository outputSettingsRepository;
  final SignalOutputRepository signalOutputRepository;

  List<SingleChildWidget> providers() {
    return [
      ChangeNotifierProvider<OnboardingProvider>(
        create: (_) => OnboardingProvider(
          checkOnboardingStatus: CheckOnboardingStatus(onboardingRepository),
          completeOnboarding: CompleteOnboarding(onboardingRepository),
        ),
      ),
      ChangeNotifierProvider<PlaybackProvider>(
        create: (_) => PlaybackProvider(
          buildTimeline: const BuildSignalTimeline(),
          output: signalOutputRepository,
          getOutputOptions: GetOutputOptions(outputSettingsRepository),
          saveOutputOptions: SaveOutputOptions(outputSettingsRepository),
        )..loadOptions(),
      ),
      ChangeNotifierProvider<TranslatorProvider>(
        create: (_) => TranslatorProvider(translate: Translate(codec), codec: codec),
      ),
      ChangeNotifierProvider<TapProvider>(
        create: (context) => TapProvider(
          codec: codec,
          classifyPress: const ClassifyPress(),
          wpm: () => context.read<PlaybackProvider>().options.wpm,
        ),
      ),
      ChangeNotifierProvider<ReferenceProvider>(
        create: (_) => ReferenceProvider(getMorseEntries: const GetMorseEntries(ReferenceRepositoryImpl())),
      ),
      ChangeNotifierProvider<HistoryProvider>(
        create: (_) => HistoryProvider(
          getHistory: GetHistory(historyRepository),
          addHistoryEntry: AddHistoryEntry(historyRepository),
          deleteHistoryEntry: DeleteHistoryEntry(historyRepository),
          toggleFavorite: ToggleFavorite(historyRepository),
          clearHistory: ClearHistory(historyRepository),
        )..load(),
      ),
    ];
  }
}
