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
          "Are you sure want to release the broadcast?",
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

      final users = await WordleDB.getUsers();
      int count = users.length;
      int sent = 0, failed = 0;

      for (int i = 0; i < count; i++) {
        try {
          await ctx.api.sendMessage(
            ChatID(users[i].id),
            message,
            parseMode: ParseMode.html,
          );
          sent++;
          await Future.delayed(Duration(milliseconds: 2500));
        } catch (e) {
          failed++;
          continue;
        }

        if (i % 10 == 0) {
          await ctx.editMessageText(
            "Sending broadcast message...\n\n"
            "Sent: $sent\n"
            "Failed: $failed\n"
            "Total: $count",
          );
        }
      }
      final resultMsg = "Broadcast message sent!\n\n 🤘"
          "Sent: $sent\n"
          "Failed: $failed\n"
          "Total: $count";
      await ctx.editMessageText(resultMsg);
      await sendLogs("$resultMsg\n\n#broadcast");
    };
  }

  /// Test Broadcast Message
  static Handler testBroadcastHandler() {
    return (ctx) async {
      final admin = await AdminConfig.get();
      final message = admin.releaseNote;
      final admins = WordleConfig.instance.adminChats;
      for (int i = 0; i < admins.length; i++) {
        await ctx.api.sendMessage(
          admins[i],
          message,
          parseMode: ParseMode.html,
        );
        await Future.delayed(Duration(milliseconds: 2500));
      }

      await ctx.reply("Test broadcast message sent!");
    };
  }

  /// Handles count command
  static Handler countHandler() {
    return (ctx) async {
      final users = await WordleDB.getUsers();
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
