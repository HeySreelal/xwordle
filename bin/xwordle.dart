import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/handlers/guess.dart';
import 'package:xwordle/handlers/help.dart';
import 'package:xwordle/handlers/next.dart';
import 'package:xwordle/handlers/notify.dart';
import 'package:xwordle/handlers/profile.dart';
import 'package:xwordle/handlers/quit.dart';
import 'package:xwordle/handlers/start.dart';
import 'package:xwordle/handlers/update.dart';
import 'package:xwordle/models/session.dart';
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
  bot.command("profile", profileHandler());
  bot.onText(guessHandler());
}
