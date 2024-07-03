import 'dart:io';
import 'package:televerse/telegram.dart' hide File;
import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  final text =
      "Hey Wordler! I'm excited to announce two new features for the bot.\n\n"
      "1. /meaning\n"
      "The meaning command shouts the meaning of today's word. Well, only after you finish the game. 😉 This is a great way to learn new vocabulary. Out of the ordinary, I really think\n\n"
      "2. /shape\n"
      "Now, what about a little bit of customization.  The shape command lets you choose the shape of the hints for your guess. Currently supports three choices - circle, square, or... Well, I guess you'll figure it out. 👀\n\n"
      "I'm always looking for ways to improve the Wordle Bot, so if you have any thoughts on improving this bot, feel free to share it either using the /feedback command or shoot the thoughts on @Xooniverse post.\n\n"
      "I hope you enjoy these new features! Regards ✨";

  final keyboard = InlineKeyboard()
      .addUrl("Xooniverse Post 💬", "https://t.me/xooniverse/5");

  // await postToXooniverse(text, keyboard);
  await broadcastLogic(text, keyboard);
}

Future<void> postToXooniverse(String text, ReplyMarkup markup) async {
  await bot.api.sendMessage(
    ChannelID("@xooniverse"),
    text,
    replyMarkup: markup,
  );
}

Future<void> broadcastLogic(String text, ReplyMarkup markup) async {
  final users = await WordleDB.getUsers();
  final ids = users.map((e) => ChatID(e.id)).toList();

  int count = ids.length;
  int sent = 0, failed = 0;
  List<ErrorUser> failedIDsAndReason = [];
  Message? statusMessage = await sendLogs(progressMessage(count, 0, 0));

  for (int i = 0; i < count; i++) {
    try {
      await bot.api.sendMessage(ids[i], text, replyMarkup: markup);
      sent++;
      await Future.delayed(Duration(milliseconds: 2000));

      if (i % 10 == 0) {
        if (statusMessage != null) {
          await editLog(
            statusMessage.messageId,
            progressMessage(count, sent, failed),
          );
          await Future.delayed(Duration(milliseconds: 2000));
        }
      }
    } catch (e) {
      print("Failed to send message to ${ids[i].id}");
      failed++;
      failedIDsAndReason.add(
        ErrorUser(ids[i].id, e.toString()),
      );
      WordleUser user = await WordleUser.init(ids[i].id);
      user.optedOutOfBroadcast = true;
      user.id = ids[i].id;
      user.save();
    }
  }

  try {
    await sendLogs(
      "Broadcasted message to $sent users. Failed to send to $failed users.",
    );

    File f = File("failed.txt");
    if (!f.existsSync()) f.createSync();
    f.writeAsStringSync(
      failedIDsAndReason.map((e) => e.line).join("\n"),
    );
    if (failedIDsAndReason.isNotEmpty) {
      await bot.api.sendDocument(
        WordleConfig.instance.logsChannel,
        InputFile.fromFile(f),
        caption: "Failed IDs",
      );
    }
    await Future.delayed(Duration(seconds: 5), () {
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
