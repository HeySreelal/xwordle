import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';

MessageHandler startHandler() {
  return (MessageContext ctx) async {
    final game = WordleDB.today;
    final user = ctx.session as WordleSession;

    if (game.index == user.lastGame) {
      final msg = random(excitedMessages).replaceAll(
        "{TIME}",
        game.formattedDurationTillNext,
      );
      await ctx.reply(
        msg,
        replyToMessageId: ctx.message.messageId,
      );
      return;
    }

    /// If the user is already playing a game, tell them to finish it first
    if (user.onGame && user.currentGame == game.index) {
      await ctx.api.sendChatAction(ctx.id, ChatAction.typing);
      await ctx.reply(inGameMessages["already"]!);
      return;
    }

    /// Let's start a new game
    await ctx.api.sendChatAction(ctx.id, ChatAction.typing);
    await ctx.reply(inGameMessages["letsStart"]!, parseMode: ParseMode.html);
    user.onGame = true;
    if (user.currentGame != game.index) {
      user.currentGame = game.index;
      user.tries = [];
      user.totalGamesPlayed++;
    }
    user.saveToFile();
  };
}
