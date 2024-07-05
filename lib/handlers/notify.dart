part of '../xwordle.dart';

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
Handler notifyHandler() {
  return (ctx) async {
    final user = await WordleUser.init(ctx.id.id);
    await ctx.reply(
      MessageStrings.notificationPrompt,
      replyMarkup: notificationMenu(user.notify, true),
    );
  };
}

/// Handles enables the notification
Handler handleNotificationTap() {
  return (ctx) async {
    await ctx.answerCallbackQuery();
    final user = await WordleUser.init(ctx.id.id);

    user.notify = ctx.callbackQuery?.data == "notify_yes";
    user.save();
    await ctx.editMessageText(
      "$notificationSettings\n\nYou will ${!user.notify ? 'not ' : ''}be notified when new word is available.",
      replyMarkup: notificationMenu(user.notify, false),
      parseMode: ParseMode.html,
    );
  };
}

String notificationSettings = "<b>Notification Settings ⚙️</b>";
