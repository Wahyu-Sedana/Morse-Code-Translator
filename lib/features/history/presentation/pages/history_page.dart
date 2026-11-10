import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../playback/presentation/providers/playback_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/history_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClear(BuildContext context, HistoryProvider history) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear all history?'),
        content: const Text('All saved messages will be deleted from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await history.clear();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final playback = context.read<PlaybackProvider>();
    final playingKey = context.select<PlaybackProvider, String?>((p) => p.isPlaying ? p.playingKey : null);
    final entries = history.visibleEntries;

    return Column(
      children: [
        ScreenHeader(
          eyebrow: '\u00B7\u2212\u00B7\u00B7 \u2212\u2212\u2212 \u2212\u2212\u00B7',
          title: 'History',
          trailing: OutlinedButton(
            onPressed: history.entries.isEmpty ? null : () => _confirmClear(context, history),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size(44, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Clear all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            children: [
              TextField(
                onChanged: history.setQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  hintStyle: const TextStyle(color: AppColors.placeholder),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.focus, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in HistoryFilter.values) ...[
                      ChoiceChip(
                        label: Text(filter.label),
                        selected: history.filter == filter,
                        onSelected: (_) => history.setFilter(filter),
                        showCheckmark: false,
                        selectedColor: AppColors.ink,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: history.filter == filter ? AppColors.ink : AppColors.border),
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: history.filter == filter ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: history.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
              : entries.isEmpty
              ? _EmptyState(hasAny: history.entries.isNotEmpty, error: history.errorMessage)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Dismissible(
                      key: ValueKey(entry.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => history.delete(entry.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3261E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, semanticLabel: 'Delete'),
                      ),
                      child: HistoryTile(
                        entry: entry,
                        isPlaying: playingKey == entry.id,
                        onPlay: () => playback.toggle(entry.morse, key: entry.id),
                        onToggleFavorite: () => history.toggleFavorite(entry.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasAny, this.error});

  final bool hasAny;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final title = error != null
        ? 'Could not open history'
        : hasAny
        ? 'No matches'
        : 'No history yet';
    final body =
        error ??
        (hasAny
            ? 'Try another keyword or filter.'
            : 'Tap the save icon on the Translate or Tap screen to save a message.');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 40, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: AppText.display.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
