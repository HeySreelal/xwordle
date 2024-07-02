import 'package:xwordle/xwordle.dart';

void main(List<String> args) {
  // Update the word
  updateWord();

  bot.use(AutoChatAction());

  // Handle commands
  bot.command("start", startHandler());
  bot.command("settings", settingsHandler());
  bot.command("notify", notifyHandler());
  bot.command("help", helpHandler());
  bot.command("about", aboutHandler());
  bot.command("next", nextWordHandler());
  bot.command("quit", quitHandler());
  bot.command("profile", profileHandler());
  bot.command("meaning", meaningHandler());
  bot.command("shape", shapeHandler());
  bot.command("feedback", feedbackHandler());
  bot.command("cancel", cancelHandler());

  // Handling errors
  bot.onError(errorHandler);

  // Callback Query Handlers
  bot.callbackQuery(notificationPattern, handleNotificationTap());
  bot.callbackQuery(quitPattern, handleQuitInteraction());
  bot.callbackQuery(settingsPattern, settingsCallback());

  // Admin Handlers
  bot.command("mod", Admin.modHandler());
  bot.command("count", Admin.countHandler());
  bot.command('testbroadcast', Admin.testBroadcastHandler());
  bot.command('stats', Admin.statsHandler());

  // Admin Broadcast pattern
  bot.hears(Admin.broadcastPattern, Admin.handleAdminText());
  bot.onChannelPost(respondToFeedback);

  // Admin release callback query
  bot.callbackQuery(Admin.releasePattern, Admin.handleConfirmation());

  // Handle guessed word
  bot.onText(guessHandler());

  // Start the bot
  bot.start();
}
