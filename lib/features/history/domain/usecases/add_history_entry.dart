import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class AddHistoryEntry implements UseCase<List<HistoryEntry>, HistoryEntry> {
  const AddHistoryEntry(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(HistoryEntry params) => _repository.addEntry(params);
}
