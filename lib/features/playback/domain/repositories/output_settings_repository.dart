import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/output_options.dart';

abstract class OutputSettingsRepository {
  Future<Either<Failure, OutputOptions>> getOptions();

  Future<Either<Failure, Unit>> saveOptions(OutputOptions options);
}
