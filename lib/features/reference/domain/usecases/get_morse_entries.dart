import '../entities/morse_entry.dart';
import '../repositories/reference_repository.dart';

class GetMorseEntries {
  const GetMorseEntries(this._repository);

  final ReferenceRepository _repository;

  List<MorseEntry> call(MorseCategory category) => _repository.getEntries(category);
}
