import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/output_options.dart';
import '../repositories/output_settings_repository.dart';

class SaveOutputOptions implements UseCase<Unit, OutputOptions> {
  const SaveOutputOptions(this._repository);

  final OutputSettingsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(OutputOptions params) => _repository.saveOptions(params);
}
