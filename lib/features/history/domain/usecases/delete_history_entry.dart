import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryEntry implements UseCase<List<HistoryEntry>, String> {
  const DeleteHistoryEntry(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(String params) => _repository.deleteEntry(params);
}
