import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CheckOnboardingStatus implements UseCase<bool, NoParams> {
  const CheckOnboardingStatus(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) => _repository.isCompleted();
}
