import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/morse_signal.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../playback/presentation/providers/playback_provider.dart';
import '../../../playback/presentation/widgets/playback_lamp.dart';
import '../../domain/entities/morse_entry.dart';
import '../providers/reference_provider.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  static const String playbackKey = 'reference';

  @override
  Widget build(BuildContext context) {
    final reference = context.watch<ReferenceProvider>();
    final playback = context.read<PlaybackProvider>();
    final selected = reference.selected;
    final isPlaying = context.select<PlaybackProvider, bool>((p) => p.isPlayingKey(playbackKey));

    return Column(
      children: [
        const ScreenHeader(
          eyebrow: '\u00B7\u2212 \u2212\u00B7\u00B7\u00B7 \u2212\u00B7\u2212\u00B7',
          title: 'Morse Alphabet',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.panelRaised,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          selected.character,
                          style: AppText.display.copyWith(fontSize: 34, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MorseSignal(code: selected.code, size: 14),
                            const SizedBox(height: 10),
                            Text(
                              '${selected.signalCount} signals',
                              style: AppText.morse.copyWith(
                                fontSize: 14,
                                letterSpacing: 1,
                                color: AppColors.onPanelMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PlaybackLamp(playbackKey: playbackKey),
                      const SizedBox(width: 10),
                      SquareIconButton(
                        icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        tooltip: isPlaying ? 'Stop' : 'Play ${selected.character}',
                        background: AppColors.accent,
                        foreground: AppColors.ink,
                        onPressed: () => playback.toggle(selected.code, key: playbackKey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SurfaceCard(
                  radius: 16,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      for (final category in MorseCategory.values)
                        Expanded(
                          child: _CategoryTab(
                            label: category.label,
                            active: category == reference.category,
                            onTap: () => reference.selectCategory(category),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 64,
                    ),
                    itemCount: reference.entries.length,
                    itemBuilder: (context, index) {
                      final entry = reference.entries[index];
                      return _EntryTile(
                        entry: entry,
                        selected: entry == selected,
                        onTap: () {
                          reference.select(entry);
                          playback.play(entry.code, key: playbackKey);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.selected, required this.onTap});

  final MorseEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spoken = entry.code.split('').map((c) => c == '.' ? 'dot' : 'dash').join(' ');
    return Semantics(
      label: '${entry.character}, $spoken',
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.ink : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? AppColors.ink : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.character,
                style: AppText.display.copyWith(
                  fontSize: 20,
                  height: 1,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  height: 8,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: MorseSignal(code: entry.code, size: 6, onDark: selected, singleLine: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
