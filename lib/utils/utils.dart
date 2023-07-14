import 'dart:math';

String random(List<String> list) => list[Random().nextInt(list.length)];

class DateUtil {
  static const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static String getFormattedDuration(DateTime till) {
    final now = DateTime.now();
    final diff = till.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours - days * 24;
    final minutes = diff.inMinutes - hours * 60 - days * 24 * 60;
    final seconds =
        diff.inSeconds - minutes * 60 - hours * 60 * 60 - days * 24 * 60 * 60;

    final dayStr = days > 0 ? '$days days ' : '';
    final hourStr = hours > 0 ? '$hours hours ' : '';
    final minuteStr = minutes > 0 ? '$minutes minutes ' : '';
    final secondStr = seconds > 0 ? '$seconds seconds ' : '';

    return '$dayStr$hourStr$minuteStr$secondStr';
  }
}
