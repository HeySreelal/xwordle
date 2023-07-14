import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/handlers/help.dart';
import 'package:xwordle/handlers/next.dart';
import 'package:xwordle/handlers/notify.dart';
import 'package:xwordle/handlers/quit.dart';
import 'package:xwordle/handlers/start.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) {
  bot.initSession(WordleSession.init);
  bot.start(startHandler());
  bot.onError(errorHandler);
  bot.command("notify", notifyHandler());
  bot.callbackQuery(notificationPattern, handleNotificationTap());
  bot.command("help", helpHandler());
  bot.command("about", aboutHandler());
  bot.command("next", nextWordHandler());
  bot.command("quit", quitHandler());
}
