import '../entities/morse_entry.dart';

abstract class ReferenceRepository {
  List<MorseEntry> getEntries(MorseCategory category);
}
