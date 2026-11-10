import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryEntry>>> getHistory();

  Future<Either<Failure, List<HistoryEntry>>> addEntry(HistoryEntry entry);

  Future<Either<Failure, List<HistoryEntry>>> deleteEntry(String id);

  Future<Either<Failure, List<HistoryEntry>>> toggleFavorite(String id);

  Future<Either<Failure, Unit>> clearHistory();
}
