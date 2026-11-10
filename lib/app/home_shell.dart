import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/playback/presentation/providers/playback_provider.dart';
import '../features/reference/presentation/pages/reference_page.dart';
import '../features/tap_keyer/presentation/pages/tap_page.dart';
import '../features/translator/presentation/pages/translator_page.dart';

class _TabItem {
  const _TabItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<_TabItem> _tabs = [
    _TabItem('Translate', Icons.swap_horiz_rounded),
    _TabItem('Tap', Icons.radio_button_checked_rounded),
    _TabItem('Alphabet', Icons.grid_view_rounded),
    _TabItem('History', Icons.history_rounded),
  ];

  int _index = 0;

  void _select(int index) {
    if (index == _index) return;
    context.read<PlaybackProvider>().stop();
    FocusScope.of(context).unfocus();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const [TranslatorPage(), TapPage(), ReferencePage(), HistoryPage()],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _TabButton(item: _tabs[i], active: i == _index, onTap: () => _select(i)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.item, required this.active, required this.onTap});

  final _TabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.muted;
    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: active ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
