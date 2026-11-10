import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/output_options.dart';
import '../../domain/repositories/output_settings_repository.dart';
import '../datasources/output_settings_local_data_source.dart';

class OutputSettingsRepositoryImpl implements OutputSettingsRepository {
  const OutputSettingsRepositoryImpl(this._local);

  final OutputSettingsLocalDataSource _local;

  @override
  Future<Either<Failure, OutputOptions>> getOptions() async {
    try {
      return Right(_local.read());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveOptions(OutputOptions options) async {
    try {
      await _local.write(options);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
