import 'package:flutter/material.dart';

import '../morse/morse_codec.dart';
import '../theme/app_colors.dart';

/// Draws a Morse string as shapes: dots are round and blue, dashes are long
/// amber pills. Letters are separated by a wider gap and words by a faint
/// slash. Accepts raw ('.', '-') or prettified ('·', '−') input.
class MorseSignal extends StatelessWidget {
  const MorseSignal({
    super.key,
    required this.code,
    this.size = 12,
    this.onDark = true,
    this.singleLine = false,
    this.alignment = WrapAlignment.start,
  });

  /// Dash length relative to the dot diameter.
  static const double dashRatio = 3.2;

  final String code;

  /// Dot diameter and dash thickness.
  final double size;
  final bool onDark;

  /// Keeps everything on one line and clips the overflow (for list rows).
  final bool singleLine;
  final WrapAlignment alignment;

  static List<List<String>> wordsOf(String code) {
    return const MorseCodec()
        .normalize(code)
        .trim()
        .split(RegExp(r'\s*/\s*'))
        .map((word) => word.trim().split(RegExp(r'\s+')).map(_symbols).where((s) => s.isNotEmpty).toList())
        .where((letters) => letters.isNotEmpty)
        .toList();
  }

  static String _symbols(String letter) => letter.replaceAll(RegExp(r'[^.\-]'), '');

  /// Screen reader text, e.g. "dot dot dot, dash dash dash".
  static String spokenOf(String code) => wordsOf(code)
      .map((word) => word.map((l) => l.split('').map((s) => s == '.' ? 'dot' : 'dash').join(' ')).join(', '))
      .join(', space, ');

  @override
  Widget build(BuildContext context) {
    final dotColor = onDark ? AppColors.signalDot : AppColors.signalDotOnLight;
    final dashColor = onDark ? AppColors.signalDash : AppColors.signalDashOnLight;
    final slashColor = onDark ? AppColors.onPanelFaint : AppColors.placeholder;
    final symbolGap = size * 0.5;
    final letterGap = size * 2.2;

    // A single letter wider than the available space (e.g. "-----" in a narrow
    // card, or a long run on the tap pad) scales down instead of overflowing.
    Widget letter(String symbols) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < symbols.length; i++) ...[
            if (i > 0) SizedBox(width: symbolGap),
            Container(
              width: symbols[i] == '.' ? size : size * dashRatio,
              height: size,
              decoration: BoxDecoration(
                color: symbols[i] == '.' ? dotColor : dashColor,
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ],
        ],
      ),
    );

    final slash = Text(
      '/',
      style: TextStyle(fontSize: size * 1.6, height: 1, fontWeight: FontWeight.w700, color: slashColor),
    );

    final words = wordsOf(code);
    final items = <Widget>[
      for (var w = 0; w < words.length; w++) ...[if (w > 0) slash, for (final l in words[w]) letter(l)],
    ];

    final Widget body = singleLine
        ? ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[if (i > 0) SizedBox(width: letterGap), items[i]],
                ],
              ),
            ),
          )
        : Wrap(
            alignment: alignment,
            spacing: letterGap,
            runSpacing: size * 1.1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: items,
          );

    return Semantics(label: spokenOf(code), excludeSemantics: true, child: body);
  }
}
