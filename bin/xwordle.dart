import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  // Update the word
  await updateWord();

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

  // Admin lock checker
  final checker = ScopeOptions(customPredicate: Admin.check);

  // Admin Handlers
  bot.command("mod", Admin.modHandler(), options: checker);
  bot.command("count", Admin.countHandler(), options: checker);
  bot.command('testbroadcast', Admin.testBroadcastHandler(), options: checker);
  bot.command('stats', Admin.statsHandler(), options: checker);

  // Admin Broadcast pattern
  bot.hears(Admin.broadcastPattern, Admin.handleAdminText(), options: checker);
  bot.onChannelPost(respondToFeedback);

  // Admin release callback query
  bot.callbackQuery(
    Admin.releasePattern,
    Admin.handleConfirmation(),
    options: checker,
  );

  // Handle guessed word
  bot.onText(guessHandler());

  // Start the bot
  bot.start();
}
