import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/add_history_entry.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/delete_history_entry.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/toggle_favorite.dart';

enum HistoryFilter {
  all('All'),
  favorites('Favorites'),
  tap('From taps');

  const HistoryFilter(this.label);

  final String label;
}

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({
    required GetHistory getHistory,
    required AddHistoryEntry addHistoryEntry,
    required DeleteHistoryEntry deleteHistoryEntry,
    required ToggleFavorite toggleFavorite,
    required ClearHistory clearHistory,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _getHistory = getHistory,
       _addHistoryEntry = addHistoryEntry,
       _deleteHistoryEntry = deleteHistoryEntry,
       _toggleFavorite = toggleFavorite,
       _clearHistory = clearHistory,
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? (() => DateTime.now().microsecondsSinceEpoch.toString());

  final GetHistory _getHistory;
  final AddHistoryEntry _addHistoryEntry;
  final DeleteHistoryEntry _deleteHistoryEntry;
  final ToggleFavorite _toggleFavorite;
  final ClearHistory _clearHistory;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  List<HistoryEntry> _entries = const [];
  HistoryFilter _filter = HistoryFilter.all;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<HistoryEntry> get entries => _entries;
  HistoryFilter get filter => _filter;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<HistoryEntry> get visibleEntries {
    final needle = _query.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesFilter = switch (_filter) {
        HistoryFilter.all => true,
        HistoryFilter.favorites => entry.isFavorite,
        HistoryFilter.tap => entry.source == HistorySource.tap,
      };
      final matchesQuery = needle.isEmpty || entry.text.toLowerCase().contains(needle) || entry.morse.contains(needle);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _apply(await _getHistory(const NoParams()));
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(HistoryFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setQuery(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }

  Future<bool> add({required String text, required String morse, required HistorySource source}) async {
    if (morse.trim().isEmpty) return false;
    final entry = HistoryEntry(
      id: _idGenerator(),
      text: text.trim().toUpperCase(),
      morse: morse.trim(),
      source: source,
      createdAt: _clock(),
    );
    final ok = _apply(await _addHistoryEntry(entry));
    notifyListeners();
    return ok;
  }

  Future<void> delete(String id) async {
    _apply(await _deleteHistoryEntry(id));
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    _apply(await _toggleFavorite(id));
    notifyListeners();
  }

  Future<void> clear() async {
    final result = await _clearHistory(const NoParams());
    result.fold((failure) => _errorMessage = failure.message, (_) {
      _entries = const [];
      _errorMessage = null;
    });
    notifyListeners();
  }

  bool _apply(Either<Failure, List<HistoryEntry>> result) {
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (entries) {
        _entries = List.unmodifiable(entries);
        _errorMessage = null;
        return true;
      },
    );
  }
}
