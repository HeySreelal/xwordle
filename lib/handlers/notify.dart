import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';

/// Creates an inline menu for notification settings
InlineMenu notificationMenu([bool enabled = true, bool isYesNoMenu = true]) {
  final menu = InlineMenu();
  if (isYesNoMenu) {
    return menu
        .text("Yes 🚀", handleYes(), data: "notify_yes")
        .text("No 🔕", handleNo(), data: "notify_no");
  } else {
    return menu.text(
      enabled ? "Enabled ✅" : "Disabled 🔕",
      enabled ? handleNo() : handleYes(),
      data: "notify${enabled ? "_no" : "_yes"}",
    );
  }
}

MessageHandler notifyHandler() {
  return (ctx) async {
    final user = ctx.session as WordleSession;
    await ctx.reply(
      notificationPrompt,
      replyMarkup: notificationMenu(user.notify, true),
    );
  };
}

CallbackQueryHandler handleYes() {
  return (ctx) async {
    final user = ctx.session as WordleSession;
    user.notify = true;
    user.saveToFile();
    await ctx.editMessage(
      "$notificationSettings\n\nYou will be notified when new word is available.",
      replyMarkup: notificationMenu(user.notify, false),
      parseMode: ParseMode.html,
    );
  };
}

CallbackQueryHandler handleNo() {
  return (ctx) async {
    final user = ctx.session as WordleSession;
    user.notify = false;
    user.saveToFile();
    await ctx.editMessage(
      "$notificationSettings\n\nYou will not be notified when new word is available.",
      replyMarkup: notificationMenu(user.notify, false),
      parseMode: ParseMode.html,
    );
  };
}

String notificationSettings = "<b>Notification Settings ⚙️</b>";
