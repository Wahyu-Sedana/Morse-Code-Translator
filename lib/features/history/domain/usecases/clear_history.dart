import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/history_repository.dart';

class ClearHistory implements UseCase<Unit, NoParams> {
  const ClearHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.clearHistory();
}
