import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/app/app.dart';
import 'package:morse_translator/core/widgets/morse_signal.dart';
import 'package:morse_translator/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:morse_translator/features/playback/domain/entities/signal_pulse.dart';
import 'package:morse_translator/features/playback/domain/repositories/signal_output_repository.dart';
import 'package:morse_translator/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSignalOutput implements SignalOutputRepository {
  int plays = 0;

  @override
  Future<void> play(List<SignalPulse> timeline, {required bool sound, required bool vibration}) async => plays++;

  @override
  Future<void> stop() async {}
}

void main() {
  Future<FakeSignalOutput> launch(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final output = FakeSignalOutput();
    final container = InjectionContainer(prefs: await SharedPreferences.getInstance(), signalOutputRepository: output);
    await tester.pumpWidget(MultiProvider(providers: container.providers(), child: const MorseApp()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    return output;
  }

  testWidgets('first launch shows onboarding and finishes into the translator', (tester) async {
    await launch(tester);

    expect(find.text('Text to signal in an instant'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Tap the signal yourself'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Morse Translator'), findsOneWidget);
  });

  testWidgets('returning users skip onboarding', (tester) async {
    await launch(tester, prefs: {OnboardingLocalDataSourceImpl.completedKey: true});

    expect(find.text('Morse Translator'), findsOneWidget);
  });

  testWidgets('typing translates, plays and saves to history', (tester) async {
    final output = await launch(tester, prefs: {OnboardingLocalDataSourceImpl.completedKey: true});

    await tester.enterText(find.byType(TextField).first, 'sos');
    await tester.pump();
    expect(find.byWidgetPredicate((w) => w is MorseSignal && w.code == '... --- ...'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(output.plays, 1);
    await tester.pump(const Duration(seconds: 5));

    await tester.tap(find.byTooltip('Save to history').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('SOS'), findsOneWidget);
  });

  testWidgets('tap keyer decodes manual symbols', (tester) async {
    await launch(tester, prefs: {OnboardingLocalDataSourceImpl.completedKey: true});

    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dot'));
    await tester.tap(find.text('Dash'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('all tabs render on a small phone without overflow', (tester) async {
    await launch(tester, prefs: {OnboardingLocalDataSourceImpl.completedKey: true}, size: const Size(360, 640));
    expect(tester.takeException(), isNull, reason: 'Initial Translate tab');

    for (final tab in ['Tap', 'Alphabet', 'History', 'Translate']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('onboarding renders on a small phone without overflow', (tester) async {
    await launch(tester, size: const Size(360, 640));

    expect(tester.takeException(), isNull);
  });
}
