import 'package:televerse/telegram.dart' hide File;
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/models/admin.dart';
import 'package:xwordle/services/db.dart';

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

  /// Checks if the given [id] is an admin
  static bool check(ID id) {
    final config = WordleConfig.instance;
    return config.adminChats.contains(id);
  }

  /// Handles the /mod command
  static MessageHandler modHandler() {
    return (ctx) async {
      if (!check(ctx.id)) {
        await markUnauthorizedAttempt(ctx);
        return;
      }

      await ctx.reply(
        "Welcome, ${ctx.from?.firstName}! You know what to do.",
        replyMarkup: adminKeyboard,
      );
    };
  }

  /// Message to prompt the admin to send the broadcast message
  static const String broadcastPrompt = "Send me the broadcast message!";

  /// Handles the keyboard button presses
  static MessageHandler handleAdminText() {
    return (ctx) async {
      if (!check(ctx.id)) {
        await markUnauthorizedAttempt(ctx);
        return;
      }
      final text = ctx.message.text!;

      if (text == setBroadcast) {
        await ctx.reply(broadcastPrompt, replyMarkup: ForceReply());
      }
      if (text == seeBroadcast) {
        AdminFile? admin = AdminFile.read();
        if (admin == null) {
          await ctx.reply("No broadcast message set!");
          return;
        }
        await ctx.reply(
          "Broadcast message:\n\n${admin.message}",
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
  static Future<void> markUnauthorizedAttempt(MessageContext ctx) async {
    await ctx.api.sendMessage(
      WordleConfig.instance.logsChannel,
      "Unauthorized access attempt by ${ctx.from?.firstName}! (${ctx.id})",
    );
  }

  /// Handles the inline key press to confirm release
  static CallbackQueryHandler handleConfirmation() {
    return (ctx) async {
      if (!check(ctx.id)) {
        return;
      }
      final confirm = ctx.data == "release:yes";
      if (!confirm) {
        await ctx.editMessage(
          "Phew! That was close. Let's do this next time. 🫡",
        );
        return;
      }
      final admin = AdminFile.read();
      final message = admin?.message;
      if (admin == null || message == null) {
        await ctx.editMessage("No broadcast message set!");
        return;
      }

      final users = WordleDB.getUsers();
      int count = users.length;
      int sent = 0, failed = 0;

      for (int i = 0; i < count; i++) {
        try {
          await ctx.api.sendMessage(ChatID(users[i].userId), message);
          sent++;
          await Future.delayed(Duration(milliseconds: 2500));
        } catch (e) {
          failed++;
          continue;
        }

        if (i % 10 == 0) {
          await ctx.editMessage(
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
      await ctx.editMessage(resultMsg);
      await ctx.api.sendMessage(
        WordleConfig.instance.logsChannel,
        "$resultMsg\n\n#broadcast",
      );
    };
  }

  /// Test Broadcast Message
  static MessageHandler testBroadcastHandler() {
    return (ctx) async {
      if (!check(ctx.id)) {
        await markUnauthorizedAttempt(ctx);
        return;
      }
      final admin = AdminFile.read();
      final message = admin?.message;
      if (admin == null || message == null) {
        await ctx.reply("No broadcast message set!");
        return;
      }
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
  static MessageHandler countHandler() {
    return (ctx) async {
      if (!check(ctx.id)) {
        await markUnauthorizedAttempt(ctx);
        return;
      }
      final users = WordleDB.getUsers();
      int count = users.length;
      await ctx.reply("Total users: $count");
    };
  }
}

/// Extension isAdmin on ID
extension IsAdmin on ID {
  /// Checks if the given [id] is an admin
  bool get isAdmin => Admin.check(this);
}
