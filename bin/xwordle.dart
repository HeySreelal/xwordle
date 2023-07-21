import 'package:xwordle/xwordle.dart';

void main(List<String> args) {
  updateWord();
  bot.initSession(WordleUser.init);
  bot.start(startHandler());
  bot.settings(settingsHandler());
  bot.callbackQuery(settingsPattern, settingsCallback());
  bot.onError(errorHandler);
  bot.command("notify", notifyHandler());
  bot.callbackQuery(notificationPattern, handleNotificationTap());
  bot.command("help", helpHandler());
  bot.command("about", aboutHandler());
  bot.command("next", nextWordHandler());
  bot.command("quit", quitHandler());
  bot.callbackQuery(quitPattern, handleQuitInteraction());
  bot.command("profile", profileHandler());
  bot.command('meaning', meaningHandler());
  bot.command('shape', shapeHandler());
  bot.command('feedback', feedbackHandler());
  bot.command('cancel', cancelHandler());
  bot.onText(guessHandler());

  // Admin Handlers
  bot.command("mod", Admin.modHandler());
  bot.command("count", Admin.countHandler());
  bot.command('testbroadcast', Admin.testBroadcastHandler());
  bot.command('stats', Admin.statsHandler());
  bot.hears(Admin.broadcastPattern, Admin.handleAdminText());
  bot.callbackQuery(Admin.releasePattern, Admin.handleConfirmation());
  bot.onChannelPost(respondToFeedback);
}
