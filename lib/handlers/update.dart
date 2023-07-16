import 'dart:async';

import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/config/day.dart';
import 'package:xwordle/config/words.dart';
import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';
import 'package:xwordle/xwordle.dart';

DateTime launch = DateTime(2023, 7, 14, 6);
int gameNo() {
  DateTime now = DateTime.now();

  return now.difference(launch).inDays;
}

String getWord() {
  return words[gameNo() % words.length];
}

void updateWord() {
  WordleDay day;
  try {
    day = WordleDB.today;
    day.word = getWord();
    day.index = gameNo();
    day.next = launch.add(Duration(days: gameNo() + 1));
  } catch (e) {
    int index = gameNo();
    String word = getWord();
    day = WordleDay(word, index, DateTime.now());
  }
  day.save();

  final durationToNext = day.next.difference(DateTime.now());
  print(durationToNext);
  Timer(durationToNext, () {
    updateWord();
    notifyUsers();
  });
}

/// Notify users about the new word
Future<void> notifyUsers() async {
  final users = WordleDB.getUsers();
  final notificationEnabledUsers = users.where((e) => e.notify).toList();
  int count = notificationEnabledUsers.length;
  try {
    await bot.api.sendMessage(
      WordleConfig.instance.logsChannel,
      "🔔 Notifying $count users",
    );
  } catch (err, stack) {
    try {
      await errorHandler(err, stack);
    } catch (e) {
      print(e);
    }
  }
  int success = 0, failure = 0;
  for (int i = 0; i < count; i++) {
    if (notificationEnabledUsers[i].notify) {
      try {
        await bot.api.sendMessage(
          ChatID(notificationEnabledUsers[i].userId),
          random(MessageStrings.notificationMsgs),
        );
        success++;
        await Future.delayed(Duration(milliseconds: 2000));
      } catch (e) {
        failure++;
      }
    }
  }
  try {
    await bot.api.sendMessage(
      WordleConfig.init().logsChannel,
      "🔔 Notified $success users, failed to notify $failure users",
    );
  } catch (err) {
    print(err);
  }
}
