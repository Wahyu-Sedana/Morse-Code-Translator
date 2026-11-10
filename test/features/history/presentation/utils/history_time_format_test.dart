import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/history/presentation/utils/history_time_format.dart';

void main() {
  final now = DateTime(2026, 11, 10, 15, 0);

  test('same day shows Today with time', () {
    expect(formatHistoryTime(DateTime(2026, 11, 10, 9, 5), now), 'Today, 09:05');
  });

  test('previous day shows Yesterday', () {
    expect(formatHistoryTime(DateTime(2026, 11, 9, 19, 5), now), 'Yesterday, 19:05');
  });

  test('same year shows day and month', () {
    expect(formatHistoryTime(DateTime(2026, 11, 8, 21, 10), now), '8 Nov, 21:10');
  });

  test('other years include the year', () {
    expect(formatHistoryTime(DateTime(2025, 1, 2, 7, 0), now), '2 Jan 2025, 07:00');
  });
}
