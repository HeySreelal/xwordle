part of '../xwordle.dart';

final launch = DateTime(2024, 7, 1, 12, 00);

/// Returns the number of games since launch date
int gameNo() {
  DateTime now = DateTime.now();

  return now.difference(launch).inDays;
}

/// Returns today's word
String getWord(int index) {
  return words[index % words.length];
}

/// Updates the words, sends notification to subscribed users.
Future<void> updateWord() async {
  WordleDay day;
  try {
    day = await WordleDB.today();
    day.index = gameNo();
    day.word = getWord(day.index);
    day.next = launch.add(Duration(days: gameNo() + 1));
  } catch (e, s) {
    try {
      await sendLogs("Error while updating word");
      await errorHandler(BotError(e, s));
    } catch (e) {
      print(e);
    }
    int index = gameNo();
    String word = getWord(index);
    day = WordleDay(word, index, DateTime.now());
  }
  await day.save();

  final durationToNext = day.next.difference(DateTime.now());
  print("Duration to next update call: $durationToNext");
  Timer(durationToNext, () async {
    sendDailyLog();
    day.resetCounters().ignore();
    updateWord();
    notifyUsers();
  });
}

/// Notify users about the new word
Future<void> notifyUsers() async {
  final users = await WordleDB.getUsers();
  final notificationEnabledUsers = users.where((e) {
    return e.notify && e.hasPlayedInLast4Days();
  }).toList();
  int count = notificationEnabledUsers.length;

  await sendLogs("🔔 Notifying $count users");
  Message? statusMessage = await sendLogs(progressMessage(count, 0, 0));

  final stopwatch = Stopwatch()..start();

  int success = 0, failure = 0;
  List<ErrorUser> errorUsers = [];

  for (int i = 0; i < count; i++) {
    try {
      final user = await WordleUser.init(notificationEnabledUsers[i].id);
      if (user.lastGame == gameNo() || user.currentGame == gameNo()) {
        success++;
        continue;
      }
      await api.sendMessage(
        ChatID(notificationEnabledUsers[i].id),
        random(MessageStrings.notificationMsgs),
      );
      success++;
      await Future.delayed(Duration(milliseconds: 2000));
    } catch (e) {
      failure++;
      errorUsers.add(ErrorUser(
        notificationEnabledUsers[i].id,
        e.toString(),
      ));
    }

    if (i % 10 == 0) {
      if (statusMessage != null) {
        await editLog(
          statusMessage.messageId,
          progressMessage(count, success, failure),
        );
        await Future.delayed(Duration(milliseconds: 2000));
      }
    }
  }
  try {
    await sendLogs(
      "🔔 Notified $success users, failed to notify $failure users.\n\nIt took ${DateUtil.durationString(stopwatch.elapsed)}",
    );
    await editLog(
      statusMessage!.messageId,
      "${progressMessage(count, success, failure)}\n\n#notified",
    );
    stopwatch.stop();
    stopwatch.reset();
    turnOffNotificationForFailedUsers(errorUsers);
    await createLogFileAndSend(errorUsers);
  } catch (err) {
    print(err);
  }
}

String progressMessage(int total, int success, int failure) {
  int totalSent = success + failure;
  double completePercent = totalSent / total;

  return "📣 Update (${(completePercent * 100).toStringAsFixed(2)}%)\n\n"
      "Total: $total\n"
      "Success: $success\n"
      "Failure: $failure\n"
      "Remaining: ${total - totalSent}\n\n"
      "${progressPercent(completePercent)}";
}

String progressPercent(double completePercent) {
  String completed = "🟢";
  String rem = "⚫️";

  int completeCount = (completePercent * 10).floor();
  int remCount = 10 - completeCount;

  String completedStr = completed * completeCount;
  String remStr = rem * remCount;
  return completedStr + remStr;
}

void turnOffNotificationForFailedUsers(List<ErrorUser> errorUsers) async {
  sendLogs('Turning off notifications for ${errorUsers.length} failed users');
  final l = errorUsers.length;
  for (int i = 0; i < l; i++) {
    final user = await WordleUser.init(errorUsers[i].userId);
    user.notify = false;
    user.id = errorUsers[i].userId;
    user.save();
  }
  final blocked = errorUsers
      .where((e) => e.reason.contains(MessageStrings.blocked))
      .toList()
      .length;
  WordleDB.incrementBlockedCount(blocked).ignore();
}
