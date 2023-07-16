import 'dart:io';
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  final text = "Dear Wordle Game Users,\n\n"
      "We apologize for the extended downtime of our Wordle Game bot on Telegram. Due to server space limitations, we were unable to keep the bot running. We deeply regret any inconvenience caused and was actively working to resolve the issue from the last week. Thank you for your patience and continued support. We are extremely thrilled to announce that the bot is back online again.\n\n"
      "Now that we said that - ready, set, go! Send /start to start the game again! 🎮\n\n"
      "Best regards!";

  final keyboard = InlineKeyboard()
      .addUrl("View Full Story 📝", "https://t.me/xooniverse/16")
      .row()
      .addUrl("Vote 🗳️", "https://t.me/xooniverse/17");

  final users = WordleDB.getUsers();
  final ids = users.map((e) => ChatID(e.userId)).toList();

  int count = ids.length;
  int sent = 0, failed = 0;
  List<List<String>> failedIDsAndReason = [];
  for (int i = 0; i < count; i++) {
    try {
      await bot.api.sendMessage(ids[i], text, replyMarkup: keyboard);
      sent++;
      await Future.delayed(Duration(milliseconds: 2000));
    } catch (e) {
      print("Failed to send message to ${ids[i].id}");
      failed++;
      failedIDsAndReason.add(
        ["${ids[i].id}", e.toString().replaceAll("\n", " ")],
      );
    }
  }

  try {
    await sendLogs(
      "Broadcasted message to $sent users. Failed to send to $failed users.",
    );

    File f = File("failed.txt");
    if (!f.existsSync()) f.createSync();
    f.writeAsStringSync(
      failedIDsAndReason.map((e) => "${e[0]}: ${e[1]}").join("\n"),
    );
    if (failedIDsAndReason.isNotEmpty) {
      await bot.api.sendDocument(
        WordleConfig.instance.logsChannel,
        InputFile.fromFile(f),
        caption: "Failed IDs",
      );
    }
    Future.delayed(Duration(seconds: 5), () {
      try {
        f.deleteSync();
      } catch (e) {
        print("Failed to delete file");
      }
    });
  } catch (e, s) {
    print("Failed to send logs");
    print(e);
    print(s);
  }
}
