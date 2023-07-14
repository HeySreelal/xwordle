import 'package:xwordle/handlers/error.dart';
import 'package:xwordle/handlers/start.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) {
  bot.initSession(WordleSession.init);
  bot.start(startHandler());
  bot.onError(errorHandler);
}
