import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';

Pattern notificationPattern = RegExp(r"notify_(yes|no)");

/// Creates an inline keyboard for notification settings
InlineKeyboard notificationMenu(
    [bool enabled = true, bool isYesNoMenu = true]) {
  final menu = InlineKeyboard();
  if (isYesNoMenu) {
    return menu.add("Yes 🚀", "notify_yes").add("No 🔕", "notify_no");
  } else {
    return menu.add(
      enabled ? "Enabled ✅" : "Disabled 🔕",
      "notify${enabled ? "_no" : "_yes"}",
    );
  }
}

/// Handles the /notify command
MessageHandler notifyHandler() {
  return (ctx) async {
    final user = ctx.session as WordleSession;
    await ctx.reply(
      notificationPrompt,
      replyMarkup: notificationMenu(user.notify, true),
    );
  };
}

/// Handles enables the notification
CallbackQueryHandler handleNotificationTap() {
  return (ctx) async {
    final user = ctx.session as WordleSession;

    user.notify = ctx.data == "notify_yes";
    user.saveToFile();
    await ctx.editMessage(
      "$notificationSettings\n\nYou will ${!user.notify ? 'not ' : ''}be notified when new word is available.",
      replyMarkup: notificationMenu(user.notify, false),
      parseMode: ParseMode.html,
    );
  };
}

String notificationSettings = "<b>Notification Settings ⚙️</b>";
