import 'dart:async';

import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/config/day.dart';
import 'package:xwordle/config/words.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';
import 'package:xwordle/xwordle.dart';

int gameNo() {
  DateTime now = DateTime.now();
  DateTime launch = DateTime(2023, 7, 14, 12);

  return now.difference(launch).inDays;
}

String getWord() {
  return words[gameNo() % words.length];
}

void updateWord() {
  final word = getWord();
  final index = gameNo();
  final day = WordleDay(word, index, DateTime.now());
  day.save();

  // Timer to update the word at 5:00 PM GMT
  final now = DateTime.now();
  final nextFivePM = DateTime(now.year, now.month, now.day, 17, 14);
  final tomorrow = now.isAfter(nextFivePM)
      ? DateTime(now.year, now.month, now.day + 1, 17)
      : nextFivePM;
  final difference = tomorrow.difference(now);
  Timer(difference, () {
    updateWord();
    notifyUsers();
  });
}

/// Notify users about the new word
Future<void> notifyUsers() async {
  final users = WordleDB.getUsers();
  final notificationEnabledUsers = users.where((e) => e.notify).toList();
  int count = notificationEnabledUsers.length;
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
