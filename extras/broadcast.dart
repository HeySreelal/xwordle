import 'dart:io';
import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart' hide bot;

final text = """
Hey Wordler! This message might come as a surprise, but unexpected things happen, right? 😊

Great news: the Wordle Bot is back and available for you to play! 🎉 We know you might have missed the bot and the fun of guessing the word of the day. We apologize for the sudden downtime.

However, we’re facing some challenges with covering the server costs to keep the bot running. In fact we need your help in keeping the Wordle Bot up and healthy :) Your support means the world to us! A small contribution can make a big difference. 

We’ve added the /donate command to make it easy for you to support us. Every little bit helps.

Also also, ff there's anything on your mind, please feel free to let us know. We truly value your feedback! Use the /feedback command to tell us what you think and how we can improve your Wordle experience.

And as always, consider joining @Xooniverse channel where we are likely to post any updates about the Wordle bot and other projects. 

Thank you for being part of our Wordle community. Enjoy the game, and let’s keep the fun going! ✨
""";

final api = RawAPI(WordleConfig.env["TOKEN"]);

void main(List<String> args) async {
  await broadcastLogic();
}

/// Keyboard to be attached with the broadcast message
final keyboard =
    InlineKeyboard().addUrl("Open @Xooniverse 🪐", "https://t.me/xooniverse");

/// Sends the broadcast message to specified users
Future<void> testBroadcast() async {
  final chats = [
    ChatID(1726826785),
  ];
  for (int i = 0; i < chats.length; i++) {
    await api.sendMessage(
      chats[i],
      text,
      replyMarkup: keyboard,
    );
    await Future.delayed(Duration(seconds: 1));
  }
}

/// Posts the broadcast message to Xooniverse channel.
Future<void> postToXooniverse() async {
  await api.sendMessage(
    ChannelID("@xooniverse"),
    text,
    replyMarkup: keyboard,
  );
}

/// Reference to the log file
final file = File("log.log");

/// Write log to file
void addlog(String text) async {
  // Get the current timestamp
  String timestamp = DateTime.now().toIso8601String();

  // Combine the timestamp with the log text
  String logEntry = '$timestamp - $text\n';
  print(logEntry);

  // Append the log entry to the file
  await file.writeAsString(logEntry, mode: FileMode.append);
}

/// Actual broadcast logic
Future<void> broadcastLogic() async {
  addlog("ℹ️ Starting up");
  final users = await WordleDB.getUsers();
  final ids = users.map((e) => ChatID(e.id)).toList();

  int count = ids.length;
  int sent = 293, failed = 198;
  List<ErrorUser> errorUsers = [];
  final statusMessage = await sendLogs(progressMessage(count, sent, failed));

  addlog("ℹ️ Got total of $count users");

  for (int i = 492; i < count; i++) {
    addlog("  > Processing ${i + 1}: ${ids[i].id}");
    try {
      await api.sendMessage(ids[i], text, replyMarkup: keyboard);
      addlog("  > ✅ Sent broadcast message");
      sent++;
      await Future.delayed(Duration(milliseconds: 2000));

      if (i % 10 == 0) {
        if (statusMessage != null) {
          await editLog(
            statusMessage.messageId,
            progressMessage(count, sent, failed),
          );
          addlog("📖 Updated channel log message");
          await Future.delayed(Duration(milliseconds: 2000));
        }
      }
    } catch (e) {
      addlog("  > ❌ Failed to send message to ${ids[i].id}");
      addlog("  > Error:");
      addlog("  > $e");
      failed++;
      errorUsers.add(
        ErrorUser(ids[i].id, e.toString()),
      );
      try {
        WordleUser user = await WordleUser.init(ids[i].id);
        user.optedOutOfBroadcast = true;
        user.id = ids[i].id;
        user.save().ignore();
        addlog("  > ℹ️ Updated user's `optedOutOfBroadcast`");
      } catch (err) {
        addlog(
          ">  🚫 Error occurred while trying to get user info from Firestore.",
        );
        addlog("    > $err");
      }
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
      await api.sendDocument(
        WordleConfig.instance.logsChannel,
        InputFile.fromFile(f),
        caption: "Failed IDs",
      );
    }
    await Future.delayed(Duration(seconds: 5), () {
      try {
        f.deleteSync();
      } catch (e) {
        addlog("Failed to delete file");
      }
    });
  } catch (e, s) {
    addlog("Failed to send logs");
    addlog("$e");
    addlog("$s");
  }

  addlog("ℹ️ Finished the process.");
}
