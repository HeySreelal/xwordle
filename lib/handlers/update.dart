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
  try {
    WordleDay day = await _fetchAndUpdateWordleDay();
    await _scheduleNextUpdate(day);
  } catch (e, s) {
    await _handleWordUpdateError(e, s);
  }
}

/// Fetch and update the Wordle day
Future<WordleDay> _fetchAndUpdateWordleDay() async {
  WordleDay day = await WordleDB.today();
  day.index = gameNo();
  day.word = getWord(day.index);
  day.next = launch.add(Duration(days: gameNo() + 1));
  await day.save();
  return day;
}

/// Schedule the next update
Future<void> _scheduleNextUpdate(WordleDay day) async {
  final durationToNext = day.next.difference(DateTime.now());
  print("Duration to next update call: $durationToNext");
  Timer(durationToNext, () async {
    await sendDailyLog();
    await day.resetCounters();
    await updateWord();
    await notifyUsers();
  });
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
  final users = await WordleDB.getUsers();
  final notificationEnabledUsers =
      users.where((e) => e.notify && e.hasPlayedInLast4Days()).toList();
  int count = notificationEnabledUsers.length;

  await sendLogs("🔔 Notifying $count users");
  Message? statusMessage = await sendLogs(progressMessage(count, 0, 0));

  final stopwatch = Stopwatch()..start();

  int success = 0, failure = 0;
  List<ErrorUser> errorUsers = [];

  for (int i = 0; i < count; i++) {
    await _notifySingleUser(
      notificationEnabledUsers[i],
      gameNo(),
      stopwatch,
      statusMessage,
      success,
      failure,
      errorUsers,
      count,
    );
  }

  await _finalizeNotifications(
    stopwatch,
    statusMessage,
    success,
    failure,
    errorUsers,
  );
}

/// Notify a single user
Future<void> _notifySingleUser(
  WordleUser user,
  int gameNo,
  Stopwatch stopwatch,
  Message? statusMessage,
  int success,
  int failure,
  List<ErrorUser> errorUsers,
  int count,
) async {
  try {
    if (await _shouldNotifyUser(user, gameNo)) {
      await _sendNotification(user);
      success++;
    } else {
      success++;
    }
  } catch (e) {
    failure++;
    errorUsers.add(ErrorUser(user.id, e.toString()));
  }

  if (count % 10 == 0 && statusMessage != null) {
    await editLog(
      statusMessage.messageId,
      progressMessage(count, success, failure),
    );
    await Future.delayed(Duration(milliseconds: 2000));
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

/// Finalize notifications
Future<void> _finalizeNotifications(Stopwatch stopwatch, Message? statusMessage,
    int success, int failure, List<ErrorUser> errorUsers) async {
  try {
    await sendLogs(
      "🔔 Notified $success users, failed to notify $failure users.\n\nIt took ${DateUtil.durationString(stopwatch.elapsed)}",
    );
    await editLog(
      statusMessage!.messageId,
      "${progressMessage(success + failure, success, failure)}\n\n#notified",
    );
    stopwatch.stop();
    await _turnOffNotificationsForFailedUsers(errorUsers);
    await createLogFileAndSend(errorUsers);
  } catch (err) {
    print(err);
  }
}

/// Turn off notifications for failed users
Future<void> _turnOffNotificationsForFailedUsers(
  List<ErrorUser> errorUsers,
) async {
  await sendLogs(
    'Turning off notifications for ${errorUsers.length} failed users',
  );
  for (var errorUser in errorUsers) {
    WordleUser user = await WordleUser.init(errorUser.userId);
    user.notify = false;
    await user.save();
  }
  final blocked =
      errorUsers.where((e) => e.reason.contains(MessageStrings.blocked)).length;
  WordleDB.incrementBlockedCount(blocked).ignore();
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
