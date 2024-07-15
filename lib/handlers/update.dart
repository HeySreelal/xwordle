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
Future<void> updateWord({bool shouldNotify = false}) async {
  await sendLogs("⏰ Updating word now!");
  if (shouldNotify) {
    await sendLogs("🔔 This time, we will send notifications to users.");
  }
  try {
    await sendDailyLog();
    WordleDay day = await _fetchAndUpdateWordleDay();
    await day.resetCounters();
    if (shouldNotify) {
      await notifyUsers();
    }
  } catch (e, s) {
    await _handleWordUpdateError(e, s);
  }
}

/// Fetch and update the Wordle day
Future<WordleDay> _fetchAndUpdateWordleDay() async {
  WordleDay day = await WordleDB.today();
  final ix = gameNo();
  day.index = ix;
  day.word = getWord(day.index);
  day.next = launch.add(Duration(days: ix + 1));
  await day.save();
  return day;
}

/// Handle errors during word update
Future<void> _handleWordUpdateError(dynamic e, StackTrace s) async {
  try {
    await sendLogs("Error while updating word");
    await errorHandler(BotError(e, s));
  } catch (innerError) {
    print(innerError);
  }

  int index = gameNo();
  String word = getWord(index);
  WordleDay day = WordleDay(word, index, DateTime.now());
  await day.save();
}

/// Notify users about the new word
Future<void> notifyUsers() async {
  final game = gameNo();
  List<int> users = await WordleDB.notifyMePeople();

  int totalCount = users.length;

  await sendLogs("🔔 Notifying $totalCount users");

  int successCount = 0, failureCount = 0;
  final text = progressMessage(totalCount, successCount, failureCount);
  Message? statusMessage = await sendLogs(text);

  final stopwatch = Stopwatch()..start();

  List<ErrorUser> errorUsers = [];

  for (int i = 0; i < totalCount; i++) {
    final user = await WordleUser.init(users[i]);
    try {
      if (await _shouldNotifyUser(user, game)) {
        await _sendNotification(user);
      }
      successCount++;
    } catch (e) {
      user.notify = false;
      try {
        await user.save();
      } catch (_) {}
      failureCount++;
      errorUsers.add(ErrorUser(user.id, e.toString()));
    }

    if (i % 10 == 0 && statusMessage != null) {
      await editLog(
        statusMessage.messageId,
        progressMessage(totalCount, successCount, failureCount),
      );
      await Future.delayed(Duration(milliseconds: 2000));
    }
  }

  try {
    await sendLogs(
      "🔔 Notified $successCount users, failed to notify $failureCount users.\n\nIt took ${DateUtil.durationString(stopwatch.elapsed)}",
    );
    await editLog(
      statusMessage!.messageId,
      "${progressMessage(totalCount, successCount, failureCount)}\n\n#notified",
    );
    stopwatch.stop();
    await sendLogs(
      'Turning off notifications for ${errorUsers.length} failed users',
    );

    users.removeWhere((e) => errorUsers.any((x) => x.userId == e));

    final blocked = errorUsers
        .where((e) => e.reason.contains(MessageStrings.blocked))
        .length;

    WordleDB.incrementBlockedCount(blocked).ignore();
    WordleDB.updateNotifyList(users).ignore();
    await createLogFileAndSend(errorUsers);
  } catch (err) {
    print(err);
  }
}

/// Determine if a user should be notified
Future<bool> _shouldNotifyUser(WordleUser user, int gameNo) async {
  return user.lastGame != gameNo && user.currentGame != gameNo;
}

/// Send a notification to a user
Future<void> _sendNotification(WordleUser user) async {
  await api.sendMessage(
    ChatID(user.id),
    random(MessageStrings.notificationMsgs),
  );
  await Future.delayed(Duration(milliseconds: 2000));
}

/// Generate a progress message
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

/// Generate a progress percentage bar
String progressPercent(double completePercent) {
  String completed = "🟢";
  String remaining = "⚫️";

  int completeCount = (completePercent * 10).floor();
  int remainingCount = 10 - completeCount;

  return completed * completeCount + remaining * remainingCount;
}
