import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../models/history_entry_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._local, {this.maxEntries = 200});

  final HistoryLocalDataSource _local;
  final int maxEntries;

  @override
  Future<Either<Failure, List<HistoryEntry>>> getHistory() async {
    return _guard(() async => _local.readAll());
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> addEntry(HistoryEntry entry) async {
    return _guard(() async {
      final updated = [HistoryEntryModel.fromEntity(entry), ..._local.readAll().where((e) => e.id != entry.id)];
      final kept = _trim(updated);
      await _local.writeAll(kept);
      return kept;
    });
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> deleteEntry(String id) async {
    return _guard(() async {
      final updated = _local.readAll().where((e) => e.id != id).toList();
      await _local.writeAll(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> toggleFavorite(String id) async {
    return _guard(() async {
      final updated = _local
          .readAll()
          .map((e) => e.id == id ? HistoryEntryModel.fromEntity(e.copyWith(isFavorite: !e.isFavorite)) : e)
          .toList();
      await _local.writeAll(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, Unit>> clearHistory() async {
    try {
      await _local.writeAll(const []);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  List<HistoryEntryModel> _trim(List<HistoryEntryModel> entries) {
    if (entries.length <= maxEntries) return entries;
    final favorites = entries.where((e) => e.isFavorite).toList();
    final others = entries.where((e) => !e.isFavorite).toList();
    final room = (maxEntries - favorites.length).clamp(0, others.length);
    final keepIds = {...favorites.map((e) => e.id), ...others.take(room).map((e) => e.id)};
    return entries.where((e) => keepIds.contains(e.id)).toList();
  }

  Future<Either<Failure, List<HistoryEntry>>> _guard(Future<List<HistoryEntry>> Function() action) async {
    try {
      return Right(await action());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
