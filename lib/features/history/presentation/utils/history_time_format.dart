const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatHistoryTime(DateTime time, DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  final clock = '${two(time.hour)}:${two(time.minute)}';
  final day = DateTime(time.year, time.month, time.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today, $clock';
  if (diff == 1) return 'Yesterday, $clock';
  final date = '${time.day} ${_months[time.month - 1]}';
  if (time.year == now.year) return '$date, $clock';
  return '$date ${time.year}, $clock';
}
