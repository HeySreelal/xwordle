import 'dart:io';
import 'dart:math';

import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/xwordle.dart';

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
    return durationString(diff);
  }

  static String durationString(Duration dur) {
    final days = dur.inDays;
    final hours = dur.inHours - days * 24;
    final minutes = dur.inMinutes - hours * 60 - days * 24 * 60;

    final dayStr = days > 0 ? '$days days ' : '';
    final hourStr = hours > 0 ? '$hours hours ' : '';
    final minuteStr = minutes > 0 ? '$minutes minutes ' : '';

    return '$dayStr$hourStr$minuteStr';
  }
}

class ErrorUser {
  final int userId;
  final String reason;

  ErrorUser(this.userId, String reason) : reason = reason.replaceAll("\n", " ");
}

Future<void> createLogFileAndSend(List<ErrorUser> errorUsers) async {
  try {
    File file = File('logs.txt');
    if (await file.exists()) {
      await file.delete();
    }

    await file.create();

    int count = errorUsers.length;

    for (int i = 0; i < count; i++) {
      await file.writeAsString(
        '${errorUsers[i].userId}: ${errorUsers[i].reason}\n',
        mode: FileMode.append,
      );
    }

    await bot.api.sendDocument(
      WordleConfig.instance.logsChannel,
      InputFile.fromFile(file),
    );

    await Future.delayed(Duration(seconds: 5), () async {
      await file.delete();
    });
  } catch (err, stack) {
    try {
      await errorHandler(err, stack);
    } catch (e) {
      print(e);
    }
  }
}
