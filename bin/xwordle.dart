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
  bot.command("privacy", privacyHandler());
  bot.command("hint", hintsHandler());

  // Handling errors
  bot.onError(errorHandler);

  // Callback Query Handlers
  bot.callbackQuery(notificationPattern, handleNotificationTap());
  bot.callbackQuery(quitPattern, handleQuitInteraction());
  bot.callbackQuery(settingsPattern, settingsCallback());
  bot.callbackQuery(donatePattern, donateCallbackHandler());
  bot.callbackQuery(starsCountPattern, starsCountSelectionHandler());
  bot.callbackQuery("start", startHandler(callback: true));

  // Hints related callback handlers
  bot.callbackQuery(hintsGetPattern, hintsGetHandler());
  bot.callbackQuery(useLetterPattern, useHintHandler());
  bot.callbackQuery(useAttemptPattern, useHintHandler());
  bot.callbackQuery(backToPricingPattern, hintsGetHandler(shouldEdit: true));
  bot.callbackQuery(hintsIndividual, hintsIndividualHandler());
  bot.callbackQuery(buykickstart, buyHandler(buykickstart));
  bot.callbackQuery(buyadvantage, buyHandler(buyadvantage));
  bot.callbackQuery(buydomination, buyHandler(buydomination));
  bot.callbackQuery(letterRevealPattern, buyHandler(letterreveal));
  bot.callbackQuery(extraattemptPattern, buyHandler(extraattempt));

  // Admin lock checker
  final checker = ScopeOptions(customPredicate: Admin.check);

  // Admin Handlers
  bot.command("mod", Admin.modHandler(), options: checker);
  bot.command("count", Admin.countHandler(), options: checker);
  bot.command('testbroadcast', Admin.testBroadcastHandler(), options: checker);
  bot.command('stats', Admin.statsHandler(), options: checker);
  bot.command(
    'paid',
    handleSuccessPaymentForHints(buyadvantage),
    options: checker,
  );

  // Admin Broadcast pattern
  bot.hears(Admin.broadcastPattern, Admin.handleAdminText(), options: checker);
  bot.onChannelPost(respondToFeedback);
  bot.onPreCheckoutQuery(preCheckoutHandler());

  // Admin release callback query
  bot.callbackQuery(
    Admin.releasePattern,
    Admin.handleConfirmation(),
    options: checker,
  );

  // Listen for inline queries
  bot.onInlineQuery(inlineHandler());

  // Successful payments
  bot.onSuccessfulPayment(successPaymentHandler());

  // Start the bot
  bot.start();
}
