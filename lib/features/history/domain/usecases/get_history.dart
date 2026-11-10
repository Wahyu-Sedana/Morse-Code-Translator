import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class GetHistory implements UseCase<List<HistoryEntry>, NoParams> {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(NoParams params) => _repository.getHistory();
}
