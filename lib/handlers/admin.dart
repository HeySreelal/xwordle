part of '../xwordle.dart';

class Admin {
  // Some text constants
  static const String setBroadcast = "Set Broadcast Note 📝";
  static const String seeBroadcast = "See Broadcast Message 👀";
  static const String releaseBroadcast = "Release Broadcast 🚀";

  /// Pattern to match any of the three button texts
  static final broadcastPattern = RegExp(
    "$setBroadcast|$seeBroadcast|$releaseBroadcast",
  );

  /// Pattern to match the release confirmation
  static final releasePattern = RegExp("release:(yes|no)");

  /// Keyboard for admin
  static final adminKeyboard = Keyboard()
      .addText(setBroadcast)
      .row()
      .addText(seeBroadcast)
      .row()
      .addText(releaseBroadcast)
      .oneTime()
      .resized();

  /// Static confirm release inline keyboard
  static final confirmReleaseKeyboard = InlineKeyboard()
      .add("Shoot, right away! 🚀", "release:yes")
      .row()
      .add("Step back, now! 🙅🏻‍♂️", "release:no");

  /// Checks if the given [ctx] is an admin
  static bool check(Context ctx) {
    final config = WordleConfig.instance;

    final contains = config.adminChats.contains(ctx.id);
    if (!contains) {
      markUnauthorizedAttempt(ctx).ignore();
    }
    return contains;
  }

  /// Handles the /mod command
  static Handler modHandler() {
    return (ctx) async {
      await ctx.reply(
        "Welcome, ${ctx.from?.firstName}! You know what to do.",
        replyMarkup: adminKeyboard,
      );
      await ctx.reply("Don't forget /testbroadcast and /stats");
    };
  }

  /// Message to prompt the admin to send the broadcast message
  static const String broadcastPrompt = "Send me the broadcast message!";

  /// Handles the keyboard button presses
  static Handler handleAdminText() {
    return (ctx) async {
      final text = ctx.message?.text!;

      if (text == setBroadcast) {
        await ctx.reply(broadcastPrompt);
        final replyCtx = await conv.waitForTextMessage(chatId: ctx.id);
        if (replyCtx?.message?.text == null) return;
        final broadcast = replyCtx?.message?.text;
        await AdminConfig.setReleaseNote(broadcast!);
        await replyCtx?.reply("Broadcast message set!");
      }

      if (text == seeBroadcast) {
        final admin = await AdminConfig.get();
        await ctx.reply(
          "Broadcast message:\n\n${admin.releaseNote}",
          replyMarkup: adminKeyboard,
          parseMode: ParseMode.html,
        );
      }

      if (text == releaseBroadcast) {
        ctx.reply(
          "Are you sure want to release the broadcast? 👀",
          replyMarkup: confirmReleaseKeyboard,
        );
      }
    };
  }

  /// Marks an unauthorized attempt to access admin commands
  static Future<void> markUnauthorizedAttempt(Context ctx) async {
    await sendLogs(
      "Unauthorized access attempt by ${ctx.from?.firstName}! (${ctx.id.id})",
    );
  }

  /// Handles the inline key press to confirm release
  static Handler handleConfirmation() {
    return (ctx) async {
      final confirm = ctx.callbackQuery?.data == "release:yes";
      if (!confirm) {
        await ctx.editMessageText(
          "Phew! That was close. Let's do this next time. 🫡",
        );
        return;
      }
      final admin = await AdminConfig.get();
      final message = admin.releaseNote;

      await broadcast(
        message,
        keyboard: InlineKeyboard()
            .switchInlineQuery("Invite Friends 💌")
            .row()
            .addUrl(
              "@Xooniverse",
              "https://t.me/xooniverse",
            ),
      );
    };
  }

  /// Test Broadcast Message
  static Handler testBroadcastHandler() {
    return (ctx) async {
      final admin = await AdminConfig.get();
      final message = admin.releaseNote;
      final admins = WordleConfig.instance.adminChats;
      await broadcast(
        userSet: admins.map((e) => e.id).toList(),
        message,
        keyboard: InlineKeyboard()
            .switchInlineQuery("Invite Friends 💌")
            .row()
            .addUrl(
              "@Xooniverse",
              "https://t.me/xooniverse",
            ),
      );

      await ctx.reply("Test broadcast message sent!");
    };
  }

  /// Handles count command
  static Handler countHandler() {
    return (ctx) async {
      final users = await WordleDB.getAllUsers();
      int count = users.length;
      await ctx.reply("Total users: $count");
    };
  }

  /// /stats command handler
  static Handler statsHandler() {
    return (ctx) async {
      await ctx.replyWithChatAction(ChatAction.typing);
      final msg = statsMessage(requestedUser: ctx.chat?.id);
      await ctx.reply(await msg, parseMode: ParseMode.html);
    };
  }
}

/// Extension isAdmin on ID
extension IsAdmin on Context {
  /// Checks if the given [id] is an admin
  bool get isAdmin => Admin.check(this);
}

void logToFile(String text) async {
  // Get the current timestamp
  String timestamp = DateTime.now().toIso8601String();

  // Combine the timestamp with the log text
  String logEntry = '$timestamp - $text\n';

  print(logEntry);

  // Create a reference to the file
  File file = File("log.log");

  // Append the log entry to the file
  file.writeAsStringSync(logEntry, mode: FileMode.append);
}

const gap = "    ";
Future<void> broadcast(
  String message, {
  InlineKeyboard? keyboard,
  List<int>? userSet,
}) async {
  List<WordleUser> users;
  if (userSet != null) {
    logToFile("ℹ️ We have a specified user set.");
    users = await Future.wait(userSet.map((e) => WordleUser.init(e)));
  } else {
    logToFile("ℹ️ No user set is specified. Targeting whole users.");
    users = await Future.wait(
      (await WordleDB.getAllUsers()).map((e) => WordleUser.init(e)),
    );
  }

  final stopwatch = Stopwatch()..start();

  List<int> successPeople = [];
  int success = 0, failure = 0;
  List<ErrorUser> errorUsers = [];
  logToFile("ℹ️ Sending the progress-log message");
  final statusMsg = await sendLogs(
    progressMessage(users.length, success, failure),
  );
  if (statusMsg == null) {
    logToFile("Couldn't send status message. So aborting.");
    return;
  }
  logToFile("🌟 Progress log message sent succesfully");

  logToFile("Got ${users.length} users to send messages to.");
  for (var (n, user) in users.indexed) {
    try {
      logToFile("ℹ️ ${n + 1}/${users.length} Sending broadcast to  ${user.id}");
      await api.sendMessage(
        ChatID(user.id),
        message,
        parseMode: ParseMode.html,
        replyMarkup: keyboard,
      );
      logToFile("$gap> ✅ Success");
      success++;
      successPeople.add(user.id);

      await Future.delayed(Duration(seconds: 2));
    } catch (err, stack) {
      failure++;
      logToFile("$gap> ❌ An error occurred");

      if (err is TelegramException) {
        logToFile("$gap> Telegram Exception: $err");
        errorUsers.add(
          ErrorUser(user.id, err.description ?? "$err"),
        );
        continue;
      }
      errorUsers.add(ErrorUser(user.id, "$err"));
      logToFile("$gap>Unknown Error");
      logToFile("$gap>$err\n$stack");
    } finally {
      if ((success + failure) % 10 == 0) {
        await editLog(
          statusMsg.messageId,
          progressMessage(users.length, success, failure),
        );
        await Future.delayed(Duration(milliseconds: 2000));
      }
    }
  }
  stopwatch.stop();
  logToFile("⏰ Took ${stopwatch.elapsed}");
  sendLogs("⏰ Took ${stopwatch.elapsed}").ignore();
  editLog(
    statusMsg.messageId,
    "${progressMessage(success + failure, success, failure)}\n\n#Broadcast",
  ).ignore();
  logToFile("✅ The log message has been updated with final results.");
  logToFile(
    "ℹ️ Successfully sent to $success people. Those are: $successPeople",
  );
  await createLogFileAndSend(errorUsers);
  logToFile("💥 Error log is created and sent.");
  logToFile("✅ Finished");

  final file = File("log.log");
  await api.sendDocument(
    WordleConfig.init().logsChannel,
    InputFile.fromFile(file),
  );

  await Future.delayed(Duration(seconds: 5), () {
    file.deleteSync();
  });
}
