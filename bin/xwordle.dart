import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  // Init the bot
  await init();

  // Update the word
  await updateWord();

  // Handle guessed word
  bot.onText(guessHandler());

  // Use auto-chat-action to send chat actions automatically
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
  bot.command("donate", donateHandler());
  bot.command("nudge", nudgeDonation);

  // Handling errors
  bot.onError(errorHandler);

  // Callback Query Handlers
  bot.callbackQuery(notificationPattern, handleNotificationTap());
  bot.callbackQuery(quitPattern, handleQuitInteraction());
  bot.callbackQuery(settingsPattern, settingsCallback());
  bot.callbackQuery(donatePattern, donateCallbackHandler());
  bot.callbackQuery(starsCountPattern, starsCountSelectionHandler());
  bot.callbackQuery("start", startHandler(callback: true));

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

  // Handle any unanswered callback queries
  bot.onCallbackQuery(
    (ctx) => ctx.answerCallbackQuery(),
    options: ScopeOptions.forked(),
  );

  // Listen for inline queries
  bot.onInlineQuery(inlineHandler());

  // Start the bot
  bot.start();
}
