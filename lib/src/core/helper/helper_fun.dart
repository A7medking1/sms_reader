bool isSameDay(int timestamp1, int timestamp2) {
  final date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
  final date2 = DateTime.fromMillisecondsSinceEpoch(timestamp2);

  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}

String formatDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();

  if (date.day == now.day) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else {
    return '${date.day}/${date.month}';
  }
}
