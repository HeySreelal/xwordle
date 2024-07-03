import 'dart:io';
import 'package:televerse/telegram.dart' hide File;
import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  await init();
  final text = """
Hey Wordler! This message might come as a surprise, but unexpected things happen, right? 😊

Great news: the Wordle Bot is back and available for you to play! 🎉 We know you might have missed the bot and the fun of guessing the word of the day. We apologize for the sudden downtime.

However, we’re facing some challenges with covering the server costs to keep the bot running. In fact we need your help in keeping the Wordle Bot up and healthy :) Your support means the world to us! A small contribution can make a big difference. 

We’ve added the /donate command to make it easy for you to support us. Every little bit helps.

We’d also love to know if you enjoy playing the Wordle game. Would you mind letting us know by voting in the linked poll?

If there's anything on your mind, please feel free to let us know. We truly value your feedback! Use the /feedback command to tell us what you think and how we can improve your Wordle experience.

Thank you for being part of our Wordle community. Enjoy the game, and let’s keep the fun going! ✨
""";

  final keyboard = InlineKeyboard()
      .addUrl("Xooniverse Post 💬", "https://t.me/xooniverse/5");

  await postToXooniverse(text, keyboard);
}

Future<void> testBroadcast(String text) async {
  bot.api.sendMessage(ChatID(1726826785), text);
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
  List<ErrorUser> errorUsers = [];
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
      errorUsers.add(
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
      errorUsers.map((e) => e.line).join("\n"),
    );
    if (errorUsers.isNotEmpty) {
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
