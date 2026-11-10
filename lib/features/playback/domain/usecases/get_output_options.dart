import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/output_options.dart';
import '../repositories/output_settings_repository.dart';

class GetOutputOptions implements UseCase<OutputOptions, NoParams> {
  const GetOutputOptions(this._repository);

  final OutputSettingsRepository _repository;

  @override
  Future<Either<Failure, OutputOptions>> call(NoParams params) => _repository.getOptions();
}
