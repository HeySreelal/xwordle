import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/config/day.dart';
import 'package:xwordle/config/words.dart';
import 'package:xwordle/models/session.dart';
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
  final nextFivePM = DateTime(now.year, now.month, now.day, 17);
  final tomorrow = now.isAfter(nextFivePM)
      ? DateTime(now.year, now.month, now.day + 1, 17)
      : nextFivePM;
  final difference = tomorrow.difference(now);
  Timer(difference, () {
    updateWord();
  });
}

/// Notify users about the new word
Future<void> notifyUsers() async {
  List<FileSystemEntity> files = Directory(".televerse/sessions").listSync();
  int count = files.length;
  int success = 0, failure = 0;
  for (int i = 0; i < count; i++) {
    File file = File(files[i].path);
    String contents = file.readAsStringSync();
    WordleSession session = WordleSession.fromMap(jsonDecode(contents));
    if (session.notify) {
      try {
        await bot.api.sendMessage(
          ChatID(session.userId),
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
      WordleConfig.instance.logsChannel,
      "Notified $success users, failed to notify $failure users",
    );
  } catch (err) {
    print(err);
  }
}
