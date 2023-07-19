part of xwordle;

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

  String get line => "$userId: $reason\n";
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

    if (file.lengthSync() > 0) {
      await bot.api.sendDocument(
        WordleConfig.instance.logsChannel,
        InputFile.fromFile(file),
      );
    }

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

Future<Message?> sendLogs(String text) async {
  try {
    return await bot.api.sendMessage(
      WordleConfig.instance.logsChannel,
      text,
      parseMode: ParseMode.html,
    );
  } catch (err, stack) {
    try {
      await errorHandler(err, stack);
    } catch (e) {
      print(e);
    }
  }
  return null;
}

Future<void> editLog(int messageId, String text) async {
  try {
    await bot.api.editMessageText(
      WordleConfig.instance.logsChannel,
      messageId,
      text,
    );
  } catch (err, stack) {
    try {
      await errorHandler(err, stack);
    } catch (e) {
      print(e);
    }
  }
}

Future<void> sendDailyLog() async {
  try {
    await sendLogs(statsMessage(autoLog: true));
  } catch (err, stack) {
    try {
      await errorHandler(err, stack);
    } catch (e) {
      print(e);
    }
  }
}

String statsMessage({int? requestedUser, bool autoLog = false}) {
  WordleDay day = WordleDB.today;
  WordleUser? user;
  if (requestedUser != null) {
    user = WordleUser.init(requestedUser);
  }

  String wordString = (user != null && user.lastGame == day.index) || autoLog
      ? "Word: ${day.word}\n\n"
      : '';

  int skips = day.totalPlayed - (day.totalWinners + day.totalLosers);

  String progressBar(int total, int wins, int loses, int skips) {
    double winPercent = wins / total;
    double losePercent = loses / total;
    double skipPercent = skips / total;

    int winLength = (winPercent * 10).round();
    int loseLength = (losePercent * 10).round();
    int skipLength = (skipPercent * 10).round();

    String winBar = "🟩" * winLength;
    String loseBar = "🟥" * loseLength;
    String skipBar = "🟨" * skipLength;

    return "$winBar$loseBar$skipBar";
  }

  String msg = "ℹ️ Wordle Day ${day.index + 1}\n\n"
      "$wordString"
      "Total Users: ${WordleDB.getUsers().length}\n"
      "Total Plays: ${day.totalPlayed}\n"
      "Total Wins: ${day.totalWinners}\n"
      "Total Losers: ${day.totalLosers}\n"
      "Total Skips: $skips\n\n"
      "${progressBar(day.totalPlayed, day.totalWinners, day.totalLosers, skips)}\n\n"
      "#daily";

  return msg;
}
