part of '../xwordle.dart';

/// Available settings
enum Settings {
  changeName("change_name"),
  toggleNotifications("toggle_notifications"),
  toggleProductUpdates("toggle_product_updates"),
  changeHintShape("change_hint_shape"),
  resetProfile("reset_profile"),
  nothing("nothing");

  final String value;
  const Settings(this.value);

  @override
  String toString() => value;

  static Settings fromString(String value) {
    return Settings.values.firstWhere(
      (element) => element.value == value,
      orElse: () => Settings.nothing,
    );
  }
}

String notificationIcon(WordleUser user, {bool negate = false}) {
  return user.notify ^ negate ? "🔔" : "🔕";
}

String productUpdateIcon(WordleUser user, {bool negate = false}) {
  return user.optedOutOfBroadcast ^ negate ? "❌" : "✅";
}

InlineKeyboard settingsKeyboard(WordleUser user) {
  return InlineKeyboard()
      .add("💬 Change Name", "settings:${Settings.changeName}")
      .row()
      .add(
        "${notificationIcon(user)} Notifications ",
        "settings:${Settings.toggleNotifications}",
      )
      .row()
      .add(
        "Product Update Messages ${productUpdateIcon(user)}",
        "settings:${Settings.toggleProductUpdates}",
      )
      .row()
      .add(
        "${user.hintShape.correct} Change Hint Shape",
        "settings:${Settings.changeHintShape}",
      )
      .row()
      .add(
        "⛑️ Reset my profile",
        "settings:${Settings.resetProfile}",
      );
}

Handler settingsHandler() {
  return (ctx) async {
    final user = WordleUser.init(ctx.id.id);

    final currentMessage = settingsMessage(user);
    await ctx.reply(
      currentMessage,
      replyMarkup: settingsKeyboard(user),
      parseMode: ParseMode.html,
    );
  };
}

String settingsMessage(WordleUser user) {
  return "<b>Settings</b> ⚙️\n------------\n"
      "💬 Name: ${user.name}\n"
      "🆔 ID: ${user.userId}\n\n"
      "${notificationIcon(user)} Notifications: ${user.notify ? 'Enabled' : 'Disabled'}\n"
      "🔄 Product Update Messages: ${!user.optedOutOfBroadcast ? 'Enabled' : 'Disabled'}\n"
      "${user.hintShape.correct} Hint Shape: ${user.hintShape.name}\n\n"
      "<b>Game Profile</b>: \n"
      "------------\n\n"
      "🔢 Current Game: ${user.currentGame}\n"
      "🔥 Current Streak ${user.streak}\n"
      "🏆 Total Wins: ${user.totalWins}\n"
      "🎮 Total Games Played: ${user.totalGamesPlayed}\n"
      "🔢 Longest Streak: ${user.maxStreak}\n"
      "🎯 Perfect Games: ${user.perfectGames}\n";
}

/// Pattern used to match the setting callback query
final settingsPattern = RegExp(r"settings:(.*)");

/// Handles the settings callback query
Handler settingsCallback() {
  return (ctx) async {
    final s = settingsPattern.firstMatch(ctx.callbackQuery!.data!)!.group(1)!;
    final setting = Settings.fromString(s);
    bool hasChange = false;
    switch (setting) {
      case Settings.changeName:
        hasChange = await changeNameCallback(ctx);
        break;
      case Settings.toggleNotifications:
        hasChange = await toggleNotificationsCallback(ctx);
        break;
      case Settings.toggleProductUpdates:
        hasChange = await toggleProductUpdatesCallback(ctx);
        break;
      case Settings.changeHintShape:
        hasChange = await changeHintShapeCallback(ctx);
        break;
      case Settings.resetProfile:
        hasChange = await resetProfileCallback(ctx);
        break;
      case Settings.nothing:
        await ctx.answerCallbackQuery(text: "Nothing to do here.");
        break;
    }
    if (!hasChange) return;

    final user = WordleUser.init(ctx.id.id);
    await ctx.editMessageText(
      settingsMessage(user),
      parseMode: ParseMode.html,
      replyMarkup: settingsKeyboard(user),
    );
  };
}

/// Hnadles the change name callback query
Future<bool> changeNameCallback(Context ctx) async {
  await ctx.api.sendMessage(ctx.id, "Okay, send me your new name.");
  await ctx.api.sendMessage(
    ctx.id,
    random(MessageStrings.cancel).replaceAll(
      "{ACTION}",
      "changing profile name",
    ),
  );
  await ctx.answerCallbackQuery();
  final replyCtx = await conv.waitForTextMessage(chatId: ctx.id);
  if (replyCtx?.message?.text == "/cancel") {
    await ctx.api.sendMessage(ctx.id, "Okay, I won't change your name.");
    return false;
  }

  final user = WordleUser.init(ctx.id.id);
  user.name = replyCtx!.message!.text!;
  user.saveToFile();
  await ctx.api.sendMessage(
    ctx.id,
    "Okay, I've changed your name to ${user.name}.",
  );
  return true;
}

/// Handles the toggle notifications callback query
Future<bool> toggleNotificationsCallback(Context ctx) async {
  final user = WordleUser.init(ctx.id.id);
  user.notify = !user.notify;
  user.saveToFile();
  await ctx.answerCallbackQuery(
    text: "Okay, I'll${user.notify ? '' : 'not '} update you on new games.",
  );

  return true;
}

/// Handles the toggle product updates callback query
Future<bool> toggleProductUpdatesCallback(Context ctx) async {
  final user = WordleUser.init(ctx.id.id);
  user.optedOutOfBroadcast = !user.optedOutOfBroadcast;
  user.saveToFile();
  await ctx.answerCallbackQuery(
    text:
        "Okay, you're now opted ${user.optedOutOfBroadcast ? 'out of' : 'into'} product updates.",
  );
  return true;
}

/// Handles the change hint shape callback query
Future<bool> changeHintShapeCallback(Context ctx) async {
  final txt = random(MessageStrings.shapesPrompts);
  await ctx.answerCallbackQuery(text: "Okay, send me your new hint shape.");
  await ctx.api.sendMessage(ctx.id, txt, replyMarkup: hintShapesKeyboard);
  await ctx.api.sendMessage(
    ctx.id,
    "Just know you can send /cancel to cancel the command.",
  );
  return await setShapeHandler(ctx.id);
}

/// Handles the reset profile callback query
Future<bool> resetProfileCallback(Context ctx) async {
  final user = WordleUser.init(ctx.id.id);
  user.resetProfile(ctx.callbackQuery!.from.fullName);
  user.saveToFile();
  await ctx.answerCallbackQuery(text: "Okay, I've reset your profile.");
  return true;
}
