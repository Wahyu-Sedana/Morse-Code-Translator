import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../playback/presentation/providers/playback_provider.dart';
import '../../../playback/presentation/widgets/output_settings_sheet.dart';
import '../../../playback/presentation/widgets/playback_lamp.dart';
import '../../../playback/presentation/widgets/speed_control.dart';
import '../providers/translator_provider.dart';
import '../widgets/direction_switcher.dart';
import '../widgets/output_panel.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  static const String playbackKey = 'translator';

  /// Caps typed or pasted input so playback audio stays a reasonable size.
  static const int maxTextLength = 500;
  static const int maxMorseLength = 4000;

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(String input) {
    if (_controller.text == input) return;
    _controller.value = TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showMessage('Copied to clipboard');
  }

  Future<void> _save(TranslatorProvider translator) async {
    final translation = translator.translation;
    final ok = await context.read<HistoryProvider>().add(
      text: translation.plainText,
      morse: translation.morse,
      source: translation.direction.isTextToMorse ? HistorySource.textToMorse : HistorySource.morseToText,
    );
    if (mounted) _showMessage(ok ? 'Saved to history' : 'Could not save');
  }

  @override
  Widget build(BuildContext context) {
    final translator = context.watch<TranslatorProvider>();
    final playback = context.read<PlaybackProvider>();
    final translation = translator.translation;
    final isTextToMorse = translator.direction.isTextToMorse;
    final maxLength = isTextToMorse ? TranslatorPage.maxTextLength : TranslatorPage.maxMorseLength;
    final isPlaying = context.select<PlaybackProvider, bool>((p) => p.isPlayingKey(TranslatorPage.playbackKey));
    _syncController(translator.input);

    return Column(
      children: [
        ScreenHeader(
          eyebrow: '\u2212 \u00B7 \u2212\u00B7\u00B7\u2212 \u2212',
          title: 'Morse Translator',
          trailing: SquareIconButton(
            icon: Icons.tune_rounded,
            tooltip: 'Output settings',
            radius: 22,
            bordered: true,
            onPressed: () => OutputSettingsSheet.show(context),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 520;
              final outputPanel = OutputPanel(
                label: isTextToMorse ? 'Morse code' : 'Text',
                output: isTextToMorse ? translation.output : translator.displayOutput,
                isMorse: isTextToMorse,
                lamp: const PlaybackLamp(playbackKey: TranslatorPage.playbackKey),
                isPlaying: isPlaying,
                onPlay: translation.morse.isEmpty
                    ? null
                    : () => playback.toggle(translation.morse, key: TranslatorPage.playbackKey),
                onCopy: translation.isEmpty ? null : () => _copy(translation.output),
                onSave: translation.isEmpty ? null : () => _save(translator),
              );
              final children = <Widget>[
                DirectionSwitcher(
                  direction: translator.direction,
                  onSwap: () {
                    playback.stop();
                    translator.swapDirection();
                  },
                ),
                const SizedBox(height: 14),
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(18, 8, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(isTextToMorse ? 'Text' : 'Morse code', style: AppText.label)),
                          TextButton(
                            onPressed: translator.input.isEmpty
                                ? null
                                : () {
                                    playback.stop();
                                    translator.clear();
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.muted,
                              minimumSize: const Size(44, 36),
                            ),
                            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _controller,
                        onChanged: translator.updateInput,
                        minLines: 3,
                        maxLines: 3,
                        keyboardType: isTextToMorse ? TextInputType.multiline : TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(maxLength),
                          if (!isTextToMorse) FilteringTextInputFormatter.allow(RegExp('[.\\-/ \u00B7\u2212_]')),
                        ],
                        style: isTextToMorse
                            ? const TextStyle(fontSize: 22, height: 1.35, color: AppColors.ink)
                            : AppText.morse.copyWith(fontSize: 20, color: AppColors.ink),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: isTextToMorse ? 'Type a message here' : 'Example: .... .- .-.. ---',
                          hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            '${translator.input.length} / $maxLength characters',
                            style: const TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (compact) SizedBox(height: 240, child: outputPanel) else Expanded(child: outputPanel),
                const SizedBox(height: 14),
                const SpeedControl(),
              ];
              final column = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: compact ? SingleChildScrollView(child: column) : column,
              );
            },
          ),
        ),
      ],
    );
  }
}
