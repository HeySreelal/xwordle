import 'package:xwordle/handlers/admin.dart';
import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/handlers/feedback.dart';
import 'package:xwordle/handlers/guess.dart';
import 'package:xwordle/handlers/help.dart';
import 'package:xwordle/handlers/meaning.dart';
import 'package:xwordle/handlers/next.dart';
import 'package:xwordle/handlers/notify.dart';
import 'package:xwordle/handlers/profile.dart';
import 'package:xwordle/handlers/quit.dart';
import 'package:xwordle/handlers/shape.dart';
import 'package:xwordle/handlers/start.dart';
import 'package:xwordle/handlers/update.dart';
import 'package:xwordle/models/user.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) {
  updateWord();
  bot.initSession(WordleUser.init);
  bot.start(startHandler());
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
  bot.command('cancel', (ctx) {});
  bot.onText(guessHandler());

  // Admin Handlers
  bot.command("mod", Admin.modHandler());
  bot.command("count", Admin.countHandler());
  bot.command('testbroadcast', Admin.testBroadcastHandler());
  bot.command('stats', Admin.statsHandler());
  bot.hears(Admin.broadcastPattern, Admin.handleAdminText());
  bot.callbackQuery(Admin.releasePattern, Admin.handleConfirmation());
}
